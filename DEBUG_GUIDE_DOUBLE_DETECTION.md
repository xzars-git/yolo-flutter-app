# 🔬 Debug Guide - Double Detection Investigation

## 🚨 Current Status: STILL DOUBLE DETECTION

### Screenshot Evidence:
- **Detected: 68** (should be ~34)
- **Cropped: 65** (should be ~33)  
- **2 boxes** with **IDENTICAL confidence: 73.6%** 😱

---

## ⚠️ Critical Discovery: Identical Confidence

**This is VERY suspicious!** Two boxes with **exactly the same confidence** (73.6%) suggests:

1. **Possible duplicate at model level** (before NMS)
2. **Possible duplicate in result handling** (after NMS)
3. **Possible issue in coordinate transformation**

Normal double detection would show:
- Box 1: 76.9%
- Box 2: 75.1% ← Different confidence

But we see:
- Box 1: 73.6%
- Box 2: 73.6% ← **IDENTICAL** 🚩

---

## 🔍 Implemented Fix - Enhanced Logging

### Changes Made:

**File**: `ObjectDetector.kt`

#### 1. **Native NMS Output Logging** (Line ~343)
```kotlin
Log.d(TAG, "=== DETECTION RESULTS (After Native NMS) ===")
Log.d(TAG, "Total detections from native code: ${resultBoxes.size}")
for ((index, boxArray) in resultBoxes.withIndex()) {
    Log.d(TAG, "  Native[$index]: conf=${boxArray[4]}, cls=${boxArray[5].toInt()}")
}
```

#### 2. **Pre-Deduplication Logging** (Line ~383)
```kotlin
Log.d(TAG, "=== BOXES BEFORE DEDUPLICATION ===")
Log.d(TAG, "Total boxes created: ${boxes.size}")
for ((index, box) in boxes.withIndex()) {
    Log.d(TAG, "  Box[$index]: ${box.cls} conf=${box.conf}")
}
```

#### 3. **Deduplication Process Logging** (Line ~448)
```kotlin
private fun removeDuplicateDetections(boxes: List<Box>): List<Box> {
    Log.d(TAG, "🔍 === STARTING DEDUPLICATION PROCESS ===")
    
    for ((index, box) in sortedBoxes.withIndex()) {
        Log.d(TAG, "🔍 Checking box[$index]: ${box.cls} conf=${box.conf}")
        
        for ((keptIndex, keptBox) in keep.withIndex()) {
            val iou = computeIoU(box.xywh, keptBox.xywh)
            Log.d(TAG, "🔍   vs kept[$keptIndex]: IoU=$iou")
            
            if (iou > 0.15f) {
                Log.w(TAG, "🗑️ REMOVING: conf=${box.conf} (IoU=$iou)")
                break
            }
        }
    }
    
    Log.d(TAG, "✅ Deduplication complete: ${boxes.size} → ${keep.size}")
}
```

#### 4. **Post-Deduplication Logging** (Line ~390)
```kotlin
Log.d(TAG, "=== BOXES AFTER DEDUPLICATION ===")
Log.d(TAG, "Total boxes remaining: ${deduplicatedBoxes.size}")
for ((index, box) in deduplicatedBoxes.withIndex()) {
    Log.d(TAG, "  Box[$index]: ${box.cls} conf=${box.conf}")
}
```

---

## 📊 Expected Log Output

### Scenario 1: Working Correctly (Should Remove Duplicates)

```
========================================
=== DETECTION RESULTS (After Native NMS) ===
Total detections from native code: 2
  Native[0]: conf=0.736, cls=0, x=0.12, y=0.34
  Native[1]: conf=0.736, cls=0, x=0.12, y=0.34
========================================

========================================
=== BOXES BEFORE DEDUPLICATION ===
Total boxes created: 2
  Box[0]: plate_number conf=0.736
  Box[1]: plate_number conf=0.736
========================================

🔍 ========================================
🔍 === STARTING DEDUPLICATION PROCESS ===
🔍 Input: 2 boxes
🔍 Sorted by confidence (highest first)
🔍   Sorted[0]: plate_number conf=0.736
🔍   Sorted[1]: plate_number conf=0.736

🔍 Checking box[0]: plate_number conf=0.736
✅ KEEPING: plate_number conf=0.736

🔍 Checking box[1]: plate_number conf=0.736
🔍   vs kept[0]: plate_number conf=0.736, IoU=0.95
🗑️ REMOVING: plate_number conf=0.736 (IoU=0.95 > 0.15)

✅ Deduplication complete: 2 → 1 boxes
✅ Removed: 1 duplicates
🔍 ========================================

========================================
=== BOXES AFTER DEDUPLICATION ===
Total boxes remaining: 1
  Box[0]: plate_number conf=0.736
========================================
```

### Scenario 2: NOT Working (Duplicates Persist)

```
========================================
=== DETECTION RESULTS (After Native NMS) ===
Total detections from native code: 2
  Native[0]: conf=0.736, cls=0
  Native[1]: conf=0.736, cls=0
========================================

========================================
=== BOXES BEFORE DEDUPLICATION ===
Total boxes created: 2
  Box[0]: plate_number conf=0.736
  Box[1]: plate_number conf=0.736
========================================

🔍 Deduplication skipped: 2 box(es) only  ← ⚠️ WRONG!
```

OR

```
🔍 Checking box[1]: plate_number conf=0.736
🔍   vs kept[0]: plate_number conf=0.736, IoU=0.05  ← ⚠️ IoU too low!
✅ KEEPING: plate_number conf=0.736  ← ⚠️ SHOULD REMOVE!
```

---

## 🧪 Testing Commands

### 1. **Check Logcat for Deduplication**
```powershell
# In PowerShell
adb logcat | Select-String -Pattern "ObjectDetector|Deduplication|REMOVING|KEEPING"
```

### 2. **Count Detections**
```powershell
# Count "BOXES BEFORE" vs "BOXES AFTER"
adb logcat | Select-String -Pattern "BOXES BEFORE DEDUPLICATION|BOXES AFTER DEDUPLICATION"
```

### 3. **Check IoU Calculations**
```powershell
# See IoU values being computed
adb logcat | Select-String -Pattern "IoU="
```

### 4. **Full Debug Log**
```powershell
# Save full log to file
adb logcat -d > debug_log.txt
```

---

## 🔬 Diagnostic Scenarios

### Scenario A: Deduplication Function NOT Called

**Symptoms**: No log messages with "🔍" or "✅ Deduplication"

**Possible Causes**:
1. Code not compiled (flutter clean not done)
2. Wrong APK installed (old version)
3. Code optimization removed function

**Fix**:
```powershell
flutter clean
flutter pub get
flutter run --release
```

### Scenario B: IoU Calculation Returns 0

**Symptoms**: All IoU values = 0.0

**Possible Causes**:
1. Coordinates not overlapping (different boxes)
2. RectF coordinates invalid
3. Math error in computeIoU()

**Fix**: Check box coordinates in log

### Scenario C: Boxes Have Different Coordinates

**Symptoms**: IoU < 0.15 for supposedly duplicate boxes

**Log Example**:
```
Box[0]: xywh=[100, 200, 300, 400]
Box[1]: xywh=[150, 250, 350, 450]
IoU=0.12  ← Below threshold!
```

**This means**: Boxes are genuinely different (not duplicates)

**Root Cause**: Problem is in **native NMS** or **model inference**, not post-processing

---

## 🎯 Possible Root Causes

### 1. **Native NMS Outputs Same Box Twice** 🔥
```cpp
// In native-lib.cpp
// Bug: Same detection added twice to output array
results.push_back(box1);
results.push_back(box1);  // ← DUPLICATE!
```

**Evidence**: Identical confidence + coordinates

### 2. **Result Array Duplicated During Conversion**
```kotlin
// In ObjectDetector.kt
for (boxArray in resultBoxes) {
    boxes.add(createBox(boxArray))
    boxes.add(createBox(boxArray))  // ← BUG!
}
```

**Evidence**: Check loop structure

### 3. **Model Outputs Duplicate Anchors**
```
Model inference → 2 identical predictions
↓
Native NMS → Both pass (IoU check fails)
↓
Result → 2 boxes with same confidence
```

**Evidence**: Always same confidence

### 4. **Coordinate Transformation Creates Duplicate**
```kotlin
// Different normalized coords transform to same pixel coords
norm1 = (0.120, 0.340)  → pixel1 = (100, 200)
norm2 = (0.121, 0.341)  → pixel2 = (100, 200)  // Rounded!
```

**Evidence**: Check normalized vs pixel coordinates

---

## 🚀 Next Steps

### Step 1: Capture Full Log
```powershell
flutter clean
flutter pub get
flutter run
# Wait for camera to detect plates
adb logcat -d > full_debug.txt
```

### Step 2: Analyze Log

Look for:
```
=== DETECTION RESULTS (After Native NMS) ===
```

Check:
- How many detections from native?
- Are confidences identical?
- Are coordinates identical?

### Step 3: Check Deduplication

Look for:
```
🔍 === STARTING DEDUPLICATION PROCESS ===
```

Verify:
- Function is called?
- IoU values computed?
- Duplicates removed?

### Step 4: Determine Root Cause

| Evidence | Root Cause | Solution |
|----------|------------|----------|
| Native outputs 2, IoU > 0.15, removed by Kotlin | ✅ **Fix works!** | Done |
| Native outputs 2, IoU < 0.15, not removed | 🔴 Boxes genuinely different | Check native NMS |
| Native outputs 1, but UI shows 2 | 🔴 Flutter duplication | Check UI code |
| No deduplication logs | 🔴 Function not compiled | Rebuild clean |

---

## 📊 Success Criteria

### ✅ Fix is Working:
```
Detected: ~34 (was 68)  ← 50% reduction
Cropped: ~33 (was 65)   ← 50% reduction
Log shows: "✅ Deduplication complete: 2 → 1 boxes"
```

### ❌ Fix Not Working:
```
Detected: 68 (no change)
Cropped: 65 (no change)
Log shows: No deduplication messages OR IoU too low
```

---

## 📝 Checklist

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Capture logcat output
- [ ] Check for deduplication logs
- [ ] Verify IoU calculations
- [ ] Check box counts (before vs after)
- [ ] Test on physical device
- [ ] Verify UI shows only 1 box per plate

---

**Created**: October 22, 2025  
**Status**: Testing with enhanced logging  
**Next**: Analyze logcat output to determine root cause
