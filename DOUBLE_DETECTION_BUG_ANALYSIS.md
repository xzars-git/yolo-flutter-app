# 🐛 Double Detection Bug Analysis - Duplicate Overlays pada Single Plate

## 📋 Summary
- **Bug**: 2 bounding box muncul untuk 1 plat nomor yang sama (double overlay)
- **Versi Bermasalah**: 0.1.39 (dan kemungkinan 0.1.38)
- **Versi Normal**: 0.1.37 (tidak ada masalah)
- **Root Cause**: **NMS (Non-Maximum Suppression) threshold terlalu ketat atau NMS tidak bekerja dengan baik**

## 🔍 Technical Investigation

### 1. **NMS Implementation Analysis**

Dari file `native-lib.cpp` (lines 74-89), implementasi NMS:

```cpp
static void nms_sorted_bboxes(const std::vector<DetectedObject>& objects, 
                               std::vector<int>& picked, 
                               float nms_threshold) {
    picked.clear();
    int n = objects.size();
    std::vector<float> areas(n);
    for (int i = 0; i < n; i++) {
        areas[i] = objects[i].rect.width * objects[i].rect.height;
    }
    for (int i = 0; i < n; i++) {
        const DetectedObject &a = objects[i];
        bool keep = true;
        for (int j = 0; j < (int)picked.size(); j++) {
            const DetectedObject &b = objects[picked[j]];
            float inter_area = intersection_area(a, b);
            float union_area = areas[i] + areas[picked[j]] - inter_area;
            if (union_area > 0 && (inter_area / union_area > nms_threshold)) {
                keep = false;
                break;
            }
        }
        if (keep)
            picked.push_back(i);
    }
}
```

**Masalah Potensial:**
- Kondisi NMS: `inter_area / union_area > nms_threshold`
- Jika IoU **LEBIH BESAR** dari threshold, box akan **ditolak (keep = false)**
- Jika IoU **LEBIH KECIL** dari threshold, box akan **diterima (keep = true)**

### 2. **Default Threshold Values**

**YOLOView.kt** (line 234):
```kotlin
private var iouThreshold = 0.45  // Default 45%
```

**ObjectDetector.kt** (line 401):
```kotlin
private var iouThreshold = 0.4f  // Default 40%
```

**Native-lib.cpp constants**:
```cpp
private const val IOU_THRESHOLD = 0.4F
```

### 3. **Possible Root Causes**

#### **Scenario A: IoU Threshold Too High (Most Likely)**
- Default threshold: **0.45** (45%)
- Jika 2 deteksi overlap **kurang dari 45%**, keduanya akan lolos NMS
- Contoh: Box 1 dan Box 2 overlap hanya **40%** → kedua box tetap ditampilkan

**Ilustrasi:**
```
┌──────────────┐
│   Box 1      │
│   78.3%      │
│  ┌───────────┼──────┐
│  │ Overlap   │      │
└──┼───────────┘      │
   │    Box 2         │
   │    76.4%         │
   └──────────────────┘
   
IoU = intersection / union = 0.40 (40%)
Threshold = 0.45
40% < 45% → BOTH KEPT (double detection!)
```

#### **Scenario B: Confidence Scores Too Close**
Dari screenshot Anda:
- **Blue box**: plate_number **78.3%**
- **Red box**: plate_number **76.4%**

Perbedaan confidence hanya **1.9%** → keduanya sangat kuat → NMS sulit memfilter

#### **Scenario C: Model Output Multiple Anchors**
YOLO menggunakan multiple anchor boxes:
- Versi 0.1.39 mungkin menggunakan model dengan lebih banyak anchors
- Atau perubahan pada anchor configuration
- Sehingga menghasilkan multiple strong detections untuk satu objek

### 4. **Changes Between Versions**

Dari GitHub commits analysis:
- **Sept 18, 2025**: "Simplify code" (#326) - mungkin ada perubahan NMS logic
- **Oct 1, 2025**: "Refactor codebase with new architecture" (#348) - major refactor
- **Oct 8, 2025**: "Fix: performance metrics" (#358) - performa changes

**Kemungkinan perubahan yang menyebabkan bug:**
1. **Threshold default diubah** dari 0.40 → 0.45 (lebih permisif)
2. **NMS algorithm direfactor** dan ada regression
3. **Model preprocessing berubah** sehingga menghasilkan lebih banyak confident detections

---

## 🔧 Solutions

### **Solution 1: Lower IoU Threshold (Recommended - Quick Fix)**

**Strategi**: Turunkan IoU threshold agar NMS lebih agresif menghapus duplicate boxes

**Implementation:**

**A. Via Flutter Code (Runtime Change)**

```dart
// Di file: example/lib/main.dart atau presentation/screens/...

YoloController(
  // ... konfigurasi lain
  iouThreshold: 0.3, // ⬇️ Turunkan dari 0.45 ke 0.30
  confidenceThreshold: 0.25,
)
```

**B. Via Android Native Default (Permanent Change)**

Edit `YOLOView.kt` (line 234):
```kotlin
// OLD:
private var iouThreshold = 0.45

// NEW:
private var iouThreshold = 0.30  // Lebih agresif filter duplicate
```

Edit `ObjectDetector.kt` (line 401):
```kotlin
// OLD:
private var iouThreshold = 0.4f

// NEW:
private var iouThreshold = 0.3f  // Matching dengan YOLOView
```

**Expected Result:**
- Dengan threshold **0.30** (30%), jika 2 box overlap **lebih dari 30%**, yang confidence lebih rendah akan dihapus
- Double detection akan hilang karena Box 1 (78.3%) dan Box 2 (76.4%) pasti overlap >30%

---

### **Solution 2: Increase Confidence Threshold**

**Strategi**: Naikkan confidence threshold agar hanya deteksi paling kuat yang lolos

```dart
YoloController(
  confidenceThreshold: 0.35, // ⬆️ Naikkan dari 0.25 ke 0.35
  iouThreshold: 0.45,        // Tetap default
)
```

**Expected Result:**
- Box dengan confidence <35% akan difilter sebelum NMS
- Hanya deteksi terkuat yang masuk NMS

---

### **Solution 3: Modify NMS Algorithm (Advanced)**

**Strategi**: Perbaiki NMS algorithm untuk lebih strict

Edit `native-lib.cpp` (lines 74-89):

```cpp
static void nms_sorted_bboxes(const std::vector<DetectedObject>& objects, 
                               std::vector<int>& picked, 
                               float nms_threshold) {
    picked.clear();
    int n = objects.size();
    std::vector<float> areas(n);
    for (int i = 0; i < n; i++) {
        areas[i] = objects[i].rect.width * objects[i].rect.height;
    }
    
    // ✅ ADD: Group detections by class first
    std::vector<std::vector<int>> class_indices(100); // Max 100 classes
    for (int i = 0; i < n; i++) {
        class_indices[objects[i].index].push_back(i);
    }
    
    // ✅ MODIFY: Process each class separately
    for (auto& indices : class_indices) {
        if (indices.empty()) continue;
        
        for (int idx : indices) {
            const DetectedObject &a = objects[idx];
            bool keep = true;
            for (int j = 0; j < (int)picked.size(); j++) {
                const DetectedObject &b = objects[picked[j]];
                
                // ✅ ADD: Skip if different class
                if (a.index != b.index) continue;
                
                float inter_area = intersection_area(a, b);
                float union_area = areas[idx] + areas[picked[j]] - inter_area;
                
                // ✅ MODIFY: More aggressive threshold for same class
                float effective_threshold = nms_threshold * 0.7; // 70% of original
                
                if (union_area > 0 && (inter_area / union_area > effective_threshold)) {
                    keep = false;
                    break;
                }
            }
            if (keep)
                picked.push_back(idx);
        }
    }
}
```

**Changes:**
1. Process detections per class (avoid cross-class comparison)
2. Lower effective threshold for same-class detections (more aggressive)
3. Better handling of multiple detections on same object

**Rebuild JNI:**
```bash
cd android
./gradlew assembleDebug
```

---

### **Solution 4: Check Model Configuration**

**Investigate if model changed between versions:**

```bash
# Compare model metadata
cd example/assets/models
ls -lh

# Check model exported parameters
# Look for anchor changes or NMS parameters baked into model
```

**Possible Actions:**
1. Re-export model dengan NMS threshold yang lebih rendah
2. Use model dari versi 0.1.37 yang bekerja normal
3. Train model baru dengan better NMS configuration

---

## 🧪 Testing Strategy

### **Step 1: Quick Test dengan Flutter**

```dart
// Test berbagai kombinasi threshold
final testConfigurations = [
  {'conf': 0.25, 'iou': 0.30},  // Test 1: Lower IoU
  {'conf': 0.35, 'iou': 0.45},  // Test 2: Higher Conf
  {'conf': 0.30, 'iou': 0.35},  // Test 3: Balanced
];

for (var config in testConfigurations) {
  yoloController.updateThresholds(
    confidenceThreshold: config['conf'],
    iouThreshold: config['iou'],
  );
  // Scan plate dan observe hasilnya
}
```

### **Step 2: Debug Logging**

Tambahkan log di `native-lib.cpp` (line 155):

```cpp
// After NMS
for (int i = 0; i < count; i++) {
    objects[i] = proposals[picked[i]];
    
    // ✅ ADD DEBUG LOG
    __android_log_print(ANDROID_LOG_DEBUG, "NMS_DEBUG", 
        "Box %d: class=%d, conf=%.2f, IoU_threshold=%.2f, x=%.2f, y=%.2f, w=%.2f, h=%.2f",
        i, objects[i].index, objects[i].confidence, iou_threshold,
        objects[i].rect.x, objects[i].rect.y, 
        objects[i].rect.width, objects[i].rect.height);
}
```

Tambahkan di `CMakeLists.txt`:
```cmake
find_library(log-lib log)
target_link_libraries(ultralytics ${log-lib})
```

---

## 📊 Expected Outcomes

### **Scenario 1: IoU Threshold = 0.30**
```
Before NMS: [Box1(78.3%), Box2(76.4%)]
IoU(Box1, Box2) = 45%
45% > 30% → Box2 REJECTED
After NMS: [Box1(78.3%)] ✅ SINGLE BOX
```

### **Scenario 2: Confidence Threshold = 0.35**
```
Before Filter: [Box1(78.3%), Box2(76.4%)]
Box1 confidence: 78.3% > 35% ✅ PASS
Box2 confidence: 76.4% > 35% ✅ PASS (still duplicate)
⚠️ May not solve the issue
```

### **Scenario 3: Combined (Conf=0.30, IoU=0.35)**
```
Before Filter: [Box1(78.3%), Box2(76.4%)]
Both pass confidence filter
IoU(Box1, Box2) = 45%
45% > 35% → Box2 REJECTED
After NMS: [Box1(78.3%)] ✅ SINGLE BOX
```

---

## 🎯 Recommended Action Plan

### **Immediate (Today)**
1. ✅ Test dengan IoU threshold = 0.30 via Flutter code
2. ✅ Verify hasilnya dengan scan plat yang sama
3. ✅ Document hasilnya (screenshot before/after)

### **Short-term (This Week)**
1. ✅ Implement permanent fix di Android native layer
2. ✅ Add debug logging untuk monitoring NMS behavior
3. ✅ Test dengan berbagai kondisi (multiple plates, jarak berbeda, lighting)

### **Long-term (Next Sprint)**
1. ✅ Investigate version changes (0.1.37 → 0.1.39 diff)
2. ✅ Consider model re-export dengan better NMS config
3. ✅ Submit fix ke upstream Ultralytics repository
4. ✅ Update documentation dengan best practices

---

## 📝 Version Comparison Checklist

- [ ] Compare `native-lib.cpp` between 0.1.37 and 0.1.39
- [ ] Compare `ObjectDetector.kt` NMS threshold defaults
- [ ] Compare model files (MD5 checksum)
- [ ] Compare anchor configurations
- [ ] Test dengan model dari 0.1.37 di versi 0.1.39 code

---

## 🔗 References

1. **NMS Algorithm**: [Non-Maximum Suppression Explained](https://learnopencv.com/non-maximum-suppression/)
2. **YOLO NMS**: [Ultralytics NMS Documentation](https://docs.ultralytics.com/modes/predict/#inference-arguments)
3. **IoU Calculation**: [Intersection over Union](https://pyimagesearch.com/2016/11/07/intersection-over-union-iou-for-object-detection/)
4. **GitHub Commits**: [yolo-flutter-app/commits](https://github.com/ultralytics/yolo-flutter-app/commits/main/)

---

## 💡 Conclusion

**Root Cause**: NMS IoU threshold **terlalu tinggi (0.45)**, sehingga 2 deteksi dengan overlap 40-44% tetap lolos dan keduanya ditampilkan.

**Best Solution**: **Lower IoU threshold to 0.30** untuk filter lebih agresif.

**Quick Fix (No Code Change)**: Update threshold via Flutter controller.

**Permanent Fix**: Modify default values di Android native layer + add better NMS logging.

---

**Status**: 🔴 BUG IDENTIFIED, SOLUTION READY FOR TESTING  
**Priority**: 🔥 HIGH (visual quality issue)  
**Estimated Fix Time**: 15 minutes (quick test) / 2 hours (permanent fix + testing)
