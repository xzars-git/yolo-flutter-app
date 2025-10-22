# 🔄 Backport Plan: Cropping Feature ke v0.1.37

## 📋 Keputusan Strategis

**Status Bug**: Double detection masih ada di v0.1.39 meskipun sudah diterapkan:
- ✅ Class-aware NMS
- ✅ IoU threshold 0.20
- ✅ Enhanced logging

**Strategi Baru**: 
- ❌ Tidak fix bug di v0.1.39 (terlalu kompleks, regression dari upstream)
- ✅ **Backport cropping feature ke v0.1.37** (versi stabil terakhir)
- ✅ Deploy v0.1.37 + cropping untuk production

---

## 🎯 Mengapa Backport ke v0.1.37?

### Keuntungan
1. ✅ **Tidak ada bug double detection** (sudah proven stable)
2. ✅ **Fokus hanya ke cropping** (tidak perlu fix NMS)
3. ✅ **Lebih cepat** (tidak perlu debug regression bug)
4. ✅ **Lebih aman** (tidak ada side effects dari refactoring v0.1.38)
5. ✅ **Production ready** (v0.1.37 sudah tested di field)

### Risiko Minimal
- File yang dimodifikasi: ~5 files only
- Tidak touch NMS logic
- Tidak touch core inference pipeline
- Pure additive feature (tidak ubah existing)

---

## 📦 Files yang Perlu Di-Backport

### 1. **ImageCropper.kt** (NEW FILE)
```
Source: v0.1.39/android/src/main/kotlin/com/ultralytics/yolo/utils/ImageCropper.kt
Target: v0.1.37/android/src/main/kotlin/com/ultralytics/yolo/utils/ImageCropper.kt
Action: Copy entire file
Lines: ~180 lines
Dependencies: None (standalone utility)
```

### 2. **YOLOView.kt** (MODIFY)
**Additions needed**:
```kotlin
// Line ~34: Import
import com.ultralytics.yolo.utils.ImageCropper

// Line ~46-48: Properties
private var enableCropping: Boolean = false
private var croppingPadding: Float = 0.1f
private var croppingQuality: Int = 90

// Line ~52: Cache
private val croppedImagesCache = ConcurrentHashMap<String, ByteArray>()

// Line ~55: Callback
var onCroppedImagesReady: ((List<Map<String, Any>>) -> Unit)? = null

// Line ~414-427: Cropping control methods
fun setEnableCropping(enable: Boolean)
fun setCroppingPadding(padding: Float)
fun setCroppingQuality(quality: Int)

// Line ~434-526: Async cropping processor
private fun processCroppingAsync(result: YOLOResult)

// Line ~533: Get from cache
fun getCroppedImageFromCache(cacheKey: String): ByteArray?

// Line ~890: Trigger cropping in onFrame()
if (enableCropping && result.boxes.isNotEmpty()) {
    processCroppingAsync(resultWithOriginalImage)
}
```

### 3. **YOLOPlatformView.kt** (MODIFY)
**Additions needed**:
```kotlin
// Line ~453-473: Method channel handlers
"setEnableCropping" -> {
    val enable = call.argument<Boolean>("enable") ?: false
    yoloView.setEnableCropping(enable)
    result.success(null)
}

"setCroppingPadding" -> {
    val padding = call.argument<Double>("padding") ?: 0.1
    yoloView.setCroppingPadding(padding.toFloat())
    result.success(null)
}

"setCroppingQuality" -> {
    val quality = call.argument<Int>("quality") ?: 90
    yoloView.setCroppingQuality(quality)
    result.success(null)
}

"getCroppedImage" -> {
    val cacheKey = call.argument<String>("cacheKey")
    if (cacheKey != null) {
        val imageBytes = yoloView.getCroppedImageFromCache(cacheKey)
        result.success(imageBytes)
    } else {
        result.error("INVALID_ARGS", "cacheKey is required", null)
    }
}
```

### 4. **Flutter Layer** (OPTIONAL - kalau mau exposed ke Flutter)
```dart
// lib/ultralytics_yolo.dart - Method channel calls
Future<void> setEnableCropping(bool enable)
Future<void> setCroppingPadding(double padding)
Future<void> setCroppingQuality(int quality)
Future<Uint8List?> getCroppedImage(String cacheKey)
```

---

## 🛠️ Step-by-Step Implementation

### Phase 1: Preparation (5 mins)

1. **Backup v0.1.37 source**
   ```powershell
   # Create backup
   cd "d:\Bapenda New\explore"
   Copy-Item -Path "ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37" `
             -Destination "ultralytics_yolo_0_1_37_BACKUP" -Recurse
   ```

2. **Verify v0.1.37 baseline**
   ```powershell
   cd "d:\Bapenda New\explore\ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37\example"
   flutter clean
   flutter pub get
   flutter run
   ```
   - ✅ No double detection
   - ✅ Normal inference works
   - ❌ No cropping feature (expected)

---

### Phase 2: Copy ImageCropper.kt (10 mins)

```powershell
# Copy ImageCropper utility
$source = "d:\Bapenda New\explore\yolo-flutter-app\android\src\main\kotlin\com\ultralytics\yolo\utils\ImageCropper.kt"
$target = "d:\Bapenda New\explore\ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37\android\src\main\kotlin\com\ultralytics\yolo\utils\ImageCropper.kt"

# Create utils directory if not exists
New-Item -ItemType Directory -Force -Path (Split-Path $target)

# Copy file
Copy-Item -Path $source -Destination $target -Force
```

**Verify**: File should exist at target location (~180 lines)

---

### Phase 3: Modify YOLOView.kt (20 mins)

**Location**: `ultralytics_yolo_0_1_37/yolo-flutter-app-0.1.37/android/src/main/kotlin/com/ultralytics/yolo/YOLOView.kt`

#### Step 3.1: Add Import
Find line ~30 (imports section), add:
```kotlin
import com.ultralytics.yolo.utils.ImageCropper
import java.util.concurrent.ConcurrentHashMap
```

#### Step 3.2: Add Properties
Find line ~42 (after `private var lifecycleOwner`), add:
```kotlin
// NEW: Cropping configuration
private var enableCropping: Boolean = false
private var croppingPadding: Float = 0.1f
private var croppingQuality: Int = 90

// NEW: Store cropped images temporarily
private val croppedImagesCache = ConcurrentHashMap<String, ByteArray>()

// NEW: Callback for cropped images
var onCroppedImagesReady: ((List<Map<String, Any>>) -> Unit)? = null
```

#### Step 3.3: Add Control Methods
Find line ~360 (after `setNumItemsThreshold()`), add:
```kotlin
// region Cropping Control

fun setEnableCropping(enable: Boolean) {
    enableCropping = enable
    Log.d(TAG, "Cropping ${if (enable) "enabled" else "disabled"}")
}

fun setCroppingPadding(padding: Float) {
    croppingPadding = padding.coerceIn(0f, 1f)
    Log.d(TAG, "Cropping padding set to: $croppingPadding")
}

fun setCroppingQuality(quality: Int) {
    croppingQuality = quality.coerceIn(1, 100)
    Log.d(TAG, "Cropping quality set to: $croppingQuality")
}

private fun processCroppingAsync(result: YOLOResult) {
    Executors.newSingleThreadExecutor().execute {
        try {
            val originalBitmap = result.originalImage ?: run {
                Log.w(TAG, "Cannot crop: originalImage is null")
                return@execute
            }
            
            // Use normalized coordinates scaled to bitmap
            val boundingBoxes = result.boxes.map { box ->
                RectF(
                    box.xywhn.left * originalBitmap.width,
                    box.xywhn.top * originalBitmap.height,
                    box.xywhn.right * originalBitmap.width,
                    box.xywhn.bottom * originalBitmap.height
                )
            }
            
            val croppedResults = ImageCropper.cropMultipleBoundingBoxes(
                originalBitmap,
                boundingBoxes,
                croppingPadding,
                useNormalizedCoords = false
            )
            
            if (croppedResults.isEmpty()) return@execute
            
            val croppedImageData = mutableListOf<Map<String, Any>>()
            
            croppedResults.forEachIndexed { index, croppedBitmap ->
                val box = result.boxes[index]
                val byteArray = ImageCropper.bitmapToByteArray(croppedBitmap, croppingQuality)
                val cacheKey = "crop_${System.currentTimeMillis()}_$index"
                
                croppedImagesCache[cacheKey] = byteArray
                
                croppedImageData.add(mapOf(
                    "cacheKey" to cacheKey,
                    "width" to croppedBitmap.width,
                    "height" to croppedBitmap.height,
                    "sizeBytes" to byteArray.size,
                    "confidence" to box.conf.toDouble(),
                    "cls" to box.index,
                    "clsName" to box.cls
                ))
                
                if (croppedBitmap != originalBitmap) {
                    croppedBitmap.recycle()
                }
            }
            
            // Clean cache if too large
            if (croppedImagesCache.size > 50) {
                val keysToRemove = croppedImagesCache.keys.take(croppedImagesCache.size - 50)
                keysToRemove.forEach { croppedImagesCache.remove(it) }
            }
            
            post {
                onCroppedImagesReady?.invoke(croppedImageData)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error during cropping", e)
        }
    }
}

fun getCroppedImageFromCache(cacheKey: String): ByteArray? {
    return croppedImagesCache[cacheKey]
}

// endregion
```

#### Step 3.4: Trigger Cropping in onFrame()
Find the `onFrame()` method, after inference callback (around line ~835), add:
```kotlin
// Process cropping if enabled
if (enableCropping && result.boxes.isNotEmpty()) {
    processCroppingAsync(resultWithOriginalImage)
}
```

---

### Phase 4: Modify YOLOPlatformView.kt (15 mins)

**Location**: `ultralytics_yolo_0_1_37/yolo-flutter-app-0.1.37/android/src/main/kotlin/com/ultralytics/yolo/YOLOPlatformView.kt`

Find method channel handler section (around line ~400), add new cases:

```kotlin
"setEnableCropping" -> {
    val enable = call.argument<Boolean>("enable") ?: false
    yoloView.setEnableCropping(enable)
    result.success(null)
}

"setCroppingPadding" -> {
    val padding = call.argument<Double>("padding") ?: 0.1
    yoloView.setCroppingPadding(padding.toFloat())
    result.success(null)
}

"setCroppingQuality" -> {
    val quality = call.argument<Int>("quality") ?: 90
    yoloView.setCroppingQuality(quality)
    result.success(null)
}

"getCroppedImage" -> {
    val cacheKey = call.argument<String>("cacheKey")
    if (cacheKey != null) {
        val imageBytes = yoloView.getCroppedImageFromCache(cacheKey)
        result.success(imageBytes)
    } else {
        result.error("INVALID_ARGS", "cacheKey is required", null)
    }
}
```

---

### Phase 5: Test (20 mins)

```powershell
# Build and test
cd "d:\Bapenda New\explore\ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37\example"

flutter clean
flutter pub get
flutter run
```

**Test Cases**:
1. ✅ **No double detection** (primary goal)
2. ✅ **Cropping works** when enabled
3. ✅ **Normal inference** when cropping disabled
4. ✅ **No crashes** or memory leaks

---

## 📊 Comparison: v0.1.37+Cropping vs v0.1.39

| Feature | v0.1.37+Cropping | v0.1.39 (Current) |
|---------|------------------|-------------------|
| **Double Detection** | ❌ None | ✅ Present |
| **Cropping** | ✅ Backported | ✅ Native |
| **Stability** | ✅ Proven | ⚠️ Regression |
| **Code Complexity** | ✅ Simple | ❌ Refactored |
| **Maintenance** | ✅ Easy | ⚠️ Complex |
| **Production Ready** | ✅ Yes | ❌ Needs fix |

---

## 🎯 Expected Results

### After Backport
```
v0.1.37 + Cropping:
- ✅ No double detection (78.6% only)
- ✅ Cropping works (25 detected → 25 cropped)
- ✅ Cache management (50 max images)
- ✅ Normalized coordinates (accurate crop)
- ✅ Rotation fix (90° for portrait)
- ✅ Performance stable (same as v0.1.37)
```

### Screenshots Should Show
- Camera view: **1 bounding box** per license plate
- Cropped gallery: **25 cropped images** (not 50 duplicates)
- Confidence: Single value (78.6%)

---

## 🚀 Deployment Strategy

### Option 1: Use Modified v0.1.37 Directly
```powershell
# Replace your current package with backported v0.1.37
cd "d:\Bapenda New\explore"

# Remove current (broken) version
Remove-Item -Path "yolo-flutter-app" -Recurse -Force

# Copy backported version
Copy-Item -Path "ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37" `
          -Destination "yolo-flutter-app" -Recurse

# Update your Flutter app's pubspec.yaml
# ultralytics_yolo:
#   path: ../yolo-flutter-app  # Points to backported v0.1.37
```

### Option 2: Git Branch Strategy
```bash
# Create new branch from v0.1.37
git checkout -b backport-cropping-to-v0.1.37

# Apply backport changes
# (manual copy of files as described above)

# Commit
git add .
git commit -m "Backport cropping feature to stable v0.1.37"

# Use in your Flutter app
# ultralytics_yolo:
#   git:
#     url: https://github.com/your-fork/yolo-flutter-app
#     ref: backport-cropping-to-v0.1.37
```

---

## 📝 Testing Checklist

### Pre-Backport (Baseline)
- [ ] v0.1.37 builds successfully
- [ ] v0.1.37 runs without errors
- [ ] No double detection in v0.1.37
- [ ] Inference works normally

### Post-Backport
- [ ] ImageCropper.kt copied successfully
- [ ] YOLOView.kt modified (imports, properties, methods)
- [ ] YOLOPlatformView.kt modified (method channel)
- [ ] Code compiles without errors
- [ ] App runs without crashes

### Functional Tests
- [ ] Cropping can be enabled/disabled
- [ ] Cropped images appear in gallery
- [ ] Cropped images are accurate (match bounding box)
- [ ] Rotation bug is fixed (90° for portrait)
- [ ] Cache management works (max 50 images)
- [ ] **NO DOUBLE DETECTION** ← PRIMARY

### Performance Tests
- [ ] FPS remains stable (~20+ FPS)
- [ ] Memory usage acceptable
- [ ] No memory leaks
- [ ] Battery usage normal

---

## ⚠️ Potential Issues & Solutions

### Issue 1: Compilation Errors
**Cause**: Missing imports or incompatible API
**Solution**: Check Kotlin/Android versions match between v0.1.37 and v0.1.39

### Issue 2: Cropped Images Wrong Coordinates
**Cause**: Coordinate system mismatch (v0.1.37 might have different origShape)
**Solution**: Use normalized coordinates (xywhn) scaled to bitmap dimensions

### Issue 3: Rotation Still Wrong
**Cause**: v0.1.37 might not have portrait rotation fix
**Solution**: Copy rotation fix from v0.1.39's onFrame() method

### Issue 4: Memory Leaks
**Cause**: Bitmap recycling not working
**Solution**: Ensure `croppedBitmap.recycle()` called after use

---

## 📄 Files Summary

### Files to Copy (1 file)
1. `ImageCropper.kt` (NEW) - ~180 lines

### Files to Modify (2 files)
1. `YOLOView.kt` - Add ~120 lines
2. `YOLOPlatformView.kt` - Add ~30 lines

### Files Unchanged
- ✅ `native-lib.cpp` (no NMS changes needed!)
- ✅ `ObjectDetector.kt` (no threshold changes needed!)
- ✅ All other predictors

**Total LOC to modify**: ~330 lines (vs fixing v0.1.38 regression = unknown complexity)

---

## 🎯 Success Criteria

### Must Have
- [x] No double detection (single box per object)
- [ ] Cropping works (correct coordinates)
- [ ] Rotation fixed (90° for portrait)
- [ ] Performance acceptable (>20 FPS)
- [ ] No crashes or errors

### Nice to Have
- [ ] Flutter API exposed (optional)
- [ ] OCR integration ready
- [ ] Documentation updated
- [ ] Example app demonstrates cropping

---

## 🔄 Rollback Plan

If backport fails:
```powershell
# Restore original v0.1.37
cd "d:\Bapenda New\explore"
Remove-Item -Path "ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37" -Recurse
Copy-Item -Path "ultralytics_yolo_0_1_37_BACKUP" `
          -Destination "ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37" -Recurse
```

---

## 📞 Next Steps

1. ✅ Review this backport plan
2. ⏳ **Execute Phase 1-5** (estimated 60-70 minutes)
3. 🧪 Test thoroughly
4. 🚀 Deploy to production if successful
5. 📝 Document any issues encountered

---

**Created**: October 21, 2025
**Strategy**: Backport cropping to stable v0.1.37 instead of fixing v0.1.39 regression
**Estimated Time**: 60-70 minutes
**Risk Level**: LOW (additive feature, no core changes)
**Production Ready**: After testing ✅
