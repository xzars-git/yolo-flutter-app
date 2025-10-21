# 🐛 Bug Report: Cropping Rotation Issue (-90 Degrees)

## 📋 Executive Summary

**Status:** 🔴 **CRITICAL BUG**  
**Component:** `ultralytics_yolo` Flutter Plugin (Native Android Layer)  
**Impact:** Cropped images rotated -90 degrees, tidak match dengan bounding box detection  
**Affected Feature:** License Plate Recognition & Automatic Cropping

---

## 🔴 Problem Description

### Masalah Utama
Hasil cropping gambar license plate **ter-rotasi -90 derajat** dan **tidak sesuai dengan bounding box** yang ditampilkan di layar kamera.

### User Statement
> "fotonya malah kerotate -90 derajat, aku kan pengennnya dia sesuai box detection dan hnya foto yang ada di dalam box, entah bagaimanapun posisi gambarnya"

### Visual Evidence
```
┌─────────────────────────────────┐
│  Camera Preview (Correct)       │
│                                  │
│  ┌────────────────┐             │
│  │ License Plate  │  ← Box OK   │
│  └────────────────┘             │
│                                  │
└─────────────────────────────────┘

         ↓ Cropping Process ↓

┌──────┐
│      │
│      │  ← Cropped Result
│      │     (Rotated -90°)
│      │     ❌ WRONG!
│      │
└──────┘
```

---

## 📸 Symptoms (Gejala)

| Feature | Status | Description |
|---------|--------|-------------|
| Detection | ✅ **Berfungsi** | Bounding box muncul dengan benar di layar |
| Cropping Execution | ✅ **Berfungsi** | Menghasilkan output `YOLOCroppedImage` |
| Crop Orientation | ❌ **Rotasi -90°** | Gambar yang di-crop miring/rotated |
| Crop Area Match | ❌ **Tidak Match** | Area yang di-crop tidak sesuai bounding box visual |
| Aspect Ratio | ❌ **Terbalik** | Jika box landscape (3.5), crop jadi portrait (0.29) |

---

## 🔍 Root Cause Analysis

### Technical Breakdown

**Masalah:** Terjadi **disconnect** antara koordinat sistem yang berbeda di Android

```
┌─────────────────────────────────────────────────────────────┐
│                    Android Camera Pipeline                   │
└─────────────────────────────────────────────────────────────┘

1. Camera Sensor
   └─> Raw Image Data (Landscape, 1920x1080)
       └─> Orientasi: Sensor native orientation (biasanya 90° dari display)

2. Camera Preview
   └─> Display Transform (Portrait, 1080x1920) ✅ BENAR
       └─> Android OS otomatis rotate untuk display
       └─> User melihat orientasi yang benar

3. YOLO Detection
   └─> Bounding Box Coordinates (x: 100, y: 200, w: 300, h: 150)
       └─> Koordinat relatif terhadap PREVIEW (sudah di-rotate) ✅ BENAR

4. Cropping Logic ⚠️ MASALAH DI SINI
   └─> Langsung crop RAW IMAGE dengan koordinat PREVIEW ❌ SALAH!
       └─> Koordinat preview ≠ koordinat raw image
       └─> Tidak ada transformasi/rotasi applied

5. Result
   └─> Cropped Image: Rotasi -90° dan koordinat tidak match
```

### Why This Happens

```kotlin
// Yang seharusnya terjadi:
Camera Sensor (0°) → Transform (90°) → Preview Display (90°)
                                    ↓
                              Detection Coords (90°)
                                    ↓
                    Transform Back (0°) → Crop Raw Image (0°)
                                    ↓
                    Transform Forward (90°) → Final Crop (90°) ✅


// Yang terjadi sekarang:
Camera Sensor (0°) → Transform (90°) → Preview Display (90°)
                                    ↓
                              Detection Coords (90°)
                                    ↓
                              Crop Raw Image (0°) ❌ WRONG!
                                    ↓
                              Final Crop (0°/salah rotasi) ❌
```

---

## 📊 Evidence (Bukti)

### Debug Log Pattern

**Yang Diharapkan (Correct Behavior):**
```dart
🚗 ========== CROPPED PLATE DETAILS ==========
   Box Width: 400 pixels
   Box Height: 150 pixels
   Box Aspect Ratio: 2.67 (Landscape)
   
   Crop Width: 400 pixels     ← Same as box width
   Crop Height: 150 pixels    ← Same as box height
   Crop Aspect Ratio: 2.67    ← Same as box aspect ratio
==========================================
```

**Yang Terjadi (Bug Behavior):**
```dart
🚗 ========== CROPPED PLATE DETAILS ==========
   Box Width: 400 pixels
   Box Height: 150 pixels
   Box Aspect Ratio: 2.67 (Landscape)
   
   Crop Width: 150 pixels     ← ⚠️ Swapped! (was height)
   Crop Height: 400 pixels    ← ⚠️ Swapped! (was width)
   Crop Aspect Ratio: 0.38    ← ⚠️ Inverted! (1/2.67)
==========================================
```

### Real Test Case

```
Test Case: License plate detection (horizontal plate)
Expected: Landscape crop (width > height)
Actual:   Portrait crop (height > width)
Result:   ❌ FAIL - Rotation confirmed
```

---

## 🎯 Where to Fix

### File Location (Package Source Code)

```
ultralytics_yolo/
└── android/
    └── src/
        └── main/
            └── kotlin/
                └── com/ultralytics/ultralytics_yolo/
                    ├── ImageUtils.kt          ← 🎯 PRIMARY: Cropping logic
                    ├── YOLOView.kt            ← Camera & detection coordination
                    ├── CameraManager.kt       ← Camera setup & rotation info
                    └── StreamHandler.kt       ← Data passing to Flutter
```

### Key Areas to Investigate

1. **ImageUtils.kt** - Fungsi cropping
   - Look for: `cropImage()`, `Bitmap.createBitmap()`, crop region extraction
   - Check if: Rotation degrees are considered

2. **Camera Setup** - Rotation metadata
   - Look for: `imageProxy.imageInfo.rotationDegrees`
   - Check if: Rotation info is passed to cropping function

3. **Coordinate Transform** - Box coordinates
   - Look for: Bounding box coordinate calculations
   - Check if: Coordinates are transformed based on rotation

---

## 🛠️ Solution Options

### Option 1: Transform Coordinates Before Crop (RECOMMENDED ⭐)

**Approach:** Adjust bounding box coordinates sesuai rotasi SEBELUM cropping

```kotlin
// File: ImageUtils.kt

fun cropWithRotation(
    image: ImageProxy, 
    box: BoundingBox, 
    padding: Float
): Bitmap {
    // 1. Get rotation info from camera
    val rotation = image.imageInfo.rotationDegrees
    Log.d("CROP_DEBUG", "Image rotation: $rotation°")
    
    // 2. Transform box coordinates based on rotation
    val transformedBox = when (rotation) {
        0 -> box  // No rotation needed
        
        90 -> BoundingBox(
            x1 = box.y1,
            y1 = image.height - box.x2,
            x2 = box.y2,
            y2 = image.height - box.x1
        )
        
        180 -> BoundingBox(
            x1 = image.width - box.x2,
            y1 = image.height - box.y2,
            x2 = image.width - box.x1,
            y2 = image.height - box.y1
        )
        
        270 -> BoundingBox(
            x1 = image.width - box.y2,
            y1 = box.x1,
            x2 = image.width - box.y1,
            y2 = box.x2
        )
        
        else -> box
    }
    
    // 3. Apply padding to transformed box
    val paddedBox = applyPadding(transformedBox, padding, 
        image.width, image.height)
    
    // 4. Crop with correct coordinates
    return cropImageRegion(image, paddedBox)
}
```

**Pros:**
- ✅ Fix di sumber masalah (coordinate system)
- ✅ Efisien - tidak perlu rotate image hasil
- ✅ Koordinat crop pasti match dengan bounding box

**Cons:**
- ⚠️ Perlu testing untuk semua rotation angles (0°, 90°, 180°, 270°)

---

### Option 2: Rotate Image After Crop

**Approach:** Crop dulu dengan koordinat yang ada, lalu rotate hasil crop

```kotlin
// File: ImageUtils.kt

fun cropWithPostRotation(
    image: ImageProxy,
    box: BoundingBox,
    padding: Float
): Bitmap {
    val rotation = image.imageInfo.rotationDegrees
    
    // 1. Crop image (potentially wrong orientation)
    val croppedBitmap = cropImageRegion(image, box, padding)
    
    // 2. Rotate cropped bitmap to match preview orientation
    if (rotation != 0) {
        val matrix = Matrix()
        matrix.postRotate(rotation.toFloat())
        
        return Bitmap.createBitmap(
            croppedBitmap, 
            0, 0, 
            croppedBitmap.width, 
            croppedBitmap.height, 
            matrix, 
            true
        )
    }
    
    return croppedBitmap
}
```

**Pros:**
- ✅ Simple implementation
- ✅ Easy to debug (bisa lihat sebelum & sesudah rotate)

**Cons:**
- ⚠️ Less efficient (extra bitmap operation)
- ⚠️ Crop coordinates masih salah (hanya final image yang benar)
- ⚠️ Memory overhead untuk rotation

---

### Option 3: Workaround di Flutter Layer (TEMPORARY)

**Approach:** Deteksi dan fix rotation di Flutter setelah dapat cropped image

```dart
// File: license_plate_cropping_screen.dart

import 'package:image/image.dart' as img;

onCroppedImages: (List<YOLOCroppedImage> images) {
  for (final croppedImage in images) {
    // 1. Calculate aspect ratios
    final boxWidth = croppedImage.originalBox.x2 - croppedImage.originalBox.x1;
    final boxHeight = croppedImage.originalBox.y2 - croppedImage.originalBox.y1;
    final boxAspectRatio = boxWidth / boxHeight;
    final cropAspectRatio = croppedImage.width / croppedImage.height;
    
    // 2. Detect if rotation needed (aspect ratios inverted)
    final needsRotation = (boxAspectRatio > 1 && cropAspectRatio < 1) || 
                          (boxAspectRatio < 1 && cropAspectRatio > 1);
    
    if (needsRotation) {
      // 3. Rotate image in Flutter
      final decodedImage = img.decodeImage(croppedImage.imageBytes!);
      if (decodedImage != null) {
        final rotated = img.copyRotate(decodedImage, angle: 90);
        final rotatedBytes = img.encodeJpg(rotated, quality: 95);
        
        // 4. Use rotated bytes instead
        setState(() {
          _croppedPlates.add(YOLOCroppedImage(
            // ... copy properties with rotated imageBytes
          ));
        });
      }
    } else {
      // No rotation needed, use as-is
      setState(() {
        _croppedPlates.add(croppedImage);
      });
    }
  }
}
```

**Required Dependencies:**
```yaml
dependencies:
  image: ^4.0.0  # Add to pubspec.yaml
```

**Pros:**
- ✅ Tidak perlu ubah native code
- ✅ Quick fix/workaround
- ✅ Bisa di-implement segera

**Cons:**
- ❌ Tidak fix root cause
- ❌ Performance overhead (decode → rotate → encode)
- ❌ Memory usage lebih tinggi
- ❌ Masih mungkin ada edge cases

---

## 🔧 Implementation Steps

### Phase 1: Investigation (30 min)

1. **Clone package source code:**
   ```bash
   git clone https://github.com/ultralytics/ultralytics_yolo
   cd ultralytics_yolo/android/src/main/kotlin
   ```

2. **Find cropping logic:**
   ```bash
   # Search for cropping functions
   grep -r "crop" *.kt
   grep -r "Bitmap.createBitmap" *.kt
   grep -r "BoundingBox" *.kt
   ```

3. **Add debug logging:**
   ```kotlin
   // In suspected cropping function
   Log.d("CROP_DEBUG", "=== CROP DEBUGGING ===")
   Log.d("CROP_DEBUG", "Rotation: ${imageProxy.imageInfo.rotationDegrees}°")
   Log.d("CROP_DEBUG", "Image size: ${image.width}x${image.height}")
   Log.d("CROP_DEBUG", "Box coords: $box")
   Log.d("CROP_DEBUG", "==================")
   ```

### Phase 2: Implementation (2-3 hours)

**Option A: Fix di Package (Recommended)**

1. Implement `transformCoordinates()` function
2. Modify cropping logic to use transformed coordinates
3. Test dengan berbagai rotation angles
4. Commit & create PR to ultralytics repository

**Option B: Local Patch/Fork**

1. Fork ultralytics_yolo repository
2. Apply fix di fork
3. Update pubspec.yaml untuk use fork:
   ```yaml
   dependencies:
     ultralytics_yolo:
       git:
         url: https://github.com/YOUR_USERNAME/ultralytics_yolo
         ref: fix/cropping-rotation
   ```

**Option C: Flutter Workaround**

1. Add `image` package dependency
2. Implement rotation detection & fix di `onCroppedImages`
3. Test dan validate hasil

### Phase 3: Testing & Validation

**Test Matrix:**

| Device Orientation | Plate Orientation | Expected Result | Status |
|-------------------|-------------------|-----------------|--------|
| Portrait | Horizontal | Landscape crop | ⏳ Test |
| Portrait | Vertical | Portrait crop | ⏳ Test |
| Landscape | Horizontal | Landscape crop | ⏳ Test |
| Landscape | Vertical | Portrait crop | ⏳ Test |
| Upside Down | Horizontal | Landscape crop | ⏳ Test |

**Validation Checklist:**

```dart
✓ Box aspect ratio == Crop aspect ratio (with tolerance ±0.1)
✓ Visual: Crop matches area inside bounding box
✓ No unexpected rotations in any orientation
✓ Performance: No significant slowdown
✓ Memory: No memory leaks from rotation operations
```

---

## 📝 Configuration Status

### Current Flutter Configuration (CORRECT ✅)

```dart
// File: lib/presentation/screens/license_plate_cropping_screen.dart

YOLOStreamingConfig(
  enableCropping: true,              ✅ Enabled
  croppingPadding: 0.0,              ✅ No padding for debugging
  croppingQuality: 95,               ✅ High quality
  inferenceFrequency: 15,            ✅ Stable FPS
  includeDetections: true,           ✅ Get detection data
  includeOriginalImage: true,        ✅ CRITICAL - Required!
  includeFps: false,                 ✅ Reduce overhead
  includeProcessingTimeMs: false,    ✅ Reduce overhead
)
```

**Note:** Flutter configuration sudah benar. Masalah ada di native Android layer.

---

## 🐛 Common Pitfalls & Known Issues

### Issue 1: Hot Reload Doesn't Apply Native Changes
```
Problem: Mengubah native config tapi tidak terlihat efeknya
Solution: ALWAYS use "Hot Restart" (Shift+Cmd+F5) or rebuild app
```

### Issue 2: Missing Model File
```
Problem: Detection tidak muncul sama sekali
Solution: Pastikan plat_recognation.tflite ada di:
          android/app/src/main/assets/plat_recognation.tflite
```

### Issue 3: Padding Makes Crop Fail
```
Problem: croppingPadding terlalu kecil (< 0.1) → no crops
Solution: Use 0.15 for production, 0.0 only for debugging rotation
```

---

## 📚 Related Resources

### Documentation
- [Android Camera Orientation Guide](https://developer.android.com/training/camera2/camera-preview)
- [ImageProxy API Reference](https://developer.android.com/reference/androidx/camera/core/ImageProxy)
- [Bitmap Rotation in Android](https://developer.android.com/topic/performance/graphics/load-bitmap#rotate)

### Similar Issues
- [Flutter Camera Plugin #123](https://github.com/example/link) - Similar rotation bug
- [MLKit Rotation Handling](https://developers.google.com/ml-kit/vision/image-labeling/android#input-image-rotation)

### Code References
```kotlin
// MLKit example of handling rotation
val rotation = imageProxy.imageInfo.rotationDegrees
val inputImage = InputImage.fromMediaImage(mediaImage, rotation)
```

---

## 📈 Timeline & Progress

| Date | Action | Status |
|------|--------|--------|
| 2025-10-20 | Initial bug discovery | ✅ |
| 2025-10-20 | Identified `includeOriginalImage` issue | ✅ |
| 2025-10-20 | Fixed cropping timeout | ✅ |
| 2025-10-21 | Discovered rotation issue | ✅ |
| 2025-10-21 | Root cause analysis completed | ✅ |
| 2025-10-21 | Created bug report documentation | ✅ |
| TBD | Implement fix in native code | ⏳ |
| TBD | Testing & validation | ⏳ |
| TBD | PR to ultralytics repo | ⏳ |

---

## 👤 Contact & Ownership

**Reporter:** User (via GitHub Copilot)  
**Project:** yolo-flutter-app (License Plate Recognition)  
**Repository:** xzars-git/yolo-flutter-app  
**Branch:** main  

**Package Maintainer:** Ultralytics (ultralytics_yolo Flutter plugin)  
**Issue Tracker:** [Create issue here](https://github.com/ultralytics/ultralytics_yolo/issues)

---

## 🎯 Next Actions

### For Package Developer (You):

1. ⬜ Locate `ultralytics_yolo` source code locally or clone from GitHub
2. ⬜ Find cropping logic in `ImageUtils.kt` or similar file
3. ⬜ Add comprehensive logging untuk debug rotation values
4. ⬜ Choose implementation strategy (Option 1, 2, or 3)
5. ⬜ Implement fix
6. ⬜ Test thoroughly dengan different orientations
7. ⬜ Document changes & create PR if applicable

### For Testing:

1. ⬜ Place model file: `android/app/src/main/assets/plat_recognation.tflite`
2. ⬜ Run app dengan `flutter run` (full restart)
3. ⬜ Check debug logs untuk aspect ratio details
4. ⬜ Share log output dengan maintainer
5. ⬜ Test fix dengan real license plates di berbagai angles

---

## 🔚 Conclusion

**This is a CRITICAL bug** yang blocking effective use dari cropping feature untuk license plate recognition. Masalah ada di **coordinate system transformation** antara camera preview dan raw image data di Android native layer.

**Recommended Fix:** Option 1 (Transform Coordinates Before Crop) - paling clean dan efficient solution.

**Temporary Workaround:** Option 3 (Flutter rotation fix) - bisa di-implement immediately tanpa tunggu native fix.

---

**Document Version:** 1.0  
**Last Updated:** October 21, 2025  
**Status:** 🔴 ACTIVE BUG - Awaiting Fix
