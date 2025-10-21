# 🎯 Implementation Plan - Adding Cropping Feature to Ultralytics YOLO Package

> **Extend existing package** | **Minimal changes** | **Production ready** | **Backward compatible**

---

## 📋 OVERVIEW: What We're Adding

**Goal**: Menambahkan fitur cropping ke package ultralytics_yolo yang sudah ada, sehingga bisa mendapatkan cropped image dari bounding box untuk OCR processing.

**Key Requirements**:
1. ✅ Get cropped license plate image tanpa overlay/label
2. ✅ Real-time cropping saat detection
3. ✅ High quality image untuk OCR
4. ✅ Minimal performance impact
5. ✅ Backward compatible (tidak break existing code)

---

## 🏗️ ARCHITECTURE: Files to Modify/Add

```
ultralytics_yolo/
│
├── 📱 Flutter Layer (Dart)
│   ├── lib/
│   │   ├── yolo_view.dart                    [MODIFY] Add cropping callback
│   │   ├── models/yolo_result.dart           [MODIFY] Add cropped images field
│   │   └── yolo_streaming_config.dart        [MODIFY] Add cropping options
│   │
├── 🤖 Android Native Layer (Kotlin)
│   └── android/src/main/kotlin/com/ultralytics/yolo/
│       ├── YOLOView.kt                       [MODIFY] Add cropping logic
│       ├── YOLOPlatformView.kt               [MODIFY] Handle cropping events
│       └── utils/
│           └── ImageCropper.kt               [NEW] Cropping utility class
│
└── 🍎 iOS Native Layer (Swift)
    └── ios/Classes/
        ├── YOLOView.swift                    [MODIFY] Add cropping logic
        ├── SwiftYOLOPlatformView.swift       [MODIFY] Handle cropping events
        └── Utils/
            └── ImageCropper.swift            [NEW] Cropping utility class
```

---

## 🔧 STEP-BY-STEP IMPLEMENTATION

### **Phase 1: Android Implementation** (Priority karena Anda fokus di Android)

#### Step 1.1: Create ImageCropper Utility

**File**: `android/src/main/kotlin/com/ultralytics/yolo/utils/ImageCropper.kt`

```kotlin
// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

package com.ultralytics.yolo.utils

import android.graphics.Bitmap
import android.graphics.RectF
import android.util.Log
import java.io.ByteArrayOutputStream

/**
 * Utility class untuk cropping detected objects dari camera frames
 * Optimized untuk license plate detection dan OCR processing
 */
object ImageCropper {
    private const val TAG = "ImageCropper"
    
    /**
     * Crop bounding box area dari original bitmap
     * 
     * @param originalBitmap Source bitmap (camera frame)
     * @param boundingBox Detection bounding box (normalized atau pixel coordinates)
     * @param padding Padding percentage around box (0.0-1.0), default 0.1 = 10%
     * @param useNormalizedCoords True jika boundingBox menggunakan normalized coords (0-1)
     * @return Cropped bitmap atau null jika crop gagal
     */
    fun cropBoundingBox(
        originalBitmap: Bitmap,
        boundingBox: RectF,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false
    ): Bitmap? {
        return try {
            // Convert normalized coords to pixels jika perlu
            val pixelBox = if (useNormalizedCoords) {
                RectF(
                    boundingBox.left * originalBitmap.width,
                    boundingBox.top * originalBitmap.height,
                    boundingBox.right * originalBitmap.width,
                    boundingBox.bottom * originalBitmap.height
                )
            } else {
                boundingBox
            }
            
            // Calculate padded box
            val boxWidth = pixelBox.width()
            val boxHeight = pixelBox.height()
            val paddingX = boxWidth * padding
            val paddingY = boxHeight * padding
            
            // Calculate crop coordinates dengan boundary checking
            val cropLeft = (pixelBox.left - paddingX).coerceAtLeast(0f).toInt()
            val cropTop = (pixelBox.top - paddingY).coerceAtLeast(0f).toInt()
            val cropRight = (pixelBox.right + paddingX)
                .coerceAtMost(originalBitmap.width.toFloat()).toInt()
            val cropBottom = (pixelBox.bottom + paddingY)
                .coerceAtMost(originalBitmap.height.toFloat()).toInt()
            
            val cropWidth = cropRight - cropLeft
            val cropHeight = cropBottom - cropTop
            
            // Validate minimum crop size (untuk avoid tiny crops)
            if (cropWidth < 20 || cropHeight < 10) {
                Log.w(TAG, "Crop size too small: ${cropWidth}x${cropHeight}")
                return null
            }
            
            // Perform actual crop
            val croppedBitmap = Bitmap.createBitmap(
                originalBitmap,
                cropLeft, cropTop,
                cropWidth, cropHeight
            )
            
            Log.d(TAG, "Successfully cropped: ${cropWidth}x${cropHeight} from ${originalBitmap.width}x${originalBitmap.height}")
            croppedBitmap
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to crop bounding box", e)
            null
        }
    }
    
    /**
     * Crop multiple bounding boxes dari single frame
     * Efficient untuk multi-object detection
     */
    fun cropMultipleBoundingBoxes(
        originalBitmap: Bitmap,
        boundingBoxes: List<RectF>,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false
    ): List<Bitmap> {
        return boundingBoxes.mapNotNull { box ->
            cropBoundingBox(originalBitmap, box, padding, useNormalizedCoords)
        }
    }
    
    /**
     * Convert cropped bitmap to byte array untuk transfer ke Flutter
     * 
     * @param bitmap Cropped bitmap
     * @param quality JPEG quality (0-100), default 90 untuk balance size vs quality
     * @return ByteArray dalam format JPEG
     */
    fun bitmapToByteArray(bitmap: Bitmap, quality: Int = 90): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        return stream.toByteArray()
    }
    
    /**
     * Enhanced cropping dengan sharpening untuk better OCR results
     * Useful untuk license plates yang blur atau low quality
     */
    fun cropWithEnhancement(
        originalBitmap: Bitmap,
        boundingBox: RectF,
        padding: Float = 0.1f,
        useNormalizedCoords: Boolean = false,
        sharpen: Boolean = true
    ): Bitmap? {
        val croppedBitmap = cropBoundingBox(
            originalBitmap, 
            boundingBox, 
            padding, 
            useNormalizedCoords
        ) ?: return null
        
        return if (sharpen) {
            applySharpenFilter(croppedBitmap)
        } else {
            croppedBitmap
        }
    }
    
    /**
     * Apply sharpening filter untuk improve OCR accuracy
     */
    private fun applySharpenFilter(bitmap: Bitmap): Bitmap {
        // TODO: Implement sharpening jika diperlukan
        // For now, just return original
        return bitmap
    }
}
```

#### Step 1.2: Modify YOLOView.kt untuk Add Cropping

**File**: `android/src/main/kotlin/com/ultralytics/yolo/YOLOView.kt`

```kotlin
// Add these imports at the top
import com.ultralytics.yolo.utils.ImageCropper
import java.util.concurrent.ConcurrentHashMap

// Add these properties to YOLOView class
class YOLOView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs), DefaultLifecycleObserver {
    
    // ... existing properties ...
    
    // NEW: Cropping configuration
    private var enableCropping: Boolean = false
    private var croppingPadding: Float = 0.1f  // 10% padding default
    private var croppingQuality: Int = 90       // JPEG quality for cropped images
    
    // NEW: Store cropped images temporarily
    private val croppedImagesCache = ConcurrentHashMap<String, ByteArray>()
    
    // NEW: Callback untuk cropped images
    var onCroppedImagesReady: ((List<Map<String, Any>>) -> Unit)? = null
    
    // ... rest of existing code ...
}

// Add these methods to YOLOView class

/**
 * Enable/disable automatic cropping of detected objects
 */
fun setEnableCropping(enable: Boolean) {
    enableCropping = enable
    Log.d(TAG, "Cropping ${if (enable) "enabled" else "disabled"}")
}

/**
 * Set padding percentage untuk cropping (0.0 - 1.0)
 */
fun setCroppingPadding(padding: Float) {
    croppingPadding = padding.coerceIn(0f, 1f)
    Log.d(TAG, "Cropping padding set to: $croppingPadding")
}

/**
 * Set JPEG quality untuk cropped images (0-100)
 */
fun setCroppingQuality(quality: Int) {
    croppingQuality = quality.coerceIn(1, 100)
    Log.d(TAG, "Cropping quality set to: $croppingQuality")
}

// Modify existing handleCameraImage method
private fun handleCameraImage(imageProxy: ImageProxy) {
    if (isUpdating || predictor?.isUpdating == true) {
        imageProxy.close()
        return
    }

    try {
        // ... existing inference code ...
        
        val result = predictor!!.predict(/* ... existing params ... */)
        
        // NEW: Process cropping jika enabled
        if (enableCropping && result.boxes.isNotEmpty()) {
            processCroppingAsync(imageProxy, result)
        }
        
        // ... rest of existing code ...
        
    } catch (e: Exception) {
        Log.e(TAG, "Error handling camera image", e)
    } finally {
        imageProxy.close()
    }
}

/**
 * Process cropping secara asynchronous untuk avoid blocking camera stream
 */
private fun processCroppingAsync(imageProxy: ImageProxy, result: YOLOResult) {
    Executors.newSingleThreadExecutor().execute {
        try {
            // Convert ImageProxy to Bitmap
            val originalBitmap = ImageUtils.toBitmap(imageProxy)
            if (originalBitmap == null) {
                Log.w(TAG, "Failed to convert ImageProxy to Bitmap for cropping")
                return@execute
            }
            
            // Crop all detected boxes
            val croppedImages = mutableListOf<Map<String, Any>>()
            
            for ((index, box) in result.boxes.withIndex()) {
                val croppedBitmap = ImageCropper.cropBoundingBox(
                    originalBitmap = originalBitmap,
                    boundingBox = box.xywh,  // Using pixel coordinates
                    padding = croppingPadding,
                    useNormalizedCoords = false
                )
                
                if (croppedBitmap != null) {
                    // Convert to byte array
                    val byteArray = ImageCropper.bitmapToByteArray(
                        croppedBitmap, 
                        croppingQuality
                    )
                    
                    // Create crop info map
                    val cropInfo = hashMapOf<String, Any>(
                        "index" to index,
                        "className" to box.cls,
                        "confidence" to box.conf.toDouble(),
                        "imageBytes" to byteArray,
                        "width" to croppedBitmap.width,
                        "height" to croppedBitmap.height,
                        "boundingBox" to hashMapOf(
                            "left" to box.xywh.left.toDouble(),
                            "top" to box.xywh.top.toDouble(),
                            "right" to box.xywh.right.toDouble(),
                            "bottom" to box.xywh.bottom.toDouble()
                        )
                    )
                    
                    croppedImages.add(cropInfo)
                    
                    // Cleanup cropped bitmap
                    croppedBitmap.recycle()
                }
            }
            
            // Cleanup original bitmap
            originalBitmap.recycle()
            
            // Send cropped images via callback jika ada
            if (croppedImages.isNotEmpty()) {
                post {
                    onCroppedImagesReady?.invoke(croppedImages)
                }
            }
            
            Log.d(TAG, "Successfully cropped ${croppedImages.size} images")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing cropping", e)
        }
    }
}
```

#### Step 1.3: Modify YOLOPlatformView.kt untuk Handle Cropping Events

**File**: `android/src/main/kotlin/com/ultralytics/yolo/YOLOPlatformView.kt`

```kotlin
class YOLOPlatformView(
    // ... existing params ...
) : PlatformView, MethodChannel.MethodCallHandler {
    
    // ... existing code ...
    
    init {
        // ... existing initialization ...
        
        // NEW: Setup cropping callback
        setupCroppingCallback()
    }
    
    private fun setupCroppingCallback() {
        yoloView.onCroppedImagesReady = { croppedImages ->
            // Send cropped images to Flutter via EventChannel
            if (streamHandler.isSinkValid()) {
                val eventData = hashMapOf<String, Any>(
                    "type" to "croppedImages",
                    "timestamp" to System.currentTimeMillis(),
                    "crops" to croppedImages
                )
                streamHandler.safelySend(eventData)
            }
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ... existing method calls ...
            
            // NEW: Cropping control methods
            "enableCropping" -> {
                val enable = call.argument<Boolean>("enable") ?: false
                yoloView.setEnableCropping(enable)
                result.success(true)
            }
            
            "setCroppingPadding" -> {
                val padding = call.argument<Double>("padding")?.toFloat() ?: 0.1f
                yoloView.setCroppingPadding(padding)
                result.success(true)
            }
            
            "setCroppingQuality" -> {
                val quality = call.argument<Int>("quality") ?: 90
                yoloView.setCroppingQuality(quality)
                result.success(true)
            }
            
            else -> result.notImplemented()
        }
    }
}
```

---

### **Phase 2: Flutter Layer Implementation**

#### Step 2.1: Extend YOLOStreamingConfig

**File**: `lib/yolo_streaming_config.dart`

```dart
class YOLOStreamingConfig {
  // ... existing fields ...
  
  /// Enable automatic cropping of detected objects
  /// When enabled, cropped images will be available in stream data
  final bool enableCropping;
  
  /// Padding percentage around bounding box (0.0 - 1.0)
  /// Default 0.1 = 10% padding around detected object
  final double croppingPadding;
  
  /// JPEG quality for cropped images (1-100)
  /// Higher value = better quality but larger file size
  /// Default 90 for good balance
  final int croppingQuality;
  
  /// Maximum number of crops to include per frame
  /// Useful untuk limit bandwidth when multiple objects detected
  final int? maxCropsPerFrame;
  
  const YOLOStreamingConfig({
    // ... existing params ...
    this.enableCropping = false,
    this.croppingPadding = 0.1,
    this.croppingQuality = 90,
    this.maxCropsPerFrame,
  });
  
  // ... existing methods ...
  
  /// Factory untuk ALPR/License Plate specific configuration
  factory YOLOStreamingConfig.alprOptimized({
    int maxFPS = 30,
    int? inferenceFrequency = 15,
    double croppingPadding = 0.15,  // Sedikit lebih besar untuk plate
    int croppingQuality = 95,        // Higher quality untuk OCR
  }) {
    return YOLOStreamingConfig(
      includeDetections: true,
      includeClassifications: true,
      includeProcessingTimeMs: true,
      includeFps: true,
      includeMasks: false,
      includePoses: false,
      includeOBB: false,
      includeOriginalImage: false,  // Tidak perlu full image
      maxFPS: maxFPS,
      inferenceFrequency: inferenceFrequency,
      enableCropping: true,          // Enable cropping untuk ALPR
      croppingPadding: croppingPadding,
      croppingQuality: croppingQuality,
      maxCropsPerFrame: 5,           // Max 5 plates per frame
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      // ... existing fields ...
      'enableCropping': enableCropping,
      'croppingPadding': croppingPadding,
      'croppingQuality': croppingQuality,
      'maxCropsPerFrame': maxCropsPerFrame,
    };
  }
}
```

#### Step 2.2: Add Cropped Image Model

**File**: `lib/models/yolo_cropped_image.dart` (NEW)

```dart
import 'dart:typed_data';

/// Represents a cropped image from a detection
class YOLOCroppedImage {
  /// Index of detection this crop belongs to
  final int detectionIndex;
  
  /// Class name of detected object
  final String className;
  
  /// Detection confidence (0.0 - 1.0)
  final double confidence;
  
  /// Cropped image as JPEG byte array
  final Uint8List imageBytes;
  
  /// Width of cropped image
  final int width;
  
  /// Height of cropped image
  final int height;
  
  /// Original bounding box coordinates (before cropping)
  final Map<String, double> boundingBox;
  
  const YOLOCroppedImage({
    required this.detectionIndex,
    required this.className,
    required this.confidence,
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.boundingBox,
  });
  
  /// Create from platform map
  factory YOLOCroppedImage.fromMap(Map<dynamic, dynamic> map) {
    return YOLOCroppedImage(
      detectionIndex: map['index'] as int,
      className: map['className'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      imageBytes: map['imageBytes'] as Uint8List,
      width: map['width'] as int,
      height: map['height'] as int,
      boundingBox: Map<String, double>.from(
        map['boundingBox'] as Map<dynamic, dynamic>,
      ),
    );
  }
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'detectionIndex': detectionIndex,
      'className': className,
      'confidence': confidence,
      'imageBytes': imageBytes,
      'width': width,
      'height': height,
      'boundingBox': boundingBox,
    };
  }
  
  @override
  String toString() {
    return 'YOLOCroppedImage(class: $className, conf: ${(confidence * 100).toStringAsFixed(1)}%, size: ${width}x$height)';
  }
}
```

#### Step 2.3: Modify YOLOView Widget

**File**: `lib/yolo_view.dart`

```dart
class YOLOView extends StatefulWidget {
  // ... existing properties ...
  
  /// Callback when cropped images are ready
  /// Only called when streamingConfig.enableCropping = true
  final void Function(List<YOLOCroppedImage> croppedImages)? onCroppedImages;
  
  const YOLOView({
    Key? key,
    // ... existing params ...
    this.onCroppedImages,
  }) : super(key: key);
  
  // ... rest of class ...
}

class _YOLOViewState extends State<YOLOView> {
  // ... existing code ...
  
  void _onPlatformViewCreated(int id) {
    // ... existing setup ...
    
    // Setup cropping configuration
    if (widget.streamingConfig?.enableCropping == true) {
      _setupCroppingConfig();
    }
    
    // ... rest of setup ...
  }
  
  Future<void> _setupCroppingConfig() async {
    try {
      final config = widget.streamingConfig!;
      
      // Enable cropping
      await _methodChannel.invokeMethod('enableCropping', {
        'enable': config.enableCropping,
      });
      
      // Set padding
      await _methodChannel.invokeMethod('setCroppingPadding', {
        'padding': config.croppingPadding,
      });
      
      // Set quality
      await _methodChannel.invokeMethod('setCroppingQuality', {
        'quality': config.croppingQuality,
      });
      
      print('✅ Cropping configuration applied');
    } catch (e) {
      print('Error setting up cropping config: $e');
    }
  }
  
  void _handleStreamData(dynamic data) {
    try {
      final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
      final type = map['type'] as String?;
      
      // Handle cropped images event
      if (type == 'croppedImages') {
        _handleCroppedImages(map);
        return;
      }
      
      // ... existing stream data handling ...
      
    } catch (e) {
      print('Error handling stream data: $e');
    }
  }
  
  void _handleCroppedImages(Map<dynamic, dynamic> data) {
    try {
      final cropsList = data['crops'] as List<dynamic>?;
      if (cropsList == null || cropsList.isEmpty) return;
      
      final croppedImages = cropsList
          .map((crop) => YOLOCroppedImage.fromMap(crop as Map<dynamic, dynamic>))
          .toList();
      
      // Limit crops jika maxCropsPerFrame di-set
      final maxCrops = widget.streamingConfig?.maxCropsPerFrame;
      final limitedCrops = maxCrops != null && croppedImages.length > maxCrops
          ? croppedImages.take(maxCrops).toList()
          : croppedImages;
      
      // Notify callback
      widget.onCroppedImages?.call(limitedCrops);
      
      print('📸 Received ${limitedCrops.length} cropped images');
    } catch (e) {
      print('Error handling cropped images: $e');
    }
  }
}
```

---

### **Phase 3: Usage Example untuk ALPR**

#### Complete ALPR Implementation dengan Cropping

```dart
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ALPRDetectorScreen extends StatefulWidget {
  const ALPRDetectorScreen({Key? key}) : super(key: key);

  @override
  State<ALPRDetectorScreen> createState() => _ALPRDetectorScreenState();
}

class _ALPRDetectorScreenState extends State<ALPRDetectorScreen> {
  final YOLOViewController _controller = YOLOViewController();
  late TextRecognizer _textRecognizer;
  
  String? _detectedPlateText;
  double _detectionConfidence = 0.0;
  int _detectionCount = 0;
  
  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ALPR Detector'),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // YOLO Camera View dengan cropping enabled
          YOLOView(
            modelPath: 'plate_recognation.tflite',  // Model Anda
            task: YOLOTask.detect,
            controller: _controller,
            
            // Confidence settings
            confidenceThreshold: 0.6,
            iouThreshold: 0.4,
            useGpu: true,
            
            // UI settings
            showOverlays: true,   // Show bounding boxes
            showNativeUI: false,  // Hide sliders
            
            // CRITICAL: Enable cropping dengan ALPR-optimized config
            streamingConfig: YOLOStreamingConfig.alprOptimized(
              maxFPS: 30,
              inferenceFrequency: 10,
              croppingPadding: 0.15,   // 15% padding untuk license plates
              croppingQuality: 95,      // High quality untuk OCR
            ),
            
            // Detection callback
            onResult: (List<YOLOResult> results) {
              if (results.isNotEmpty && mounted) {
                setState(() {
                  _detectionCount = results.first.boxes.length;
                  if (results.first.boxes.isNotEmpty) {
                    _detectionConfidence = results.first.boxes.first.conf;
                  }
                });
              }
            },
            
            // CROPPED IMAGES CALLBACK - INI YANG PENTING!
            onCroppedImages: (List<YOLOCroppedImage> croppedImages) {
              // Process setiap cropped image dengan OCR
              for (final crop in croppedImages) {
                _processLicensePlateWithOCR(crop);
              }
            },
          ),
          
          // Result overlay
          _buildResultOverlay(),
        ],
      ),
    );
  }
  
  /// Process cropped license plate dengan Google ML Kit OCR
  Future<void> _processLicensePlateWithOCR(YOLOCroppedImage croppedImage) async {
    try {
      // Hanya process jika confidence tinggi
      if (croppedImage.confidence < 0.7) return;
      
      // Create InputImage dari cropped bytes
      final inputImage = InputImage.fromBytes(
        bytes: croppedImage.imageBytes,
        metadata: InputImageMetadata(
          size: Size(
            croppedImage.width.toDouble(), 
            croppedImage.height.toDouble(),
          ),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.jpeg,
          bytesPerRow: croppedImage.width,
        ),
      );
      
      // Process dengan ML Kit
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isNotEmpty) {
        // Clean text untuk format plat Indonesia
        final cleanedText = _cleanPlateText(recognizedText.text);
        
        if (mounted && cleanedText.isNotEmpty) {
          setState(() {
            _detectedPlateText = cleanedText;
          });
          
          print('🚗 Detected License Plate: $cleanedText');
          print('   Confidence: ${(croppedImage.confidence * 100).toStringAsFixed(1)}%');
          
          // Optional: Save, send to API, etc.
          _onPlateDetected(cleanedText, croppedImage.confidence);
        }
      }
    } catch (e) {
      print('Error processing OCR: $e');
    }
  }
  
  /// Clean OCR text untuk format plat nomor Indonesia
  String _cleanPlateText(String rawText) {
    // Remove non-alphanumeric characters
    String cleaned = rawText
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Validate format plat Indonesia (contoh: B 1234 TOR)
    final platePattern = RegExp(r'^[A-Z]{1,2}\s*\d{1,4}\s*[A-Z]{1,3}$');
    
    return platePattern.hasMatch(cleaned) ? cleaned : '';
  }
  
  /// Called when valid plate detected
  void _onPlateDetected(String plateText, double confidence) {
    // TODO: Implement your logic
    // - Save to database
    // - Send to API
    // - Show notification
    // - Log to file
    // etc.
  }
  
  Widget _buildResultOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚗 ALPR Real-time Detection',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Detections: $_detectionCount',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              'Confidence: ${(_detectionConfidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.blue, fontSize: 14),
            ),
            if (_detectedPlateText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plate Number:',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _detectedPlateText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 TESTING CHECKLIST

```yaml
✅ Phase 1 - Basic Functionality:
  - [ ] Cropping menghasilkan image yang valid
  - [ ] Cropping tidak crash pada berbagai ukuran detection
  - [ ] Padding calculation bekerja dengan benar
  - [ ] Image quality sesuai setting (JPEG compression)

✅ Phase 2 - Performance:
  - [ ] Camera FPS tetap stabil (>25 FPS)
  - [ ] Memory tidak leak setelah extended usage
  - [ ] Cropping tidak block camera stream
  - [ ] OCR processing smooth tanpa lag

✅ Phase 3 - Integration:
  - [ ] Cropped images successfully diterima di Flutter
  - [ ] Google ML Kit OCR bisa read text dengan baik
  - [ ] Multiple plates detected dan processed correctly
  - [ ] Edge cases handled (tiny plates, partial plates, etc.)

✅ Phase 4 - Production Readiness:
  - [ ] Error handling comprehensive
  - [ ] Logging untuk debugging
  - [ ] Configuration options bekerja
  - [ ] Backward compatibility maintained
```

---

## 🎯 EXPECTED RESULTS

Setelah implementation selesai, Anda akan punya:

```dart
✅ REAL-TIME LICENSE PLATE DETECTION:
   - 25-35 FPS detection speed
   - Automatic cropping of detected plates
   - High-quality crops (configurable JPEG quality)
   - Padding control untuk optimal OCR

✅ CLEAN API:
   YOLOView(
     streamingConfig: YOLOStreamingConfig.alprOptimized(),
     onCroppedImages: (crops) {
       // Langsung dapat cropped images siap untuk OCR!
     },
   )

✅ OCR-READY OUTPUT:
   - Pure image tanpa overlay/label
   - Optimal size dan quality untuk ML Kit
   - Configurable padding untuk better results
   - Automatic cleanup untuk memory efficiency

✅ PRODUCTION FEATURES:
   - Error handling
   - Performance optimization
   - Backward compatible
   - Extensible untuk future needs
```

---

## 🚀 NEXT STEPS

1. **Start with Android Implementation** (Step 1.1 - 1.3)
2. **Test Cropping Functionality** menggunakan existing example app
3. **Add Flutter Layer** (Step 2.1 - 2.3)
4. **Integrate Google ML Kit OCR** (Phase 3 example)
5. **Test End-to-End** dengan real license plates
6. **Optimize Performance** berdasarkan testing results

**Estimasi waktu**: 2-3 hari untuk full implementation dan testing.

Mau saya mulai implement step pertama (ImageCropper utility)?
