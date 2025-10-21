# 🎯 Action Plan: Testing & Validation

## 📋 Quick Summary

**Status**: Bug analysis complete ✅ | Fix implemented ✅ | Testing needed 🔄

**Bug**: Double detection (2 boxes for 1 license plate)
- **Cause**: Package-level regression in v0.1.38 (Architecture refactor PR #348)
- **Working version**: v0.1.37
- **Broken versions**: v0.1.38, v0.1.39

**Our Fix**:
1. ✅ Class-aware NMS (skip different classes)
2. ✅ Aggressive IoU threshold (0.45 → 0.20)
3. ✅ Comprehensive debug logging

---

## 🚀 Step-by-Step Testing Guide

### Step 1: Build & Run App

```powershell
# Navigate to example folder
cd "d:\Bapenda New\explore\yolo-flutter-app\example"

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Run on connected device
flutter run
```

**Expected output**: App launches with camera view

---

### Step 2: Monitor Logcat Output

Open **NEW TERMINAL** window and run:

```powershell
adb logcat -s NMS_DEBUG:D YOLOView:D ObjectDetector:D
```

**Alternative (filtered)**:
```powershell
adb logcat | Select-String -Pattern "PROPOSAL|NMS|DETECTION|WARNING"
```

---

### Step 3: Test Single License Plate

1. Point camera at **single license plate**
2. Wait for detection (green box should appear)
3. Check terminal for log output

**✅ EXPECTED LOG (Success)**:
```
=== PROPOSAL EXTRACTION: w=8400, h=84, classes=1, conf_thresh=0.250 ===
  Proposal[0]: cls=0, conf=0.783, x=123.4, y=456.7, w=89.0, h=45.0
  Proposal[1]: cls=0, conf=0.764, x=125.2, y=458.1, w=88.5, h=44.8
=== TOTAL PROPOSALS BEFORE NMS: 2 ===

=== NMS START: 2 objects, threshold=0.200 ===
  Checking Box[0]: cls=0, conf=0.783
  ✅ Box[0] KEPT (cls=0, conf=0.783)
  
  Checking Box[1]: cls=0, conf=0.764
  📏 Box[1] vs Box[0]: IoU=0.420
  ❌ Box[1] SUPPRESSED (IoU=0.420 > threshold=0.200)
  
=== NMS END: 1/2 boxes kept ===

=== BITMAP & RESULT DEBUG ===
ImageProxy size: 480x640
Bitmap size: 480x640
Result origShape: 640x480
Device orientation: PORTRAIT

=== FINAL DETECTION RESULTS ===
Total boxes after NMS: 1
IoU Threshold: 0.2
Confidence Threshold: 0.25
```

**❌ FAILED LOG (Bug still present)**:
```
=== FINAL DETECTION RESULTS ===
Total boxes after NMS: 2
⚠️ WARNING: Multiple boxes detected (2)
  Box[0]: cls=plate_number, conf=0.783, xywh=[...]
  Box[1]: cls=plate_number, conf=0.764, xywh=[...]
```

---

### Step 4: Verify Visual Output

**✅ SUCCESS**: 
- Camera shows **1 bounding box** around license plate
- Label shows single confidence (e.g., "plate_number 78.3%")

**❌ FAILURE**:
- Camera shows **2 overlapping bounding boxes**
- Two labels visible with different confidences

---

### Step 5: Test Multiple Scenarios

#### Scenario A: Close License Plate
- Move closer (fill ~50% of screen)
- Expected: 1 box, high confidence (>70%)

#### Scenario B: Far License Plate
- Move farther (fill ~10% of screen)
- Expected: 1 box, lower confidence (~50-60%)

#### Scenario C: Angled Plate
- Tilt phone or plate at 30-45 degrees
- Expected: 1 box, moderate confidence (~60-70%)

#### Scenario D: Multiple Plates
- Show 2 separate license plates (well-separated)
- Expected: 2 boxes (1 per plate, correct behavior)

#### Scenario E: Overlapping Plates
- Show 2 plates close together (partial overlap)
- Expected: 2 boxes if different plates, 1 box if same plate

---

## 📊 Interpretation Guide

### Case 1: Fix Successful (1 Box Detected)

**Log shows**:
```
TOTAL PROPOSALS: 2
NMS: 2 → 1 (1 suppressed)
Output: 1 box
```

**Actions**:
1. ✅ Confirm fix works
2. 🎚️ Consider adjusting threshold from 0.20 → 0.30 (less aggressive)
3. 🗑️ Remove verbose logging for production
4. 📝 Document in CHANGELOG
5. 🐛 Optional: Submit PR to Ultralytics

**Optimization test**:
```kotlin
// Try gradually increasing threshold
private var iouThreshold = 0.25  // Test 1
private var iouThreshold = 0.30  // Test 2
private var iouThreshold = 0.35  // Test 3
```

Find the **highest value** that still prevents double detection.

---

### Case 2: Fix Failed (2 Boxes Still Appear)

**Log shows**:
```
TOTAL PROPOSALS: 2
NMS: 2 → 2 (none suppressed)
Output: 2 boxes ❌
```

**Possible causes**:

#### A. IoU Below Threshold
```
Box[1] vs Box[0]: IoU=0.15 < 0.20 → KEPT
```

**Solution**: Lower threshold further
```kotlin
private var iouThreshold = 0.15  // More aggressive
```

#### B. Different Classes Detected
```
Box[0]: cls=0 (plate_number)
Box[1]: cls=1 (different_class)
```

**Solution**: This is correct behavior if truly different classes. Check model labels.

#### C. Spatial Clustering Issue
```
Box[0]: x=100, y=200
Box[1]: x=500, y=600  (far apart)
```

**Solution**: Not overlapping spatially, NMS correctly keeps both. May need different approach.

---

### Case 3: Too Few Proposals

**Log shows**:
```
TOTAL PROPOSALS: 0
Output: No detections ❌
```

**Possible causes**:
- Confidence threshold too high (0.25)
- Model not loading correctly
- Camera image not reaching inference

**Solution**:
```kotlin
// Lower confidence threshold temporarily
private var confidenceThreshold = 0.15
```

---

## 🔍 Advanced Debugging

### Check Proposal Details

If double detection persists, analyze proposal coordinates:

```
Proposal[0]: cls=0, conf=0.783, x=123.4, y=456.7, w=89.0, h=45.0
Proposal[1]: cls=0, conf=0.764, x=125.2, y=458.1, w=88.5, h=44.8
```

**Calculate IoU manually**:
```
Box A: [123.4, 456.7, 212.4, 501.7]  (x1, y1, x2, y2)
Box B: [125.2, 458.1, 213.7, 502.9]

Intersection: [125.2, 458.1, 212.4, 501.7]
  Width:  212.4 - 125.2 = 87.2
  Height: 501.7 - 458.1 = 43.6
  Area:   87.2 * 43.6 = 3,801.92

Box A Area: 89.0 * 45.0 = 4,005
Box B Area: 88.5 * 44.8 = 3,964.8

Union: 4,005 + 3,964.8 - 3,801.92 = 4,167.88

IoU: 3,801.92 / 4,167.88 = 0.912 (91.2% overlap!)
```

**If IoU > 0.90**: Boxes are nearly identical, should be suppressed by any reasonable threshold.

**If IoU < 0.20**: Boxes are different objects or different parts, may need spatial analysis.

---

## 📝 Results Logging Template

Copy this template and fill in your test results:

```markdown
## Test Results - [DATE]

### Environment
- Device: [e.g., Samsung Galaxy S21]
- Android Version: [e.g., Android 12]
- App Version: ultralytics_yolo v0.1.39 (custom)
- Model: [e.g., yolo11n.tflite]

### Test 1: Single License Plate (Close)
- Visual: [ ] 1 box ✅ | [ ] 2 boxes ❌
- Proposals: ___ boxes before NMS
- After NMS: ___ boxes
- IoU value: ___
- Confidence: ___ / ___
- Status: [ ] PASS | [ ] FAIL

### Test 2: Single License Plate (Far)
- Visual: [ ] 1 box ✅ | [ ] 2 boxes ❌
- Proposals: ___ boxes before NMS
- After NMS: ___ boxes
- IoU value: ___
- Confidence: ___ / ___
- Status: [ ] PASS | [ ] FAIL

### Test 3: Angled License Plate
- Visual: [ ] 1 box ✅ | [ ] 2 boxes ❌
- Proposals: ___ boxes before NMS
- After NMS: ___ boxes
- IoU value: ___
- Confidence: ___ / ___
- Status: [ ] PASS | [ ] FAIL

### Test 4: Multiple Plates (Separated)
- Visual: [ ] 2 boxes ✅ | [ ] Other ❌
- Proposals: ___ boxes before NMS
- After NMS: ___ boxes
- Status: [ ] PASS | [ ] FAIL

### Test 5: Overlapping Plates
- Visual: [ ] Expected | [ ] Unexpected
- Proposals: ___ boxes before NMS
- After NMS: ___ boxes
- Status: [ ] PASS | [ ] FAIL

### Overall Status
- [ ] ✅ Fix successful - all tests pass
- [ ] ⚠️ Partial success - some tests fail
- [ ] ❌ Fix failed - double detection persists

### Log Sample
```
[Paste relevant log output here]
```

### Next Actions
1. [ ] [Action 1]
2. [ ] [Action 2]
```

---

## 🎯 Success Criteria

### Minimum Viable Fix
- [x] Class-aware NMS implemented
- [x] IoU threshold lowered
- [x] Debug logging added
- [ ] **Single box for single object** ← PRIMARY GOAL
- [ ] No false negatives (missing detections)

### Optimal Fix
- [ ] Single box for single object ✅
- [ ] Threshold optimized (0.25-0.35 range)
- [ ] Verbose logging removed
- [ ] Performance validated (>20 FPS)
- [ ] Works across all test scenarios

### Production Ready
- [ ] All tests pass ✅
- [ ] Performance acceptable ✅
- [ ] Code cleaned up ✅
- [ ] Documentation updated ✅
- [ ] Changelog updated ✅
- [ ] Ready for upstream PR (optional)

---

## 🔧 Quick Fixes Reference

### If IoU Too Low (0.20 not enough)
```kotlin
// android/src/main/kotlin/.../YOLOView.kt
private var iouThreshold = 0.15  // Try 0.15

// android/src/main/kotlin/.../ObjectDetector.kt
private var iouThreshold = 0.15f  // Try 0.15f
```

### If Too Aggressive (missing valid boxes)
```kotlin
// Raise threshold
private var iouThreshold = 0.30  // Try 0.30
private var iouThreshold = 0.3f  // Try 0.3f
```

### If Confidence Too High (no detections)
```kotlin
// YOLOView.kt
private var confidenceThreshold = 0.20  // Lower from 0.25
```

### Disable Verbose Logging (for production)
```cpp
// android/src/main/cpp/native-lib.cpp
// Comment out all LOGD lines or set log level higher
#define LOGD(...)  // Disable all debug logs
```

---

## 📞 Support & Resources

### Documentation Created
1. `VERSION_COMPARISON_ANALYSIS.md` - Full technical analysis (English)
2. `RINGKASAN_ANALISIS_BUG_INDONESIA.md` - Summary in Indonesian
3. `DOUBLE_DETECTION_COMPREHENSIVE_FIX.md` - Fix implementation guide
4. This file: `ACTION_PLAN_TESTING.md` - Testing guide

### GitHub Resources
- Ultralytics YOLO Flutter: https://github.com/ultralytics/yolo-flutter-app
- v0.1.37 (working): https://github.com/ultralytics/yolo-flutter-app/releases/tag/v0.1.37
- v0.1.38 (regression): https://github.com/ultralytics/yolo-flutter-app/releases/tag/v0.1.38
- PR #348 (cause): https://github.com/ultralytics/yolo-flutter-app/pull/348

### Need Help?
If testing reveals unexpected results:
1. Save complete Logcat output to file
2. Take screenshot of visual issue
3. Note device model and Android version
4. Share results for further analysis

---

## ⚡ Quick Start Command

**All-in-one testing command** (PowerShell):

```powershell
# Terminal 1: Build and run
cd "d:\Bapenda New\explore\yolo-flutter-app\example"
flutter clean; flutter pub get; flutter run

# Terminal 2: Monitor logs (run after app launches)
adb logcat -s NMS_DEBUG:D YOLOView:D | Select-String -Pattern "PROPOSAL|NMS|DETECTION|WARNING|ERROR"
```

---

**Status**: Ready for Testing 🚀
**Last Updated**: October 21, 2025
**Next Step**: Execute Step 1 above
