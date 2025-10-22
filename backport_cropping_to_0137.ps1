# 🚀 Backport Cropping Feature to v0.1.37
# This script automates the backport process

$ErrorActionPreference = "Stop"
$v0137Path = "d:\Bapenda New\explore\ultralytics_yolo_0_1_37"
$v0139Path = "d:\Bapenda New\explore\yolo-flutter-app"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🚀 BACKPORT CROPPING FEATURE TO v0.1.37" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Phase 1: Copy ImageCropper.kt
Write-Host "📦 Phase 1: Copying ImageCropper.kt..." -ForegroundColor Yellow
$utilsDir = "$v0137Path\android\src\main\kotlin\com\ultralytics\yolo\utils"
New-Item -ItemType Directory -Path $utilsDir -Force | Out-Null

$sourceCropper = "$v0139Path\android\src\main\kotlin\com\ultralytics\yolo\utils\ImageCropper.kt"
$targetCropper = "$utilsDir\ImageCropper.kt"

if (Test-Path $sourceCropper) {
    Copy-Item -Path $sourceCropper -Destination $targetCropper -Force
    Write-Host "✅ ImageCropper.kt copied successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Source ImageCropper.kt not found!" -ForegroundColor Red
    exit 1
}

# Phase 2: Modify YOLOView.kt
Write-Host ""
Write-Host "✏️  Phase 2: Modifying YOLOView.kt..." -ForegroundColor Yellow

$yoloViewPath = "$v0137Path\android\src\main\kotlin\com\ultralytics\yolo\YOLOView.kt"
$yoloViewContent = Get-Content $yoloViewPath -Raw

# 2.1: Add imports after existing imports
$importRegex = '(import androidx\.lifecycle\.LifecycleOwner)'
$newImports = @"
`$1
import com.ultralytics.yolo.utils.ImageCropper
import java.util.concurrent.ConcurrentHashMap
import android.graphics.RectF
"@

if ($yoloViewContent -notmatch 'import com\.ultralytics\.yolo\.utils\.ImageCropper') {
    $yoloViewContent = $yoloViewContent -replace $importRegex, $newImports
    Write-Host "  ✓ Added imports" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ Imports already exist, skipping" -ForegroundColor Gray
}

# 2.2: Add properties after lifecycleOwner
$propsRegex = '(private var lifecycleOwner: LifecycleOwner\? = null)'
$newProps = @"
`$1

    // 🔥 NEW: Cropping configuration (v0.1.37 backport)
    private var enableCropping: Boolean = false
    private var croppingPadding: Float = 0.1f
    private var croppingQuality: Int = 90
    
    // 🔥 NEW: Store cropped images temporarily
    private val croppedImagesCache = ConcurrentHashMap<String, ByteArray>()
    
    // 🔥 NEW: Callback for cropped images
    var onCroppedImagesReady: ((List<Map<String, Any>>) -> Unit)? = null
"@

if ($yoloViewContent -notmatch 'enableCropping') {
    $yoloViewContent = $yoloViewContent -replace $propsRegex, $newProps
    Write-Host "  ✓ Added cropping properties" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ Properties already exist, skipping" -ForegroundColor Gray
}

# 2.3: Add cropping methods before the last closing brace
$croppingMethods = @"

    // region Cropping Control (v0.1.37 backport)
    
    fun setEnableCropping(enable: Boolean) {
        enableCropping = enable
        Log.d(TAG, "Cropping `${if (enable) "enabled" else "disabled"}")
    }

    fun setCroppingPadding(padding: Float) {
        croppingPadding = padding.coerceIn(0f, 1f)
        Log.d(TAG, "Cropping padding set to: `$croppingPadding")
    }

    fun setCroppingQuality(quality: Int) {
        croppingQuality = quality.coerceIn(1, 100)
        Log.d(TAG, "Cropping quality set to: `$croppingQuality")
    }

    private fun processCroppingAsync(result: YOLOResult) {
        Executors.newSingleThreadExecutor().execute {
            try {
                val originalBitmap = result.originalImage ?: run {
                    Log.w(TAG, "Cannot crop: originalImage is null. Enable includeOriginalImage!")
                    return@execute
                }
                
                Log.d(TAG, "=== CROPPING DEBUG ===")
                Log.d(TAG, "Original bitmap: `${originalBitmap.width}x`${originalBitmap.height}")
                Log.d(TAG, "Number of boxes: `${result.boxes.size}")
                
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
                
                Log.d(TAG, "Successfully cropped `${croppedResults.size} images")
                
                val croppedImageData = mutableListOf<Map<String, Any>>()
                
                croppedResults.forEachIndexed { index, croppedBitmap ->
                    val box = result.boxes[index]
                    val byteArray = ImageCropper.bitmapToByteArray(croppedBitmap, croppingQuality)
                    val cacheKey = "crop_`${System.currentTimeMillis()}_`$index"
                    
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
"@

# Find onFrame method and add cropping trigger
$onFramePattern = '(onInferenceResult\?\(result, yoloView\.width, yoloView\.height\))'
$croppingTrigger = @"
`$1
                
                // 🔥 NEW: Process cropping if enabled (v0.1.37 backport)
                if (enableCropping && result.boxes.isNotEmpty()) {
                    processCroppingAsync(result)
                }
"@

if ($yoloViewContent -notmatch 'processCroppingAsync') {
    # Add methods before last closing brace
    $yoloViewContent = $yoloViewContent -replace '(\n\})(\s*)$', "$croppingMethods`n}`$2"
    Write-Host "  ✓ Added cropping methods" -ForegroundColor Gray
    
    # Add trigger in onFrame
    $yoloViewContent = $yoloViewContent -replace $onFramePattern, $croppingTrigger
    Write-Host "  ✓ Added cropping trigger in onFrame()" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ Cropping methods already exist, skipping" -ForegroundColor Gray
}

# Save modified YOLOView.kt
Set-Content -Path $yoloViewPath -Value $yoloViewContent -Encoding UTF8
Write-Host "✅ YOLOView.kt modified successfully!" -ForegroundColor Green

# Phase 3: Modify YOLOPlatformView.kt
Write-Host ""
Write-Host "✏️  Phase 3: Modifying YOLOPlatformView.kt..." -ForegroundColor Yellow

$platformViewPath = "$v0137Path\android\src\main\kotlin\com\ultralytics\yolo\YOLOPlatformView.kt"
$platformViewContent = Get-Content $platformViewPath -Raw

# Find method channel handler section
$methodChannelPattern = '("stopCamera" -> \{[^}]+\})'
$newMethods = @"
`$1
            
            // 🔥 NEW: Cropping method channel handlers (v0.1.37 backport)
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
"@

if ($platformViewContent -notmatch 'setEnableCropping') {
    $platformViewContent = $platformViewContent -replace $methodChannelPattern, $newMethods
    Write-Host "  ✓ Added method channel handlers" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ Method handlers already exist, skipping" -ForegroundColor Gray
}

Set-Content -Path $platformViewPath -Value $platformViewContent -Encoding UTF8
Write-Host "✅ YOLOPlatformView.kt modified successfully!" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🎉 BACKPORT COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Modified files:" -ForegroundColor White
Write-Host "  ✓ ImageCropper.kt (NEW)" -ForegroundColor Gray
Write-Host "  ✓ YOLOView.kt (MODIFIED)" -ForegroundColor Gray
Write-Host "  ✓ YOLOPlatformView.kt (MODIFIED)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd '$v0137Path\example'" -ForegroundColor Gray
Write-Host "  2. flutter clean && flutter pub get" -ForegroundColor Gray
Write-Host "  3. flutter run" -ForegroundColor Gray
Write-Host "  4. Test with includeOriginalImage: true" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Ready to test!" -ForegroundColor Green
