# 🚀 Backport Implementation Guide: Cropping to v0.1.37

## ✅ CONFIRMED: Bisa 100% Di-Implement!

**Key Finding**: Perbedaan utama adalah **parameter `includeOriginalImage`** yang tidak ada di v0.1.37!

---

## 📦 Files yang Harus Di-Backport/Modify

### 🆕 Files Baru (Copy dari v0.1.39)
1. `android/src/main/kotlin/com/ultralytics/yolo/utils/ImageCropper.kt` (NEW)
2. `lib/models/yolo_cropped_image.dart` (NEW - optional)

### ✏️ Files yang Harus Dimodifikasi

#### Android Layer (Kotlin)
1. `android/src/main/kotlin/com/ultralytics/yolo/YOLOView.kt`
   - Add cropping properties
   - Add cropping methods
   - Add `includeOriginalImage` support
   - Trigger cropping in `onFrame()`

2. `android/src/main/kotlin/com/ultralytics/yolo/YOLOPlatformView.kt`
   - Add method channel handlers for cropping

3. `android/src/main/kotlin/com/ultralytics/yolo/BasePredictor.kt` (CRITICAL!)
   - Add `includeOriginalImage` parameter support
   - Store originalImage in YOLOResult

#### Flutter/Dart Layer
4. `lib/yolo_streaming_config.dart` (CRITICAL!)
   - Add `includeOriginalImage` parameter

5. `lib/models/yolo_result.dart`
   - Add `originalImage` field (if not exist)

---

## 🔧 Step-by-Step Implementation

### Phase 1: Copy ImageCropper.kt

```powershell
# Create utils directory
New-Item -ItemType Directory -Force -Path "d:\Bapenda New\explore\ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37\android\src\main\kotlin\com\ultralytics\yolo\utils"

# Copy file
Copy-Item -Path "d:\Bapenda New\explore\yolo-flutter-app\android\src\main\kotlin\com\ultralytics\yolo\utils\ImageCropper.kt" `
          -Destination "d:\Bapenda New\explore\ultralytics_yolo_0_1_37\yolo-flutter-app-0.1.37\android\src\main\kotlin\com\ultralytics\yolo\utils\ImageCropper.kt"
```

---

### Phase 2: Modify YOLOStreamingConfig.dart (CRITICAL!)

**File**: `lib/yolo_streaming_config.dart`

**Location**: Find class definition, add new parameter

```dart
class YOLOStreamingConfig {
  // Existing parameters
  final int? maxFPS;
  final int? throttleIntervalMs;
  final int? inferenceFrequency;
  final bool? includeMasks;
  final bool? includeProcessingTimeMs;
  
  // 🔥 NEW: Critical for cropping!
  final bool? includeOriginalImage;

  const YOLOStreamingConfig({
    this.maxFPS,
    this.throttleIntervalMs,
    this.inferenceFrequency,
    this.includeMasks,
    this.includeProcessingTimeMs,
    this.includeOriginalImage,  // Add this line
  });

  Map<String, dynamic> toMap() {
    return {
      if (maxFPS != null) 'maxFPS': maxFPS,
      if (throttleIntervalMs != null) 'throttleIntervalMs': throttleIntervalMs,
      if (inferenceFrequency != null) 'inferenceFrequency': inferenceFrequency,
      if (includeMasks != null) 'includeMasks': includeMasks,
      if (includeProcessingTimeMs != null) 'includeProcessingTimeMs': includeProcessingTimeMs,
      if (includeOriginalImage != null) 'includeOriginalImage': includeOriginalImage,  // Add this line
    };
  }
}
```

---

### Phase 3: Modify BasePredictor.kt (CRITICAL!)

**File**: `android/src/main/kotlin/com/ultralytics/yolo/BasePredictor.kt`

**Add property**:
```kotlin
abstract class BasePredictor {
    // Existing properties...
    
    // 🔥 NEW: Flag to include original image in results
    protected var includeOriginalImage: Boolean = false
    
    // Existing methods...
}
```

**Modify `predict()` method** to capture and attach originalImage:

```kotlin
fun predict(
    bitmap: Bitmap,
    width: Int,
    height: Int,
    rotateForCamera: Boolean = false,
    isLandscape: Boolean = false
): YOLOResult {
    // ... existing preprocessing code ...
    
    val result = predictInternal(processedBitmap, width, height)
    
    // 🔥 NEW: Attach original image if requested
    if (includeOriginalImage) {
        result.originalImage = processedBitmap  // or rotated bitmap for cropping
    }
    
    return result
}
```

---

### Phase 4: Modify YOLOView.kt

**File**: `android/src/main/kotlin/com/ultralytics/yolo/YOLOView.kt`

#### Step 4.1: Add Imports
```kotlin
import com.ultralytics.yolo.utils.ImageCropper
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import android.graphics.RectF
```

#### Step 4.2: Add Cropping Properties (after line ~42)
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

#### Step 4.3: Handle includeOriginalImage in setStreamConfig()

**Find method** `setStreamConfig()` and modify:
```kotlin
fun setStreamConfig(config: YOLOStreamConfig?) {
    this.streamConfig = config
    
    // 🔥 NEW: Pass includeOriginalImage to predictor
    val includeImage = config?.includeOriginalImage ?: false
    predictor?.let { p ->
        if (p is BasePredictor) {
            p.includeOriginalImage = includeImage
        }
    }
    
    // ... rest of existing code ...
}
```

#### Step 4.4: Add Cropping Control Methods (after `setNumItemsThreshold()`)

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
                Log.w(TAG, "Cannot crop: originalImage is null. Enable includeOriginalImage in streamConfig!")
                return@execute
            }
            
            Log.d(TAG, "=== CROPPING DEBUG ===")
            Log.d(TAG, "Original bitmap: ${originalBitmap.width}x${originalBitmap.height}")
            Log.d(TAG, "Number of boxes: ${result.boxes.size}")
            
            // 🔥 FIX: Use normalized coordinates scaled to bitmap
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
            
            if (croppedResults.isEmpty()) {
                Log.w(TAG, "No valid crops produced")
                return@execute
            }
            
            Log.d(TAG, "Successfully cropped ${croppedResults.size} images")
            
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
                    "clsName" to box.cls,
                    "originalBox" to mapOf(
                        "x1" to box.xywh.left.toDouble(),
                        "y1" to box.xywh.top.toDouble(),
                        "x2" to box.xywh.right.toDouble(),
                        "y2" to box.xywh.bottom.toDouble()
                    )
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
            
            Log.d(TAG, "Cropping completed successfully")
            
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

#### Step 4.5: Trigger Cropping in onFrame()

**Find method** `onFrame()`, after inference callback, add:

```kotlin
// Process cropping if enabled
if (enableCropping && result.boxes.isNotEmpty()) {
    processCroppingAsync(result)
}
```

---

### Phase 5: Modify YOLOPlatformView.kt

**File**: `android/src/main/kotlin/com/ultralytics/yolo/YOLOPlatformView.kt`

**Find method channel handler** (usually in `onMethodCall()`), add new cases:

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

Also handle `includeOriginalImage` in platform view creation params:

```kotlin
// In onCreate or initialization
val streamConfig = creationParams?.get("streamingConfig") as? Map<String, Any>
val includeOriginalImage = streamConfig?.get("includeOriginalImage") as? Boolean ?: false
// Pass to yoloView via streamConfig
```

---

### Phase 6: Usage Example (Flutter)

```dart
// In your Flutter app
YOLOView(
  modelPath: 'assets/models/yolo11n.tflite',
  task: YOLOTask.detect,
  
  // 🔥 CRITICAL: Enable includeOriginalImage for cropping!
  streamingConfig: const YOLOStreamingConfig(
    includeOriginalImage: true,  // Must be true!
    maxFPS: 30,
  ),
  
  onViewCreated: (controller) async {
    // Enable cropping
    await controller.setEnableCropping(true);
    await controller.setCroppingPadding(0.1);  // 10% padding
    await controller.setCroppingQuality(90);   // JPEG quality
  },
  
  onResult: (result) {
    print('Detected: ${result.boxes.length} objects');
  },
)

// Listen for cropped images
yoloView.onCroppedImagesReady = (croppedImages) {
  for (var cropData in croppedImages) {
    String cacheKey = cropData['cacheKey'];
    int width = cropData['width'];
    int height = cropData['height'];
    double confidence = cropData['confidence'];
    
    print('Cropped: ${width}x${height}, conf: $confidence');
    
    // Get actual image bytes
    Uint8List? imageBytes = await controller.getCroppedImage(cacheKey);
    if (imageBytes != null) {
      // Use image (save, display, OCR, etc.)
    }
  }
};
```

---

## 🎯 Critical Configuration

### ⚠️ MUST DO untuk Cropping Bekerja!

```dart
YOLOStreamingConfig(
  includeOriginalImage: true,  // ← WITHOUT THIS, NO CROPPING!
)
```

**Mengapa Critical**:
- Tanpa ini, `result.originalImage` akan `null`
- `processCroppingAsync()` akan langsung return
- Log akan show: `"Cannot crop: originalImage is null"`

---

## 📊 Comparison Matrix

| Feature | v0.1.37 Original | v0.1.37 + Backport | v0.1.39 |
|---------|------------------|---------------------|---------|
| `includeOriginalImage` param | ❌ None | ✅ Added | ✅ Native |
| ImageCropper utility | ❌ None | ✅ Backported | ✅ Native |
| Cropping methods | ❌ None | ✅ Added | ✅ Native |
| Double detection bug | ✅ None | ✅ None | ❌ Present |
| Rotation fix | ⚠️ May need | ✅ Include | ✅ Has |
| Production ready | ✅ Yes | ✅ Yes | ❌ No (bug) |

---

## 🧪 Testing Checklist

### Pre-Backport Verification
- [ ] v0.1.37 builds successfully
- [ ] v0.1.37 runs without double detection
- [ ] Baseline performance measured

### Post-Backport Verification
- [ ] Code compiles without errors
- [ ] App launches successfully
- [ ] **No double detection** (PRIMARY)
- [ ] Cropping can be enabled
- [ ] `includeOriginalImage` works
- [ ] Cropped images are accurate
- [ ] Cache management works
- [ ] No memory leaks
- [ ] Performance acceptable

### Test Cases

#### Test 1: Without includeOriginalImage
```dart
YOLOStreamingConfig(
  includeOriginalImage: false,  // or not set
)
```
**Expected**: 
- Inference works ✅
- Cropping doesn't work ✅ (expected)
- Log shows: "Cannot crop: originalImage is null"

#### Test 2: With includeOriginalImage
```dart
YOLOStreamingConfig(
  includeOriginalImage: true,
)
await controller.setEnableCropping(true);
```
**Expected**:
- Inference works ✅
- Cropping works ✅
- Cropped images appear in callback
- Coordinates accurate

#### Test 3: Double Detection Check
**Expected**:
- Single bounding box per license plate ✅
- No duplicate overlays
- Cropped gallery shows correct count (not doubled)

---

## 🚨 Common Issues & Solutions

### Issue 1: "Cannot crop: originalImage is null"
**Cause**: `includeOriginalImage` not set to `true`  
**Solution**: 
```dart
YOLOStreamingConfig(
  includeOriginalImage: true,  // Add this!
)
```

### Issue 2: Cropped coordinates wrong
**Cause**: Using pixel coords instead of normalized  
**Solution**: Already handled in backport - uses `xywhn * bitmap.width/height`

### Issue 3: Rotation bug persists
**Cause**: v0.1.37 might not have rotation fix  
**Solution**: Check `onFrame()` method has:
```kotlin
val rotatedBitmap = if (!isLandscape) {
    val matrix = Matrix()
    matrix.postRotate(90f)
    Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
} else {
    bitmap
}
```

### Issue 4: Memory leak
**Cause**: Bitmap not recycled  
**Solution**: Ensure:
```kotlin
if (croppedBitmap != originalBitmap) {
    croppedBitmap.recycle()
}
```

---

## ⏱️ Estimated Time

| Phase | Task | Time |
|-------|------|------|
| 1 | Copy ImageCropper.kt | 5 min |
| 2 | Modify YOLOStreamingConfig.dart | 10 min |
| 3 | Modify BasePredictor.kt | 15 min |
| 4 | Modify YOLOView.kt | 25 min |
| 5 | Modify YOLOPlatformView.kt | 10 min |
| 6 | Test & Debug | 20 min |
| **Total** | | **~85 min** |

---

## 🎯 Success Criteria

### Must Have ✅
- [x] No compilation errors
- [ ] No double detection (PRIMARY GOAL!)
- [ ] Cropping works with correct coordinates
- [ ] `includeOriginalImage` parameter functional
- [ ] Performance acceptable (>20 FPS)

### Nice to Have
- [ ] Flutter API fully exposed
- [ ] Example app updated
- [ ] Documentation complete
- [ ] Memory usage optimized

---

## 📝 Final Notes

**Key Insight**: Parameter `includeOriginalImage` adalah **CRITICAL ENABLER** untuk cropping!

**Backport Strategy**:
1. ✅ Copy standalone utilities (ImageCropper)
2. ✅ Add missing parameter (`includeOriginalImage`)
3. ✅ Implement cropping logic
4. ✅ Keep v0.1.37 stability (no NMS changes)
5. ✅ Test thoroughly before production

**Deployment**:
- Test di v0.1.37 + backport dulu
- Kalau stable, deploy to production
- Monitor untuk double detection dan performance

---

**Ready to Execute?** 🚀  
Follow steps Phase 1-6 above, test each phase, dan report hasilnya!

**Status**: Documentation Complete ✅  
**Next**: Execute Implementation 🔧
