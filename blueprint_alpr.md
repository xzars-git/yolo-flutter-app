# 🚀 Custom ALPR Blueprint - Modular Architecture (Low-End Optimized)

> **Zero dependency on ultralytics_yolo** | **Production-ready** | **Modular & Maintainable**

---

## ⚡ SYSTEM BEHAVIOR: CONTINUOUS LIVE DETECTION

**CRITICAL: This system performs AUTOMATIC, CONTINUOUS live detection:**

```
🎥 CAMERA STREAM BEHAVIOR:
├─ Camera runs at 30 FPS (frames per second)
├─ Frames processed automatically every 1 second (cooldown to prevent overload)
├─ NO manual "scan" button required
├─ NO photo picker - direct camera stream only
├─ Detection happens AUTOMATICALLY while camera is active
└─ Results update in REAL-TIME on screen overlay

� DETECTION FLOW:
1. Camera starts → controller.startImageStream() called
2. Every frame (30 FPS) sent to _handleCameraImage callback
3. Frame cooldown (1000ms) prevents overwhelming worker isolate
4. Worker isolate processes frame through 7-step pipeline
5. Result streams update UI automatically
6. Detection overlay appears when plate found
7. Process repeats continuously until camera stops

❌ WHAT THIS SYSTEM DOES NOT DO:
├─ NO button to "scan" each frame
├─ NO image picker for photo selection
├─ NO manual trigger per detection
└─ NO photo-based processing

✅ WHAT THIS SYSTEM DOES:
├─ AUTOMATIC continuous frame processing
├─ LIVE camera stream (30 FPS capture, 1 FPS processing)
├─ REAL-TIME result overlay updates
└─ INSTANT detection feedback
```

---

## �📱 Target Specifications

| Category | Specification |
|----------|---------------|
| **Device Target** | Low-end to Medium Android phones |
| **RAM** | 2-4 GB |
| **Processor** | Snapdragon 4xx / MediaTek Helio |
| **Model Type** | **TFLite Float32** (best_float32.tflite) |
| **Model Size** | ~5-10 MB |
| **Performance Goal** | Detection + OCR < 2 seconds |
| **UI Requirement** | Smooth, no lag (60 FPS preview) |
| **Camera Mode** | **LIVE STREAM (continuous automatic detection)** |

---

## 🎯 Model Configuration: best_float32.tflite

### **Why Float32 Model?**

```
✅ ADVANTAGES:
├─ Better accuracy (no quantization loss)
├─ Wider device compatibility
├─ Stable inference results
├─ Easier debugging
├─ Excellent NNAPI support on Android
└─ Predictable performance across devices

⚠️ TRADE-OFFS:
├─ Larger model size (~2x vs int8)
├─ Slightly slower inference (~1.2x vs quantized)
└─ Higher memory usage (~10MB vs ~5MB)

📊 VERDICT: BEST choice for low-end devices!
   Reason: 
   - Accuracy > Speed for ALPR use case
   - 100ms speed difference acceptable for 2s target
   - Better confidence scores = less false positives
   - Float32 works better with NNAPI hardware acceleration
```

### **Model Specifications**

```yaml
Model Information:
  Path: android/app/src/main/assets/plat_recognation.tflite
  Type: TFLite Float32 (best_float32)
  Architecture: YOLO-based (YOLOv8/v5 assumed)
  Size: ~5-10 MB
  
Input Specification:
  Shape: [1, 320, 320, 3]
  Data Type: float32
  Format: RGB (interleaved)
  Value Range: [0.0, 1.0] (normalized)
  Color Order: Red, Green, Blue
  
Output Specification:
  Shape: [1, N, 6] or [1, 25200, 6]
  Data Type: float32
  Format Per Detection:
    - Index 0: x_center (normalized 0-1)
    - Index 1: y_center (normalized 0-1)
    - Index 2: width (normalized 0-1)
    - Index 3: height (normalized 0-1)
    - Index 4: objectness confidence
    - Index 5: class probability
  
Hardware Acceleration:
  Primary: NNAPI Delegate (Android Neural Networks API)
  Fallback: CPU with 2 threads
  GPU: Optional via NNAPI if available
  
Expected Performance (Float32):
  Low-end device: 200-500ms per inference
  Medium device: 150-300ms per inference
  High-end device: 80-150ms per inference
```

---

## 🏗️ Modular Project Structure

```
lib/
│
├── features/
│   └── alpr/
│       │
│       ├── presentation/                    # UI Layer
│       │   │
│       │   ├── widgets/
│       │   │   ├── custom_alpr_view.dart
│       │   │   │   Purpose: Main camera view widget
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Display camera preview
│       │   │   │   ├─ Coordinate with services
│       │   │   │   ├─ Handle user interactions
│       │   │   │   ├─ Manage UI state
│       │   │   │   └─ Compose all overlay widgets
│       │   │   │
│       │   │   ├── bounding_box_painter.dart
│       │   │   │   Purpose: CustomPainter for detection overlay
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Draw bounding box rectangle
│       │   │   │   ├─ Draw corner markers
│       │   │   │   ├─ Draw confidence label
│       │   │   │   └─ Handle coordinate transformations
│       │   │   │
│       │   │   ├── plate_result_card.dart
│       │   │   │   Purpose: Display OCR result
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Show plate text (large, readable)
│       │   │   │   ├─ Display confidence percentage
│       │   │   │   ├─ Show processing time
│       │   │   │   ├─ Provide "Scan Again" button
│       │   │   │   └─ Animate entrance (slide + fade)
│       │   │   │
│       │   │   ├── loading_overlay.dart
│       │   │   │   Purpose: Processing indicator
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Show loading spinner
│       │   │   │   ├─ Display processing status
│       │   │   │   ├─ Semi-transparent background
│       │   │   │   └─ Animated status text
│       │   │   │
│       │   │   └── status_bar_widget.dart
│       │   │       Purpose: Top status indicator
│       │   │       Responsibilities:
│       │   │       ├─ Show current status (Ready/Processing/Error)
│       │   │       ├─ Display FPS counter (debug mode)
│       │   │       └─ Show processing time
│       │   │
│       │   └── pages/
│       │       └── alpr_scanner_page.dart
│       │           Purpose: Full-page wrapper
│       │           Responsibilities:
│       │           ├─ Scaffold with AppBar
│       │           ├─ Embed CustomALPRView
│       │           ├─ Handle navigation
│       │           └─ Manage page lifecycle
│       │
│       ├── domain/                          # Business Logic Layer
│       │   │
│       │   ├── models/
│       │   │   ├── plate_detection.dart
│       │   │   │   Purpose: Detection result model
│       │   │   │   Properties:
│       │   │   │   ├─ Rect boundingBox (pixel coordinates)
│       │   │   │   ├─ double confidence (0.0 - 1.0)
│       │   │   │   ├─ String? text (OCR result)
│       │   │   │   ├─ int frameId
│       │   │   │   └─ DateTime timestamp
│       │   │   │
│       │   │   ├── worker_message.dart
│       │   │   │   Purpose: Message sent TO worker isolate
│       │   │   │   Properties:
│       │   │   │   ├─ String type ('frame', 'shutdown', 'config')
│       │   │   │   ├─ dynamic data (serialized image data)
│       │   │   │   ├─ int frameId
│       │   │   │   └─ DateTime timestamp
│       │   │   │
│       │   │   ├── worker_result.dart
│       │   │   │   Purpose: Result sent FROM worker isolate
│       │   │   │   Properties:
│       │   │   │   ├─ String type ('success', 'error', 'no_detection')
│       │   │   │   ├─ List<PlateDetection> detections
│       │   │   │   ├─ int frameId
│       │   │   │   ├─ int processingTime (milliseconds)
│       │   │   │   └─ String? error (if type == 'error')
│       │   │   │
│       │   │   └── processing_config.dart
│       │   │       Purpose: Configuration for processing pipeline
│       │   │       Properties:
│       │   │       ├─ double confidenceThreshold (default: 0.5)
│       │   │       ├─ double iouThreshold (default: 0.4)
│       │   │       ├─ int inputSize (default: 320)
│       │   │       ├─ bool useNNAPI (default: true)
│       │   │       ├─ int numThreads (default: 2)
│       │   │       └─ Duration frameCooldown (default: 1 second)
│       │   │
│       │   └── repositories/
│       │       └── alpr_repository.dart
│       │           Purpose: Abstract interface for ALPR operations
│       │           Methods:
│       │           ├─ Future<void> initialize()
│       │           ├─ Stream<PlateDetection> processFrame(CameraImage)
│       │           ├─ Future<void> dispose()
│       │           └─ ProcessingConfig getConfig()
│       │
│       ├── data/                            # Data Layer
│       │   │
│       │   ├── services/
│       │   │   ├── camera_service.dart
│       │   │   │   Purpose: Camera initialization & management
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Initialize CameraController
│       │   │   │   │  ├─ Resolution: ResolutionPreset.medium (640x480)
│       │   │   │   │  ├─ FPS: 30 (for smooth preview)
│       │   │   │   │  ├─ Format: ImageFormatGroup.yuv420
│       │   │   │   │  └─ Camera: back camera
│       │   │   │   ├─ Start image stream
│       │   │   │   ├─ Provide camera controller for preview
│       │   │   │   ├─ Handle camera errors
│       │   │   │   └─ Dispose camera properly
│       │   │   │   
│       │   │   │   Key Features:
│       │   │   │   ├─ Auto-select best back camera
│       │   │   │   ├─ Graceful degradation if medium fails
│       │   │   │   ├─ Error recovery & retry logic
│       │   │   │   └─ Proper lifecycle management
│       │   │   │
│       │   │   ├── worker_isolate_service.dart
│       │   │   │   Purpose: Manage worker isolate lifecycle
│       │   │   │   Responsibilities:
│       │   │   │   ├─ Spawn worker isolate on initialization
│       │   │   │   ├─ Setup bidirectional communication
│       │   │   │   │  ├─ SendPort (main → worker)
│       │   │   │   │  └─ ReceivePort (worker → main)
│       │   │   │   ├─ Send frames to worker with proper serialization
│       │   │   │   ├─ Receive & parse results from worker
│       │   │   │   ├─ Handle worker errors & crashes
│       │   │   │   ├─ Implement timeout mechanism (5s max)
│       │   │   │   ├─ Queue management (max 1 pending frame)
│       │   │   │   └─ Graceful shutdown
│       │   │   │   
│       │   │   │   Key Features:
│       │   │   │   ├─ Single pending frame (drop old on new)
│       │   │   │   ├─ Auto-restart worker on crash
│       │   │   │   ├─ Timeout protection
│       │   │   │   └─ Clean shutdown sequence
│       │   │   │
│       │   │   └── performance_monitor.dart
│       │   │       Purpose: Track performance metrics
│       │   │       Responsibilities:
│       │   │       ├─ Track processed frame count
│       │   │       ├─ Track dropped frame count
│       │   │       ├─ Calculate average inference time
│       │   │       ├─ Calculate current FPS
│       │   │       ├─ Monitor memory usage (optional)
│       │   │       ├─ Track success/failure rate
│       │   │       └─ Provide real-time metrics
│       │   │       
│       │   │       Metrics Exposed:
│       │   │       ├─ int totalFrames
│       │   │       ├─ int processedFrames
│       │   │       ├─ int droppedFrames
│       │   │       ├─ double avgInferenceTime
│       │   │       ├─ double currentFPS
│       │   │       ├─ double successRate
│       │   │       └─ DateTime lastUpdate
│       │   │
│       │   └── repositories/
│       │       └── alpr_repository_impl.dart
│       │           Purpose: Implement ALPRRepository interface
│       │           Responsibilities:
│       │           ├─ Coordinate camera & worker services
│       │           ├─ Apply business rules
│       │           ├─ Transform data between layers
│       │           └─ Handle errors gracefully
│       │
│       └── core/                            # Core Processing Layer
│           │
│           ├── workers/
│           │   └── detection_worker.dart
│           │       Purpose: Worker isolate entry point
│           │       Responsibilities:
│           │       ├─ Initialize all processors
│           │       ├─ Setup communication ports
│           │       ├─ Listen for frame messages
│           │       ├─ Execute processing pipeline
│           │       ├─ Send results back to main
│           │       ├─ Handle shutdown signal
│           │       └─ Catch & report errors
│           │       
│           │       Pipeline Sequence:
│           │       1. Receive frame message
│           │       2. ImagePreprocessor.process()
│           │       3. TFLiteDetector.detect()
│           │       4. YoloParser.parse()
│           │       5. NmsProcessor.process()
│           │       6. RoiExtractor.extract()
│           │       7. OcrProcessor.recognize()
│           │       8. TextValidator.validate()
│           │       9. Send WorkerResult back
│           │
│           ├── processing/
│           │   │
│           │   ├── image_preprocessor.dart
│           │   │   Purpose: Prepare image for TFLite inference
│           │   │   
│           │   │   Input:
│           │   │   ├─ Uint8List imageData (YUV420 format)
│           │   │   ├─ int width (original, e.g., 640)
│           │   │   └─ int height (original, e.g., 480)
│           │   │   
│           │   │   Processing Steps:
│           │   │   1. YUV420 → RGB888 Conversion
│           │   │      ├─ Extract Y plane (luminance)
│           │   │      ├─ Extract U plane (chrominance blue)
│           │   │      ├─ Extract V plane (chrominance red)
│           │   │      └─ Apply ITU-R BT.601 conversion formula:
│           │   │         R = Y + 1.402 * (V - 128)
│           │   │         G = Y - 0.344 * (U - 128) - 0.714 * (V - 128)
│           │   │         B = Y + 1.772 * (U - 128)
│           │   │   
│           │   │   2. Resize to Model Input Size (320x320)
│           │   │      ├─ Use nearest-neighbor interpolation (fastest)
│           │   │      ├─ Alternative: bilinear (better quality, slower)
│           │   │      └─ Maintain aspect ratio or stretch (config)
│           │   │   
│           │   │   3. Normalize to [0.0, 1.0]
│           │   │      └─ For each pixel: value / 255.0
│           │   │   
│           │   │   Output:
│           │   │   └─ Float32List [1, 320, 320, 3] (interleaved RGB)
│           │   │   
│           │   │   Performance Target: 50-120ms
│           │   │   Optimizations:
│           │   │   ├─ Use lookup tables for YUV conversion
│           │   │   ├─ Single-pass processing
│           │   │   ├─ Pre-allocate buffers
│           │   │   └─ Clamp values inline
│           │   │
│           │   ├── tflite_detector.dart
│           │   │   Purpose: Run inference on best_float32.tflite
│           │   │   
│           │   │   Initialization:
│           │   │   ├─ Load model from assets
│           │   │   │  └─ Path: 'plat_recognation.tflite'
│           │   │   ├─ Configure interpreter options:
│           │   │   │  ├─ Threads: 2
│           │   │   │  ├─ UseNNAPI: true
│           │   │   │  ├─ Delegates: [NnApiDelegate()]
│           │   │   │  └─ AllowFp16: true (if supported)
│           │   │   ├─ Create interpreter
│           │   │   ├─ Get input tensor shape [1, 320, 320, 3]
│           │   │   ├─ Get output tensor shape [1, N, 6]
│           │   │   ├─ Allocate tensors
│           │   │   └─ Warmup with dummy inference
│           │   │   
│           │   │   Detection:
│           │   │   ├─ Receive Float32List input
│           │   │   ├─ Reshape to [1, 320, 320, 3]
│           │   │   ├─ Allocate output buffer [1, N, 6]
│           │   │   ├─ Run: interpreter.run(input, output)
│           │   │   └─ Return raw output
│           │   │   
│           │   │   Performance Target: 200-500ms
│           │   │   
│           │   │   NNAPI Benefits:
│           │   │   ├─ Automatic hardware acceleration
│           │   │   ├─ GPU offloading if available
│           │   │   ├─ DSP usage if supported
│           │   │   └─ 2-3x speedup on compatible devices
│           │   │   
│           │   │   Error Handling:
│           │   │   ├─ Fallback to CPU if NNAPI fails
│           │   │   ├─ Retry mechanism for transient errors
│           │   │   └─ Graceful degradation
│           │   │
│           │   ├── yolo_parser.dart
│           │   │   Purpose: Parse raw YOLO output to detections
│           │   │   
│           │   │   Input Format:
│           │   │   └─ List [1, N, 6] where each detection:
│           │   │      [0] x_center (normalized 0-1)
│           │   │      [1] y_center (normalized 0-1)
│           │   │      [2] width (normalized 0-1)
│           │   │      [3] height (normalized 0-1)
│           │   │      [4] objectness confidence
│           │   │      [5] class probability
│           │   │   
│           │   │   Processing Steps:
│           │   │   1. Iterate through all N detections
│           │   │   
│           │   │   2. For each detection:
│           │   │      ├─ Calculate final confidence:
│           │   │      │  └─ conf = objectness * class_prob
│           │   │      │
│           │   │      ├─ Filter by threshold:
│           │   │      │  └─ if conf < 0.5: skip
│           │   │      │
│           │   │      └─ Convert to corner format:
│           │   │         ├─ xMin = x_center - width / 2
│           │   │         ├─ yMin = y_center - height / 2
│           │   │         ├─ xMax = x_center + width / 2
│           │   │         └─ yMax = y_center + height / 2
│           │   │   
│           │   │   3. Convert normalized coords to pixels:
│           │   │      ├─ xMin_px = xMin * imageWidth
│           │   │      ├─ yMin_px = yMin * imageHeight
│           │   │      ├─ xMax_px = xMax * imageWidth
│           │   │      └─ yMax_px = yMax * imageHeight
│           │   │   
│           │   │   Output:
│           │   │   └─ List<Detection> with pixel coordinates
│           │   │   
│           │   │   Performance Target: 5-10ms
│           │   │
│           │   ├── nms_processor.dart
│           │   │   Purpose: Non-Maximum Suppression
│           │   │   
│           │   │   Input:
│           │   │   └─ List<Detection> (possibly overlapping)
│           │   │   
│           │   │   Algorithm:
│           │   │   1. Sort detections by confidence (descending)
│           │   │   
│           │   │   2. For each detection (highest conf first):
│           │   │      ├─ Keep this detection
│           │   │      └─ Suppress all overlapping detections:
│           │   │         └─ if IoU > threshold (0.4): remove
│           │   │   
│           │   │   IoU Calculation:
│           │   │   ├─ intersection = overlap area
│           │   │   ├─ union = area_A + area_B - intersection
│           │   │   └─ IoU = intersection / union
│           │   │   
│           │   │   Output:
│           │   │   └─ List<Detection> (non-overlapping)
│           │   │      └─ For ALPR: typically 1 best detection
│           │   │   
│           │   │   Performance Target: 5-15ms
│           │   │   
│           │   │   Configuration:
│           │   │   └─ IoU threshold: 0.4 (configurable)
│           │   │
│           │   ├── roi_extractor.dart
│           │   │   Purpose: Extract & enhance plate region
│           │   │   
│           │   │   Input:
│           │   │   ├─ Original image (RGB)
│           │   │   ├─ Image dimensions
│           │   │   └─ Detection bounding box
│           │   │   
│           │   │   Processing Steps:
│           │   │   1. Add Padding (10%)
│           │   │      ├─ Expand bbox by 10% on all sides
│           │   │      ├─ Provides context for OCR
│           │   │      └─ Clamp to image bounds
│           │   │   
│           │   │   2. Crop Image
│           │   │      └─ Extract rectangle from original image
│           │   │   
│           │   │   3. Enhancement (Optional)
│           │   │      ├─ Contrast enhancement (CLAHE)
│           │   │      ├─ Sharpening
│           │   │      └─ Denoising
│           │   │      Note: Skip if OCR already accurate
│           │   │   
│           │   │   4. Resize if Too Small
│           │   │      └─ Min height: 50px for good OCR
│           │   │   
│           │   │   Output:
│           │   │   └─ Uint8List (PNG/JPEG encoded image)
│           │   │   
│           │   │   Performance Target: 10-25ms
│           │   │   
│           │   │   Quality Settings:
│           │   │   ├─ Padding: 10% (balance context vs noise)
│           │   │   ├─ Min size: 50px height
│           │   │   └─ Enhancement: Optional (test accuracy)
│           │   │
│           │   ├── ocr_processor.dart
│           │   │   Purpose: Extract text using ML Kit
│           │   │   
│           │   │   Initialization:
│           │   │   └─ TextRecognizer(
│           │   │        script: TextRecognitionScript.latin
│           │   │      )
│           │   │   
│           │   │   Processing Steps:
│           │   │   1. Convert image to InputImage
│           │   │      ├─ From bytes (Uint8List)
│           │   │      └─ With metadata (width, height, format)
│           │   │   
│           │   │   2. Run ML Kit Recognition
│           │   │      └─ recognizedText = await recognizer
│           │   │           .processImage(inputImage)
│           │   │   
│           │   │   3. Extract Text Blocks
│           │   │      ├─ Iterate through blocks
│           │   │      ├─ Iterate through lines
│           │   │      ├─ Concatenate all text
│           │   │      └─ Remove line breaks
│           │   │   
│           │   │   4. Initial Cleaning
│           │   │      ├─ Remove extra spaces
│           │   │      ├─ Convert to uppercase
│           │   │      └─ Keep alphanumeric + spaces
│           │   │   
│           │   │   Output:
│           │   │   └─ String (raw OCR text)
│           │   │   
│           │   │   Performance Target: 400-900ms
│           │   │   
│           │   │   ML Kit Configuration:
│           │   │   ├─ Script: Latin (faster than default)
│           │   │   ├─ Mode: Accurate (not Fast)
│           │   │   └─ Language: Not specified (auto-detect)
│           │   │   
│           │   │   Performance Notes:
│           │   │   ├─ First call: slower (model loading)
│           │   │   ├─ Subsequent: faster (cached)
│           │   │   └─ Cannot be optimized much (Google SDK)
│           │   │
│           │   └── text_validator.dart
│           │       Purpose: Validate & format plate text
│           │       
│           │       Input:
│           │       ├─ String rawText (from OCR)
│           │       └─ double detectionConfidence
│           │       
│           │       Processing Steps:
│           │       1. Clean Text
│           │          ├─ Remove all spaces
│           │          ├─ Remove special characters
│           │          ├─ Keep only: A-Z, 0-9
│           │          └─ Convert to uppercase
│           │       
│           │       2. Validate Indonesian Plate Format
│           │          Pattern: ^[A-Z]{1,2}\d{1,4}[A-Z]{1,3}$
│           │          
│           │          Valid Examples:
│           │          ├─ B1234ABC
│           │          ├─ DK567XY
│           │          ├─ F12Z
│           │          └─ AA9999ZZZ
│           │          
│           │          Invalid Examples:
│           │          ├─ ABC123 (wrong order)
│           │          ├─ 1234ABC (no prefix)
│           │          └─ B (incomplete)
│           │       
│           │       3. Calculate Final Confidence
│           │          Components:
│           │          ├─ Detection confidence: 60% weight
│           │          ├─ Format match: 30% weight
│           │          └─ Length check: 10% weight
│           │          
│           │          Formula:
│           │          final_conf = 
│           │            detection_conf * 0.6 +
│           │            (format_valid ? 0.3 : 0) +
│           │            (length_ok ? 0.1 : 0)
│           │       
│           │       4. Format Output
│           │          ├─ Add spaces: "B 1234 ABC"
│           │          ├─ Uppercase all letters
│           │          └─ Standard Indonesian format
│           │       
│           │       Output:
│           │       └─ ValidationResult {
│           │            String formattedText;
│           │            double finalConfidence;
│           │            bool isValid;
│           │          }
│           │       
│           │       Performance Target: 5-10ms
│           │       
│           │       Configuration:
│           │       ├─ Min confidence: 0.5 (reject below)
│           │       ├─ Min length: 5 characters
│           │       └─ Max length: 10 characters
│           │
│           ├── utils/
│           │   │
│           │   ├── camera_image_serializer.dart
│           │   │   Purpose: Convert CameraImage to transferable data
│           │   │   
│           │   │   Responsibilities:
│           │   │   ├─ Extract planes from CameraImage
│           │   │   ├─ Serialize YUV420 data
│           │   │   ├─ Handle different formats (YUV, BGRA)
│           │   │   ├─ Pack metadata (width, height, format)
│           │   │   └─ Create Uint8List for isolate transfer
│           │   │   
│           │   │   YUV420 Format:
│           │   │   ├─ Y plane: width * height bytes
│           │   │   ├─ U plane: (width/2) * (height/2) bytes
│           │   │   └─ V plane: (width/2) * (height/2) bytes
│           │   │   
│           │   │   Performance: <10ms
│           │   │
│           │   ├── image_converter.dart
│           │   │   Purpose: Image format conversions
│           │   │   
│           │   │   Utilities:
│           │   │   ├─ YUV → RGB conversion
│           │   │   ├─ RGB → Grayscale
│           │   │   ├─ Image encoding (PNG, JPEG)
│           │   │   ├─ Image decoding
│           │   │   └─ Format detection
│           │   │   
│           │   │   Use Cases:
│           │   │   ├─ Preprocessing pipeline
│           │   │   ├─ ROI extraction
│           │   │   └─ OCR preparation
│           │   │
│           │   ├── bbox_calculator.dart
│           │   │   Purpose: Bounding box utilities
│           │   │   
│           │   │   Functions:
│           │   │   ├─ calculateIoU(boxA, boxB)
│           │   │   │  └─ Intersection over Union calculation
│           │   │   ├─ convertNormalizedToPixels(bbox, width, height)
│           │   │   │  └─ Convert [0,1] coords to pixel coords
│           │   │   ├─ convertCenterToCorner(x, y, w, h)
│           │   │   │  └─ Center format → corner format
│           │   │   ├─ addPadding(bbox, percent)
│           │   │   │  └─ Expand bbox by percentage
│           │   │   ├─ clampToImageBounds(bbox, width, height)
│           │   │   │  └─ Ensure bbox within image
│           │   │   └─ calculateArea(bbox)
│           │   │      └─ Get bbox area in pixels
│           │   │
│           │   └── indonesian_plate_regex.dart
│           │       Purpose: Indonesian plate format validation
│           │       
│           │       Patterns:
│           │       ├─ Standard: ^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$
│           │       ├─ Motorcycle: ^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,2}$
│           │       ├─ Government: ^[A-Z]{2}\s?\d{1,4}\s?[A-Z]{3}$
│           │       └─ Special: Custom patterns
│           │       
│           │       Functions:
│           │       ├─ isValidIndonesianPlate(text)
│           │       ├─ extractPlateType(text)
│           │       ├─ formatPlateText(text)
│           │       └─ suggestCorrections(text)
│           │
│           └── constants/
│               │
│               ├── model_constants.dart
│               │   Purpose: Model-related configuration
│               │   
│               │   Constants:
│               │   ├─ MODEL_PATH = 'plat_recognation.tflite'
│               │   ├─ MODEL_TYPE = 'float32'
│               │   ├─ INPUT_SIZE = 320
│               │   ├─ INPUT_SHAPE = [1, 320, 320, 3]
│               │   ├─ OUTPUT_SHAPE = [1, 25200, 6]
│               │   ├─ NUM_CLASSES = 1
│               │   └─ CLASS_NAMES = ['license_plate']
│               │
│               ├── processing_constants.dart
│               │   Purpose: Processing pipeline configuration
│               │   
│               │   Constants:
│               │   ├─ CONFIDENCE_THRESHOLD = 0.5
│               │   ├─ IOU_THRESHOLD = 0.4
│               │   ├─ NMS_MAX_DETECTIONS = 1
│               │   ├─ ROI_PADDING_PERCENT = 0.1
│               │   ├─ MIN_OCR_HEIGHT = 50
│               │   ├─ FRAME_COOLDOWN_MS = 1000
│               │   ├─ WORKER_TIMEOUT_MS = 5000
│               │   ├─ NUM_THREADS = 2
│               │   ├─ USE_NNAPI = true
│               │   └─ ALLOW_FP16 = true
│               │
│               └── ui_constants.dart
│                   Purpose: UI styling & colors
│                   
│                   Colors:
│                   ├─ PRIMARY_COLOR = Colors.blue[700]
│                   ├─ ACCENT_COLOR = Colors.green[500]
│                   ├─ BBOX_COLOR = Colors.green
│                   ├─ LOADING_COLOR = Colors.white70
│                   └─ ERROR_COLOR = Colors.red[400]
│                   
│                   Dimensions:
│                   ├─ BBOX_STROKE_WIDTH = 3.0
│                   ├─ CORNER_MARKER_LENGTH = 20.0
│                   ├─ RESULT_CARD_PADDING = 24.0
│                   └─ STATUS_BAR_HEIGHT = 60.0
│                   
│                   Animations:
│                   ├─ SLIDE_DURATION = 300ms
│                   ├─ FADE_DURATION = 200ms
│                   └─ LOADING_ROTATION_DURATION = 1000ms
│
└── main.dart
    Purpose: App entry point
    Responsibilities:
    ├─ Initialize Flutter app
    ├─ Setup camera permissions
    ├─ Configure routing
    └─ Launch ALPRScannerPage

assets/
└── plat_recognation.tflite              # Best Float32 model
```

---

## 📊 Complete Processing Flow

### **User Journey**

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: APP LAUNCH                                          │
├─────────────────────────────────────────────────────────────┤
│ 1. User opens app                                           │
│ 2. Request camera permissions                               │
│ 3. Initialize CameraService                                 │
│    ├─ Select back camera                                    │
│    ├─ Set resolution: 640x480                               │
│    └─ Start preview (30 FPS)                                │
│ 4. Initialize WorkerIsolateService                          │
│    ├─ Spawn worker isolate                                  │
│    ├─ Load best_float32.tflite model                        │
│    ├─ Initialize ML Kit OCR                                 │
│    └─ Wait for ready signal                                 │
│ 5. Show camera preview                                      │
│    └─ Status: "Ready to scan"                               │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: POINT CAMERA AT PLATE                               │
├─────────────────────────────────────────────────────────────┤
│ 1. User points camera at license plate                      │
│ 2. Preview shows live feed (smooth 30 FPS)                  │
│ 3. Frame throttling active:                                 │
│    ├─ Capture 1 frame per second                            │
│    ├─ Skip frames if worker busy                            │
│    └─ Cooldown: 1 second between captures                   │
│ 4. Status: "Align plate in view"                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: AUTO CAPTURE (or Manual Tap)                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Trigger capture:                                         │
│    ├─ Auto: After 1 second stabilization                    │
│    └─ Manual: User taps "SCAN" button                       │
│ 2. Serialize camera frame                                   │
│ 3. Send to worker isolate                                   │
│ 4. Show loading overlay                                     │
│    └─ "Processing..."                                       │
│ 5. Disable further captures                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: WORKER PROCESSING (1-2 seconds)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Phase 1: PRE-PROCESSING (50-120ms)                         │
│ ├─ YUV420 → RGB conversion                                 │
│ ├─ Resize 640x480 → 320x320                                │
│ └─ Normalize to [0.0, 1.0]                                 │
│ Status: "Preparing image..."                                │
│                                                             │
│ Phase 2: DETECTION (200-500ms)                             │
│ ├─ TFLite inference (best_float32)                         │
│ ├─ Parse YOLO output                                        │
│ ├─ Filter confidence > 0.5                                  │
│ └─ Apply NMS (keep best)                                    │
│ Status: "Detecting plate..."                                │
│                                                             │
│ Phase 3: ROI EXTRACTION (10-25ms)                          │
│ ├─ Crop plate region                                        │
│ ├─ Add 10% padding                                          │
│ └─ Enhance (optional)                                       │
│ Status: "Analyzing..."                                      │
│                                                             │
│ Phase 4: OCR (400-900ms)                                   │
│ ├─ Convert to InputImage                                    │
│ ├─ ML Kit text recognition                                  │
│ └─ Extract text blocks                                      │
│ Status: "Reading characters..."                             │
│                                                             │
│ Phase 5: VALIDATION (5-10ms)                               │
│ ├─ Clean text                                               │
│ ├─ Validate format                                          │
│ ├─ Calculate confidence                                     │
│ └─ Format output                                            │
│ Status: "Validating..."                                     │
│                                                             │
│ TOTAL: 700ms - 1.6 seconds                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: RESULT DISPLAY                                      │
├─────────────────────────────────────────────────────────────┤
│ 1. Receive WorkerResult                                     │
│ 2. Hide loading overlay                                     │
│ 3. Draw bounding box (green)                                │
│    └─ CustomPaint overlay on preview                        │
│ 4. Show PlateResultCard (slide up animation)               │
│    ├─ Plate Text: "B 1234 ABC"                             │
│    ├─ Confidence: 87%                                       │
│    ├─ Processing Time: 1.2s                                │
│    └─ Button: "Scan Again"                                 │
│ 5. Status: "Detection complete!"                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 6: USER ACTION                                         │
├─────────────────────────────────────────────────────────────┤
│ Option A: Result Correct                                    │
│ ├─ User taps "Save" or "Continue"                          │
│ ├─ Store result in database                                │
│ └─ Navigate to next screen                                 │
│                                                             │
│ Option B: Result Incorrect                                  │
│ ├─ User taps "Scan Again"                                  │
│ ├─ Clear current detection                                 │
│ ├─ Re-enable camera capture                                │
│ └─ Return to STEP 2                                        │
│                                                             │
│ Option C: Manual Edit                                       │
│ ├─ User taps "Edit"                                        │
│ ├─ Show text input dialog                                  │
│ ├─ User corrects text                                      │
│ └─ Save edited result                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Architecture

### **Main Thread ↔ Worker Isolate Communication**

```
MAIN ISOLATE                           WORKER ISOLATE
    │                                       │
    │  1. Initialize                       │
    ├──────── Spawn Worker ────────────────>
    │                                       ├─ Load TFLite
    │                                       ├─ Initialize ML Kit
    │                                       └─ Create ReceivePort
    │                                       │
    │  2. Handshake                         │
    <──────── SendPort ─────────────────────┤
    │                                       │
    │  3. Processing Loop                   │
    │                                       │
    ├──────── WorkerMessage ────────────────>
    │         {                              │
    │           type: 'frame'                ├─ Deserialize
    │           data: {                      ├─ Preprocess
    │             image: Uint8List           ├─ Detect (TFLite)
    │             width: 640                 ├─ Parse Output
    │             height: 480                ├─ NMS
    │           }                            ├─ Extract ROI
    │           frameId: 123                 ├─ OCR (ML Kit)
    │           timestamp: DateTime          └─ Validate
    │         }                              │
    │                                       │
    │  4. Result                             │
    <──────── WorkerResult ─────────────────┤
    │         {                              │
    │           type: 'success'              │
    │           detections: [...]            │
    │           frameId: 123                 │
    │           processingTime: 1200         │
    │         }                              │
    │                                       │
    ├─ Update UI                            │
    ├─ Draw Bbox                            │
    ├─ Show Result                          │
    └─ Enable Next Capture                  │
    │                                       │
    │  5. Shutdown                           │
    ├──────── WorkerMessage ────────────────>
    │         {                              │
    │           type: 'shutdown'             ├─ Cleanup
    │         }                              ├─ Close TFLite
    │                                       ├─ Close ML Kit
    <──────── Confirmation ─────────────────┤
    │                                       │
    ├─ Kill Isolate                         └─ Exit
    └─ Cleanup                              
```

---

## ⚙️ Configuration & Optimization

### **Camera Configuration**

```yaml
Camera Settings:
  Resolution: ResolutionPreset.medium
  Actual Size: 640 x 480 pixels
  FPS: 30 (preview only)
  Format: ImageFormatGroup.yuv420
  Camera: Back camera (index 0)
  
Processing Rate:
  Capture Rate: 1 frame per second
  Processing Rate: 1 frame per 1-2 seconds
  Drop Strategy: Skip frames if worker busy
  Cooldown: 1 second after each processing
  
Rationale:
  ├─ 640x480: Good balance (quality vs performance)
  ├─ 30 FPS preview: Smooth user experience
  ├─ 1 FPS processing: Sufficient for ALPR
  └─ YUV420: Native Android format (no conversion)
```

### **TFLite Configuration (best_float32.tflite)**

```yaml
Model Configuration:
  Type: Float32 (not quantized)
  Input: [1, 320, 320, 3]
  Output: [1, N, 6]
  Size: ~5-10 MB
  
Interpreter Options:
  Threads: 2
  UseNNAPI: true
  Delegates: [NnApiDelegate()]
  AllowFp16: true (if device supports)
  AllowBufferHandling: true
  
NNAPI Delegate:
  Purpose: Hardware acceleration
  Benefits:
    ├─ Automatic GPU offloading
    ├─ DSP utilization if available
    ├─ 2-3x speed improvement
    └─ Better battery efficiency
  Fallback: CPU with 2 threads
  
Performance Tuning:
  ├─ Warmup: 1 dummy inference on init
  ├─ Tensor Allocation: Pre-allocated
  ├─ Memory: Reuse buffers
  └─ Error Handling: Graceful fallback
```

### **ML Kit OCR Configuration**

```yaml
TextRecognizer Settings:
  Script: TextRecognitionScript.latin
  Mode: Accurate (not Fast)
  Language: Auto-detect
  
Benefits of Latin Script:
  ├─ Faster than default multi-script
  ├─ Better accuracy for alphanumeric
  └─ Indonesian plates use Latin alphabet
  
Image Requirements:
  ├─ Min Height: 50 pixels (text height)
  ├─ Format: PNG or JPEG
  ├─ Quality: High contrast preferred
  └─ Orientation: Upright (auto-rotated)
  
Performance:
  ├─ First Call: 800-1000ms (model load)
  ├─ Subsequent: 400-600ms (cached)
  └─ Cannot optimize (Google SDK)
```

### **Performance Thresholds**

```yaml
Detection:
  Confidence Threshold: 0.5
  Rationale: Balance precision/recall
  Adjust: Increase for fewer false positives
  
NMS:
  IoU Threshold: 0.4
  Rationale: Remove overlapping detections
  Adjust: Lower = more aggressive suppression
  
Validation:
  Min Final Confidence: 0.6
  Min Text Length: 5 characters
  Max Text Length: 10 characters
  
Timeouts:
  Worker Timeout: 5 seconds
  Camera Init Timeout: 10 seconds
  OCR Timeout: 3 seconds
```

---

## 🎨 UI Component Specifications

### **CustomALPRView Widget Tree**

```
CustomALPRView (StatefulWidget)
│
└─ Scaffold
   ├─ AppBar: "License Plate Scanner"
   │
   └─ Body: Stack
      │
      ├─ Layer 1: CameraPreview (Full Screen)
      │   └─ AspectRatio(controller.value.aspectRatio)
      │
      ├─ Layer 2: LoadingOverlay (Conditional)
      │   └─ if (_isProcessing)
      │      Container(
      │        color: Colors.black54 (semi-transparent)
      │        child: Center(
      │          ├─ CircularProgressIndicator(white)
      │          └─ Text(_statusMessage, white)
      │        )
      │      )
      │
      ├─ Layer 3: CustomPaint (BoundingBoxPainter)
      │   └─ if (_currentDetection != null)
      │      CustomPaint(
      │        painter: BoundingBoxPainter(
      │          boundingBox: _currentDetection.boundingBox,
      │          confidence: _currentDetection.confidence,
      │          color: Colors.green,
      │        )
      │      )
      │
      ├─ Layer 4: PlateResultCard (Bottom)
      │   └─ if (_currentDetection?.text != null)
      │      Positioned(
      │        bottom: 20,
      │        left: 20,
      │        right: 20,
      │        child: PlateResultCard(
      │          plateText: _currentDetection.text,
      │          confidence: _currentDetection.confidence,
      │          processingTime: _processingTimeMs,
      │          onScanAgain: _handleScanAgain,
      │        )
      │      )
      │
      └─ Layer 5: StatusBarWidget (Top)
          └─ Positioned(
               top: 0,
               left: 0,
               right: 0,
               child: StatusBarWidget(
                 status: _statusMessage,
                 fps: _currentFPS,
                 showDebug: kDebugMode,
               )
             )
```

### **BoundingBoxPainter Details**

```
CustomPainter Logic:
│
├─ Paint Configuration:
│  ├─ Style: PaintingStyle.stroke
│  ├─ Color: Colors.green (or red if low confidence)
│  ├─ StrokeWidth: 3.0
│  └─ StrokeCap: StrokeCap.round
│
├─ Draw Main Rectangle:
│  └─ canvas.drawRect(boundingBox, paint)
│
├─ Draw Corner Markers (L-shaped):
│  └─ For each corner:
│     ├─ Horizontal line (20px)
│     └─ Vertical line (20px)
│
├─ Draw Confidence Label:
│  └─ At top-left of bbox:
│     ├─ Background rectangle (filled, green)
│     └─ Text: "85%" (white, bold)
│
└─ Coordinate Transformation:
   ├─ Input: Normalized [0, 1]
   ├─ Screen Size: MediaQuery.of(context).size
   ├─ Camera Aspect: controller.value.aspectRatio
   └─ Output: Screen pixels (accounting for letterboxing)
```

### **PlateResultCard Design**

```
Material Card:
  Elevation: 8.0
  BorderRadius: 16.0
  Padding: 24.0
  Background: Colors.white
  
Content Layout:
  Column(
    ├─ Row: Header
    │  ├─ Icon(Icons.check_circle, green, 24)
    │  ├─ SizedBox(width: 8)
    │  └─ Text("Plate Detected", bold, 18sp)
    │
    ├─ SizedBox(height: 16)
    │
    ├─ Text: Plate Number
    │  └─ "B 1234 ABC"
    │     ├─ FontSize: 32sp
    │     ├─ FontWeight: bold
    │     ├─ FontFamily: monospace
    │     └─ LetterSpacing: 2.0
    │
    ├─ SizedBox(height: 12)
    │
    ├─ Row: Metadata
    │  ├─ Icon(Icons.analytics, grey, 16)
    │  ├─ Text("Confidence: 87%", 14sp)
    │  ├─ Spacer()
    │  ├─ Icon(Icons.timer, grey, 16)
    │  └─ Text("1.2s", 14sp)
    │
    ├─ SizedBox(height: 16)
    │
    └─ Row: Actions
       ├─ ElevatedButton("Scan Again")
       │  └─ onPressed: clear & re-enable
       ├─ SizedBox(width: 12)
       └─ OutlinedButton("Edit")
          └─ onPressed: show edit dialog
  )

Animation:
  ├─ Entrance: SlideTransition from bottom (300ms)
  ├─ Fade: FadeTransition (200ms)
  └─ Curve: Curves.easeOutCubic
```

---

## 📊 Performance Benchmarks

### **Expected Performance by Device Category**

```
LOW-END DEVICE (Snapdragon 450, 3GB RAM):
┌──────────────────────────────────────────────────┐
│ Component              │ Time    │ Percentage   │
├──────────────────────────────────────────────────┤
│ Pre-processing         │  80ms   │   5%         │
│ TFLite Detection       │ 500ms   │  31%         │
│ YOLO Parsing + NMS     │  15ms   │   1%         │
│ ROI Extraction         │  25ms   │   2%         │
│ ML Kit OCR             │ 900ms   │  56%         │
│ Text Validation        │  10ms   │   1%         │
├──────────────────────────────────────────────────┤
│ TOTAL                  │ 1530ms  │ 100%         │
└──────────────────────────────────────────────────┘
✅ Meets target: < 2 seconds

MEDIUM DEVICE (Snapdragon 665, 4GB RAM):
┌──────────────────────────────────────────────────┐
│ Component              │ Time    │ Percentage   │
├──────────────────────────────────────────────────┤
│ Pre-processing         │  50ms   │   5%         │
│ TFLite Detection       │ 300ms   │  30%         │
│ YOLO Parsing + NMS     │  10ms   │   1%         │
│ ROI Extraction         │  15ms   │   2%         │
│ ML Kit OCR             │ 600ms   │  60%         │
│ Text Validation        │   5ms   │   1%         │
├──────────────────────────────────────────────────┤
│ TOTAL                  │ 980ms   │ 100%         │
└──────────────────────────────────────────────────┘
✅ Exceeds target: Well under 2 seconds
```

### **Memory Usage**

```
Component Memory Footprint:
├─ TFLite Model (Float32): ~8 MB (loaded once)
├─ TFLite Runtime: ~5 MB
├─ ML Kit OCR: ~20 MB (lazy loaded, shared)
├─ Camera Buffer: ~1.2 MB per frame
├─ Processing Buffers: ~2 MB
├─ App Base: ~15 MB
└─ TOTAL: ~50-55 MB sustained

Peak Memory (during processing):
└─ ~65-70 MB (includes temporary buffers)

Rationale: Very reasonable for 2GB+ devices
```

### **Battery Impact**

```
Power Consumption:
├─ Camera Preview (30 FPS): Medium
├─ Processing (1 FPS): Low
├─ NNAPI Acceleration: Low (efficient)
└─ Overall: Medium-Low

Battery Life Impact:
├─ Continuous use: ~2% per minute
├─ Typical session (5 scans): <1%
└─ Standby: Negligible

Optimization:
├─ NNAPI uses dedicated hardware (less CPU)
├─ Low processing rate (1 FPS)
└─ Camera stops when not scanning
```

---

## 🛡️ Error Handling Strategy

### **Error Categories & Handling**

```
1. CAMERA ERRORS:
   ├─ Permission Denied
   │  └─ Show dialog: "Camera access required"
   │     └─ Button: "Open Settings"
   │
   ├─ Camera Not Available
   │  └─ Show error: "No camera found"
   │     └─ Fallback: File picker
   │
   └─ Initialization Failed
      └─ Retry 3 times with exponential backoff
         └─ If still fails: Show manual entry option

2. WORKER ISOLATE ERRORS:
   ├─ Spawn Failed
   │  └─ Log error & show toast
   │     └─ Retry once
   │
   ├─ Worker Crash
   │  └─ Auto-restart worker
   │     └─ Notify user: "Restarting scanner..."
   │
   └─ Timeout (>5 seconds)
      └─ Kill worker & restart
         └─ Show: "Processing timed out. Try again."

3. MODEL ERRORS:
   ├─ Model Not Found
   │  └─ CRITICAL: Show error dialog
   │     └─ "App data corrupted. Please reinstall."
   │
   ├─ Load Failed
   │  └─ Retry once
   │     └─ If fails: Show offline mode
   │
   └─ Inference Error
      └─ Log error & skip frame
         └─ Show: "Detection failed. Retrying..."

4. OCR ERRORS:
   ├─ ML Kit Initialization Failed
   │  └─ Fallback: Manual text entry
   │     └─ Show: "OCR unavailable. Enter manually."
   │
   ├─ Recognition Failed
   │  └─ Retry with enhanced image
   │     └─ If still fails: Manual entry
   │
   └─ No Text Detected
      └─ Show: "No text found. Try better lighting."

5. VALIDATION ERRORS:
   ├─ Invalid Format
   │  └─ Show result with warning
   │     └─ Allow manual correction
   │
   ├─ Low Confidence (<60%)
   │  └─ Show result with "Low confidence" badge
   │     └─ Suggest re-scan
   │
   └─ Empty Result
      └─ Show: "No plate detected. Try again."

GENERAL PRINCIPLE:
├─ Never crash the app
├─ Always provide user feedback
├─ Offer alternatives (manual entry)
└─ Log errors for debugging
```

---

## 🧪 Testing Strategy

### **Unit Tests**

```
Test Modules:
│
├─ image_preprocessor_test.dart
│  ├─ Test YUV → RGB conversion accuracy
│  ├─ Test resize output dimensions
│  ├─ Test normalization range [0, 1]
│  └─ Test performance (<120ms)
│
├─ yolo_parser_test.dart
│  ├─ Test detection parsing
│  ├─ Test confidence filtering
│  ├─ Test coordinate conversion
│  └─ Test edge cases (empty output)
│
├─ nms_processor_test.dart
│  ├─ Test IoU calculation
│  ├─ Test suppression logic
│  └─ Test single detection case
│
├─ text_validator_test.dart
│  ├─ Test regex patterns
│  ├─ Test format validation
│  ├─ Test confidence calculation
│  └─ Test formatting output
│
└─ bbox_calculator_test.dart
   ├─ Test coordinate transformations
   ├─ Test padding calculation
   └─ Test boundary clamping
```

### **Integration Tests**

```
Test Scenarios:
│
├─ end_to_end_test.dart
│  ├─ Full pipeline: Camera → Result
│  ├─ Test with mock images
│  ├─ Verify timing < 2 seconds
│  └─ Verify result accuracy
│
├─ isolate_communication_test.dart
│  ├─ Test message serialization
│  ├─ Test result deserialization
│  ├─ Test error propagation
│  └─ Test timeout handling
│
└─ ui_interaction_test.dart
   ├─ Test continuous live detection (automatic, no manual scan button)
   ├─ Test result display overlay (real-time updates)
   ├─ Test pause/resume camera stream flow
   └─ Test error states (camera permissions, initialization)
```

### **Performance Tests**

```
Benchmarks:
│
├─ Pre-processing: Should complete < 120ms
├─ TFLite Inference: Should complete < 500ms (low-end)
├─ YOLO Parsing: Should complete < 10ms
├─ NMS Processing: Should complete < 15ms
├─ ROI Extraction: Should complete < 25ms
├─ OCR Processing: Should complete < 900ms (low-end)
├─ Text Validation: Should complete < 10ms
└─ Total Pipeline: Should complete < 2000ms (low-end)

Memory Tests:
│
├─ Peak memory usage < 80MB
├─ Sustained memory usage < 60MB
├─ No memory leaks after 100 scans
└─ Proper resource cleanup on dispose

Stress Tests:
│
├─ 1000 consecutive scans (no crash)
├─ Rapid start/stop cycles (no leak)
├─ Worker restart after crash (recovery)
└─ Simultaneous camera + background tasks
```

---

## 📱 Device Compatibility Matrix

```
┌─────────────────────────────────────────────────────────────┐
│ DEVICE TIER │ PERFORMANCE │ EXPECTED TIME │ RECOMMENDED    │
├─────────────────────────────────────────────────────────────┤
│ Low-End     │ Snapdragon  │ 1.3 - 1.8s   │ ✅ Supported   │
│             │ 450-460     │              │ (Target tier)  │
│             │ 2-3GB RAM   │              │                │
├─────────────────────────────────────────────────────────────┤
│ Medium      │ Snapdragon  │ 0.8 - 1.2s   │ ✅ Optimal     │
│             │ 665-720     │              │                │
│             │ 4GB RAM     │              │                │
├─────────────────────────────────────────────────────────────┤
│ High-End    │ Snapdragon  │ 0.5 - 0.8s   │ ✅ Excellent   │
│             │ 865+        │              │                │
│             │ 6GB+ RAM    │              │                │
└─────────────────────────────────────────────────────────────┘

Android Version Support:
├─ Minimum: Android 7.0 (API 24)
├─ Recommended: Android 8.0+ (API 26)
└─ NNAPI: Best on Android 9.0+ (API 28)
```

---

## 🚀 Deployment Checklist

### **Pre-Production**

```
✅ Model Asset:
   ├─ Verify plat_recognation.tflite in assets/
   ├─ Check model size < 10MB
   ├─ Test model loading on all device tiers
   └─ Verify NNAPI compatibility

✅ Permissions:
   ├─ AndroidManifest.xml: CAMERA permission
   ├─ Runtime permission handling
   └─ Permission denied fallback UI

✅ Dependencies:
   ├─ camera: ^0.10.0+
   ├─ tflite_flutter: ^0.10.0+
   ├─ google_mlkit_text_recognition: ^0.10.0+
   └─ image: ^4.0.0+

✅ Configuration:
   ├─ ProGuard rules for TFLite
   ├─ ML Kit model download strategy
   └─ Asset compression disabled for .tflite

✅ Testing:
   ├─ Unit tests: 100% coverage on processors
   ├─ Integration tests: Full pipeline
   ├─ Performance tests: All device tiers
   └─ UI tests: All user flows

✅ Optimization:
   ├─ Enable R8/ProGuard minification
   ├─ Shrink resources
   ├─ Split APKs by ABI
   └─ Use app bundle for Play Store
```

### **Production Monitoring**

```
📊 Key Metrics to Track:
│
├─ Performance Metrics:
│  ├─ Average processing time
│  ├─ P50, P95, P99 latency
│  ├─ Frame drop rate
│  └─ Worker restart frequency
│
├─ Accuracy Metrics:
│  ├─ Detection success rate
│  ├─ OCR accuracy rate
│  ├─ Validation pass rate
│  └─ User correction frequency
│
├─ Error Metrics:
│  ├─ Camera initialization failures
│  ├─ Worker crash rate
│  ├─ Model loading failures
│  └─ Timeout occurrences
│
└─ User Experience:
   ├─ Session duration
   ├─ Scans per session
   ├─ Manual entry fallback rate
   └─ App crash rate
```

---

## 🔧 Troubleshooting Guide

### **Common Issues & Solutions**

```
ISSUE 1: Slow Detection (>3 seconds)
├─ Symptoms: Processing takes longer than expected
├─ Possible Causes:
│  ├─ NNAPI not enabled
│  ├─ Model not optimized
│  └─ Device too old
├─ Solutions:
│  ├─ Verify NNAPI delegate is active
│  ├─ Check device API level >= 28
│  ├─ Test with quantized model alternative
│  └─ Profile with DevTools

ISSUE 2: Poor OCR Accuracy
├─ Symptoms: Text recognition often incorrect
├─ Possible Causes:
│  ├─ Poor lighting conditions
│  ├─ Blurry images
│  ├─ ROI too small
│  └─ Plate angle too steep
├─ Solutions:
│  ├─ Add lighting guidance UI
│  ├─ Increase ROI padding to 15%
│  ├─ Add image sharpening
│  └─ Guide user for better angle

ISSUE 3: High Memory Usage
├─ Symptoms: App killed by system
├─ Possible Causes:
│  ├─ Memory leaks in isolate
│  ├─ Images not disposed
│  └─ Buffers not cleared
├─ Solutions:
│  ├─ Profile with Memory Profiler
│  ├─ Verify all dispose() calls
│  ├─ Clear image buffers after use
│  └─ Reduce camera resolution

ISSUE 4: Worker Isolate Crashes
├─ Symptoms: Processing stops, no result
├─ Possible Causes:
│  ├─ TFLite inference error
│  ├─ Out of memory
│  └─ ML Kit crash
├─ Solutions:
│  ├─ Implement auto-restart
│  ├─ Add try-catch in all processors
│  ├─ Log crashes to analytics
│  └─ Show user-friendly error

ISSUE 5: Camera Not Starting
├─ Symptoms: Black screen, no preview
├─ Possible Causes:
│  ├─ Permission denied
│  ├─ Camera in use by another app
│  └─ Unsupported resolution
├─ Solutions:
│  ├─ Request permission properly
│  ├─ Retry with lower resolution
│  ├─ Show clear error message
│  └─ Provide manual capture fallback
```

---

## 📚 Implementation Timeline

### **Phase-by-Phase Development**

```
PHASE 1: Foundation (Week 1)
Day 1-2: Project Setup
├─ Create modular folder structure
├─ Add dependencies
├─ Setup constants
└─ Create data models

Day 3-4: Core Processing Modules
├─ Implement ImagePreprocessor
├─ Implement YoloParser
├─ Implement NmsProcessor
└─ Write unit tests

Day 5-7: Detection Pipeline
├─ Implement TFLiteDetector
├─ Implement RoiExtractor
├─ Test with mock data
└─ Performance benchmarking

PHASE 2: Worker & Services (Week 2)
Day 1-2: Worker Isolate
├─ Implement detection_worker.dart
├─ Setup communication protocol
├─ Test message passing
└─ Error handling

Day 3-4: Services Layer
├─ Implement CameraService
├─ Implement WorkerIsolateService
├─ Implement PerformanceMonitor
└─ Integration testing

Day 5-7: OCR Integration
├─ Implement OcrProcessor
├─ Implement TextValidator
├─ Test with real plates
└─ Accuracy tuning

PHASE 3: UI Layer (Week 3)
Day 1-2: Basic UI
├─ Implement CustomALPRView
├─ Implement camera preview
├─ Basic layout
└─ State management

Day 3-4: Overlay & Feedback
├─ Implement BoundingBoxPainter
├─ Implement LoadingOverlay
├─ Implement StatusBarWidget
└─ Animations

Day 5-7: Result Display
├─ Implement PlateResultCard
├─ Polish UI/UX
├─ User testing
└─ Refinements

PHASE 4: Polish & Deploy (Week 4)
Day 1-2: Testing
├─ Full integration tests
├─ Performance tests
├─ Device compatibility tests
└─ Bug fixes

Day 3-4: Optimization
├─ Memory optimization
├─ Performance tuning
├─ Error handling improvements
└─ Analytics integration

Day 5-7: Deployment
├─ Final testing
├─ Documentation
├─ Play Store preparation
└─ Release
```

---

## 🎓 Best Practices Summary

### **Code Organization**

```
✅ DO:
├─ Follow single responsibility principle
├─ Keep functions small and focused
├─ Use meaningful variable names
├─ Comment complex algorithms
├─ Separate concerns (UI, Business, Data)
└─ Write unit tests for all processors

❌ DON'T:
├─ Mix UI and business logic
├─ Create god classes
├─ Hardcode configuration values
├─ Ignore error handling
└─ Skip dispose() calls
```

### **Performance**

```
✅ DO:
├─ Pre-allocate buffers
├─ Reuse objects where possible
├─ Profile regularly
├─ Use NNAPI delegate
├─ Implement frame throttling
└─ Clear unused resources

❌ DON'T:
├─ Process every camera frame
├─ Create objects in hot paths
├─ Load models repeatedly
├─ Ignore memory leaks
└─ Block the UI thread
```

### **User Experience**

```
✅ DO:
├─ Provide clear feedback
├─ Show loading states
├─ Handle errors gracefully
├─ Allow manual corrections
├─ Guide user (lighting, angle)
└─ Keep UI responsive

❌ DON'T:
├─ Show technical errors
├─ Freeze the UI
├─ Leave user guessing
├─ Force retries on failure
└─ Ignore edge cases
```

---

## 📖 Additional Resources

### **Documentation Links**

```
TFLite Flutter:
└─ https://pub.dev/packages/tflite_flutter

Google ML Kit:
└─ https://pub.dev/packages/google_mlkit_text_recognition

Camera Plugin:
└─ https://pub.dev/packages/camera

Dart Isolates:
└─ https://dart.dev/guides/language/concurrency

NNAPI Documentation:
└─ https://developer.android.com/ndk/guides/neuralnetworks

Flutter Performance:
└─ https://docs.flutter.dev/perf
```

### **Reference Implementation**

```
Example Project Structure:

alpr_app/
├─ lib/
│  └─ features/alpr/
│     ├─ presentation/
│     ├─ domain/
│     ├─ data/
│     └─ core/
├─ assets/
│  └─ plat_recognation.tflite
├─ test/
│  ├─ unit/
│  ├─ integration/
│  └─ performance/
└─ android/
   └─ app/
      └─ src/main/
         └─ assets/
            └─ plat_recognation.tflite
```

---

## 🎯 Success Criteria

```
✅ Performance:
   ├─ Detection + OCR < 2 seconds (low-end)
   ├─ UI maintains 60 FPS during processing
   ├─ Memory usage < 70MB peak
   └─ Battery drain < 2% per minute

✅ Accuracy:
   ├─ Detection success rate > 90%
   ├─ OCR accuracy > 85%
   ├─ False positive rate < 5%
   └─ Validation pass rate > 80%

✅ Reliability:
   ├─ App crash rate < 0.1%
   ├─ Worker recovery time < 1 second
   ├─ Error handling covers all cases
   └─ Graceful degradation on failures

✅ User Experience:
   ├─ Clear feedback at every step
   ├─ Intuitive error messages
   ├─ Manual correction available
   └─ Smooth animations and transitions
```

---

## 📝 Final Notes

### **Key Advantages of This Architecture**

```
1. MODULAR DESIGN
   ├─ Easy to test individual components
   ├─ Simple to add features
   ├─ Clear separation of concerns
   └─ Maintainable codebase

2. PERFORMANCE OPTIMIZED
   ├─ UI never blocks
   ├─ Efficient resource usage
   ├─ Hardware acceleration (NNAPI)
   └─ Smart frame throttling

3. LOW-END FRIENDLY
   ├─ Minimal memory footprint
   ├─ Efficient processing pipeline
   ├─ Graceful degradation
   └─ Battery conscious

4. PRODUCTION READY
   ├─ Comprehensive error handling
   ├─ Performance monitoring
   ├─ Device compatibility
   └─ Scalable architecture
```

### **Future Enhancements (Optional)**

```
🔮 Possible Improvements:
│
├─ Multiple Plate Detection
│  └─ Detect multiple plates in single frame
│
├─ Batch Processing
│  └─ Process multiple images from gallery
│
├─ Offline Mode
│  └─ Save and process later
│
├─ Cloud Backup
│  └─ Sync detected plates
│
├─ Analytics Dashboard
│  └─ View detection history and stats
│
├─ Advanced Filters
│  └─ Pre-process images for better accuracy
│
└─ Custom Model Training
   └─ Fine-tune for specific regions/formats
```

---

## ✨ Summary

This blueprint provides a **complete, production-ready architecture** for building a custom ALPR system optimized for low-end Android devices. Key highlights:

✅ **Zero dependency on ultralytics_yolo** - Full control over every component  
✅ **best_float32.tflite model** - Optimal balance of accuracy and performance  
✅ **Modular architecture** - Clean, testable, maintainable code  
✅ **< 2 second processing** - Meets performance target on low-end devices  
✅ **Smooth UI** - Never blocks, always responsive  
✅ **Production-ready** - Comprehensive error handling and monitoring  

Ready to implement! 🚀   │   ├─ calculateIoU(boxA, boxB)
│           │   │   │  └─ Intersection over Union calculation
│           │   │   ├─ convertNormalizedToPixels(bbox, width, height)
│           │   │   │  └─ Convert [0,1] coords to pixel coords
│           │   │   ├─ convertCenterToCorner(x, y, w, h)
│           │   │   │  └─ Center format → corner format
│           │   │   ├─ addPadding(bbox, percent)
│           │   │   │  └─ Expand bbox by percentage
│           │   │   ├─ clampToImageBounds(bbox, width, height)
│           │   │   │  └─ Ensure bbox within image
│           │   │   └─ calculateArea(bbox)
│           │   │      └─ Get bbox area in pixels
│           │   │
│           │   └── indonesian_plate_regex.dart
│           │       Purpose: Indonesian plate format validation
│           │       
│           │       Patterns:
│           │       ├─ Standard: ^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$
│           │       ├─ Motorcycle: ^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,2}$
│           │       ├─ Government: ^[A-Z]{2}\s?\d{1,4}\s?[A-Z]{3}$
│           │       └─ Special: Custom patterns
│           │       
│           │       Functions:
│           │       ├─ isValidIndonesianPlate(text)
│           │       ├─ extractPlateType(text)
│           │       ├─ formatPlateText(text)
│           │       └─ suggestCorrections(text)
│           │
│           └── constants/
│               │
│               ├── model_constants.dart
│               │   Purpose: Model-related configuration
│               │   
│               │   Constants:
│               │   ├─ MODEL_PATH = 'plat_recognation.tflite'
│               │   ├─ MODEL_TYPE = 'float32'
│               │   ├─ INPUT_SIZE = 320
│               │   ├─ INPUT_SHAPE = [1, 320, 320, 3]
│               │   ├─ OUTPUT_SHAPE = [1, 25200, 6]
│               │   ├─ NUM_CLASSES = 1
│               │   └─ CLASS_NAMES = ['license_plate']
│               │
│               ├── processing_constants.dart
│               │   Purpose: Processing pipeline configuration
│               │   
│               │   Constants:
│               │   ├─ CONFIDENCE_THRESHOLD = 0.5
│               │   ├─ IOU_THRESHOLD = 0.4
│               │   ├─ NMS_MAX_DETECTIONS = 1
│               │   ├─ ROI_PADDING_PERCENT = 0.1
│               │   ├─ MIN_OCR_HEIGHT = 50
│               │   ├─ FRAME_COOLDOWN_MS = 1000
│               │   ├─ WORKER_TIMEOUT_MS = 5000
│               │   ├─ NUM_THREADS = 2
│               │   ├─ USE_NNAPI = true
│               │   └─ ALLOW_FP16 = true
│               │
│               └── ui_constants.dart
│                   Purpose: UI styling & colors
│                   
│                   Colors:
│                   ├─ PRIMARY_COLOR = Colors.blue[700]
│                   ├─ ACCENT_COLOR = Colors.green[500]
│                   ├─ BBOX_COLOR = Colors.green
│                   ├─ LOADING_COLOR = Colors.white70
│                   └─ ERROR_COLOR = Colors.red[400]
│                   
│                   Dimensions:
│                   ├─ BBOX_STROKE_WIDTH = 3.0
│                   ├─ CORNER_MARKER_LENGTH = 20.0
│                   ├─ RESULT_CARD_PADDING = 24.0
│                   └─ STATUS_BAR_HEIGHT = 60.0
│                   
│                   Animations:
│                   ├─ SLIDE_DURATION = 300ms
│                   ├─ FADE_DURATION = 200ms
│                   └─ LOADING_ROTATION_DURATION = 1000ms
│
└── main.dart
    Purpose: App entry point
    Responsibilities:
    ├─ Initialize Flutter app
    ├─ Setup camera permissions
    ├─ Configure routing
    └─ Launch ALPRScannerPage

assets/
└── plat_recognation.tflite              # Best Float32 model
```

---

## 📊 Complete Processing Flow

### **User Journey**

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: APP LAUNCH                                          │
├─────────────────────────────────────────────────────────────┤
│ 1. User opens app                                           │
│ 2. Request camera permissions                               │
│ 3. Initialize CameraService                                 │
│    ├─ Select back camera                                    │
│    ├─ Set resolution: 640x480                               │
│    └─ Start preview (30 FPS)                                │
│ 4. Initialize WorkerIsolateService                          │
│    ├─ Spawn worker isolate                                  │
│    ├─ Load best_float32.tflite model                        │
│    ├─ Initialize ML Kit OCR                                 │
│    └─ Wait for ready signal                                 │
│ 5. Show camera preview                                      │
│    └─ Status: "Ready to scan"                               │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: POINT CAMERA AT PLATE                               │
├─────────────────────────────────────────────────────────────┤
│ 1. User points camera at license plate                      │
│ 2. Preview shows live feed (smooth 30 FPS)                  │
│ 3. Frame throttling active:                                 │
│    ├─ Capture 1 frame per second                            │
│    ├─ Skip frames if worker busy                            │
│    └─ Cooldown: 1 second between captures                   │
│ 4. Status: "Align plate in view"                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: AUTO CAPTURE (or Manual Tap)                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Trigger capture:                                         │
│    ├─ Auto: After 1 second stabilization                    │
│    └─ Manual: User taps "SCAN" button                       │
│ 2. Serialize camera frame                                   │
│ 3. Send to worker isolate                                   │
│ 4. Show loading overlay                                     │
│    └─ "Processing..."                                       │
│ 5. Disable further captures                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: WORKER PROCESSING (1-2 seconds)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Phase 1: PRE-PROCESSING (50-120ms)                         │
│ ├─ YUV420 → RGB conversion                                 │
│ ├─ Resize 640x480 → 320x320                                │
│ └─ Normalize to [0.0, 1.0]                                 │
│ Status: "Preparing image..."                                │
│                                                             │
│ Phase 2: DETECTION (200-500ms)                             │
│ ├─ TFLite inference (best_float32)                         │
│ ├─ Parse YOLO output                                        │
│ ├─ Filter confidence > 0.5                                  │
│ └─ Apply NMS (keep best)                                    │
│ Status: "Detecting plate..."                                │
│                                                             │
│ Phase 3: ROI EXTRACTION (10-25ms)                          │
│ ├─ Crop plate region                                        │
│ ├─ Add 10% padding                                          │
│ └─ Enhance (optional)                                       │
│ Status: "Analyzing..."                                      │
│                                                             │
│ Phase 4: OCR (400-900ms)                                   │
│ ├─ Convert to InputImage                                    │
│ ├─ ML Kit text recognition                                  │
│ └─ Extract text blocks                                      │
│ Status: "Reading characters..."                             │
│                                                             │
│ Phase 5: VALIDATION (5-10ms)                               │
│ ├─ Clean text                                               │
│ ├─ Validate format                                          │
│ ├─ Calculate confidence                                     │
│ └─ Format output                                            │
│ Status: "Validating..."                                     │
│                                                             │
│ TOTAL: 700ms - 1.6 seconds                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: RESULT DISPLAY                                      │
├─────────────────────────────────────────────────────────────┤
│ 1. Receive WorkerResult                                     │
│ 2. Hide loading overlay                                     │
│ 3. Draw bounding box (green)                                │
│    └─ CustomPaint overlay on preview                        │
│ 4. Show PlateResultCard (slide up animation)               │
│    ├─ Plate Text: "B 1234 ABC"                             │
│    ├─ Confidence: 87%                                       │
│    ├─ Processing Time: 1.2s                                │
│    └─ Button: "Scan Again"                                 │
│ 5. Status: "Detection complete!"                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 6: USER ACTION                                         │
├─────────────────────────────────────────────────────────────┤
│ Option A: Result Correct                                    │
│ ├─ User taps "Save" or "Continue"                          │
│ ├─ Store result in database                                │
│ └─ Navigate to next screen                                 │
│                                                             │
│ Option B: Result Incorrect                                  │
│ ├─ User taps "Scan Again"                                  │
│ ├─ Clear current detection                                 │
│ ├─ Re-enable camera capture                                │
│ └─ Return to STEP 2                                        │
│                                                             │
│ Option C: Manual Edit                                       │
│ ├─ User taps "Edit"                                        │
│ ├─ Show text input dialog                                  │
│ ├─ User corrects text                                      │
│ └─ Save edited result                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Architecture

### **Main Thread ↔ Worker Isolate Communication**

```
MAIN ISOLATE                           WORKER ISOLATE
    │                                       │
    │  1. Initialize                       │
    ├──────── Spawn Worker ────────────────>
    │                                       ├─ Load TFLite
    │                                       ├─ Initialize ML Kit
    │                                       └─ Create ReceivePort
    │                                       │
    │  2. Handshake                         │
    <──────── SendPort ─────────────────────┤
    │                                       │
    │  3. Processing Loop                   │
    │                                       │
    ├──────── WorkerMessage ────────────────>
    │         {                              │
    │           type: 'frame'                ├─ Deserialize
    │           data: {                      ├─ Preprocess
    │             image: Uint8List           ├─ Detect (TFLite)
    │             width: 640                 ├─ Parse Output
    │             height: 480                ├─ NMS
    │           }                            ├─ Extract ROI
    │           frameId: 123                 ├─ OCR (ML Kit)
    │           timestamp: DateTime          └─ Validate
    │         }                              │
    │                                       │
    │  4. Result                             │
    <──────── WorkerResult ─────────────────┤
    │         {                              │
    │           type: 'success'              │
    │           detections: [...]            │
    │           frameId: 123                 │
    │           processingTime: 1200         │
    │         }                              │
    │                                       │
    ├─ Update UI                            │
    ├─ Draw Bbox                            │
    ├─ Show Result                          │
    └─ Enable Next Capture                  │
    │                                       │
    │  5. Shutdown                           │
    ├──────── WorkerMessage ────────────────>
    │         {                              │
    │           type: 'shutdown'             ├─ Cleanup
    │         }                              ├─ Close TFLite
    │                                       ├─ Close ML Kit
    <──────── Confirmation ─────────────────┤
    │                                       │
    ├─ Kill Isolate                         └─ Exit
    └─ Cleanup                              
```

---

## ⚙️ Configuration & Optimization

### **Camera Configuration**

```yaml
Camera Settings:
  Resolution: ResolutionPreset.medium
  Actual Size: 640 x 480 pixels
  FPS: 30 (preview only)
  Format: ImageFormatGroup.yuv420
  Camera: Back camera (index 0)
  
Processing Rate:
  Capture Rate: 1 frame per second
  Processing Rate: 1 frame per 1-2 seconds
  Drop Strategy: Skip frames if worker busy
  Cooldown: 1 second after each processing
  
Rationale:
  ├─ 640x480: Good balance (quality vs performance)
  ├─ 30 FPS preview: Smooth user experience
  ├─ 1 FPS processing: Sufficient for ALPR
  └─ YUV420: Native Android format (no conversion)
```

### **TFLite Configuration (best_float32.tflite)**

```yaml
Model Configuration:
  Type: Float32 (not quantized)
  Input: [1, 320, 320, 3]
  Output: [1, N, 6]
  Size: ~5-10 MB
  
Interpreter Options:
  Threads: 2
  UseNNAPI: true
  Delegates: [NnApiDelegate()]
  AllowFp16: true (if device supports)
  AllowBufferHandling: true
  
NNAPI Delegate:
  Purpose: Hardware acceleration
  Benefits:
    ├─ Automatic GPU offloading
    ├─ DSP utilization if available
    ├─ 2-3x speed improvement
    └─ Better battery efficiency
  Fallback: CPU with 2 threads
  
Performance Tuning:
  ├─ Warmup: 1 dummy inference on init
  ├─ Tensor Allocation: Pre-allocated
  ├─ Memory: Reuse buffers
  └─ Error Handling: Graceful fallback
```

### **ML Kit OCR Configuration**

```yaml
TextRecognizer Settings:
  Script: TextRecognitionScript.latin
  Mode: Accurate (not Fast)
  Language: Auto-detect
  
Benefits of Latin Script:
  ├─ Faster than default multi-script
  ├─ Better accuracy for alphanumeric
  └─ Indonesian plates use Latin alphabet
  
Image Requirements:
  ├─ Min Height: 50 pixels (text height)
  ├─ Format: PNG or JPEG
  ├─ Quality: High contrast preferred
  └─ Orientation: Upright (auto-rotated)
  
Performance:
  ├─ First Call: 800-1000ms (model load)
  ├─ Subsequent: 400-600ms (cached)
  └─ Cannot optimize (Google SDK)
```

### **Performance Thresholds**

```yaml
Detection:
  Confidence Threshold: 0.5
  Rationale: Balance precision/recall
  Adjust: Increase for fewer false positives
  
NMS:
  IoU Threshold: 0.4
  Rationale: Remove overlapping detections
  Adjust: Lower = more aggressive suppression
  
Validation:
  Min Final Confidence: 0.6
  Min Text Length: 5 characters
  Max Text Length: 10 characters
  
Timeouts:
  Worker Timeout: 5 seconds
  Camera Init Timeout: 10 seconds
  OCR Timeout: 3 seconds
```

---

## 🎨 UI Component Specifications

### **CustomALPRView Widget Tree**

```
CustomALPRView (StatefulWidget)
│
└─ Scaffold
   ├─ AppBar: "License Plate Scanner"
   │
   └─ Body: Stack
      │
      ├─ Layer 1: CameraPreview (Full Screen)
      │   └─ AspectRatio(controller.value.aspectRatio)
      │
      ├─ Layer 2: LoadingOverlay (Conditional)
      │   └─ if (_isProcessing)
      │      Container(
      │        color: Colors.black54 (semi-transparent)
      │        child: Center(
      │          ├─ CircularProgressIndicator(white)
      │          └─ Text(_statusMessage, white)
      │        )
      │      )
      │
      ├─ Layer 3: CustomPaint (BoundingBoxPainter)
      │   └─ if (_currentDetection != null)
      │      CustomPaint(
      │        painter: BoundingBoxPainter(
      │          boundingBox: _currentDetection.boundingBox,
      │          confidence: _currentDetection.confidence,
      │          color: Colors.green,
      │        )
      │      )
      │
      ├─ Layer 4: PlateResultCard (Bottom)
      │   └─ if (_currentDetection?.text != null)
      │      Positioned(
      │        bottom: 20,
      │        left: 20,
      │        right: 20,
      │        child: PlateResultCard(
      │          plateText: _currentDetection.text,
      │          confidence: _currentDetection.confidence,
      │          processingTime: _processingTimeMs,
      │          onScanAgain: _handleScanAgain,
      │        )
      │      )
      │
      └─ Layer 5: StatusBarWidget (Top)
          └─ Positioned(
               top: 0,
               left: 0,
               right: 0,
               child: StatusBarWidget(
                 status: _statusMessage,
                 fps: _currentFPS,
                 showDebug: kDebugMode,
               )
             )
```

### **BoundingBoxPainter Details**

```
CustomPainter Logic:
│
├─ Paint Configuration:
│  ├─ Style: PaintingStyle.stroke
│  ├─ Color: Colors.green (or red if low confidence)
│  ├─ StrokeWidth: 3.0
│  └─ StrokeCap: StrokeCap.round
│
├─ Draw Main Rectangle:
│  └─ canvas.drawRect(boundingBox, paint)
│
├─ Draw Corner Markers (L-shaped):
│  └─ For each corner:
│     ├─ Horizontal line (20px)
│     └─ Vertical line (20px)
│
├─ Draw Confidence Label:
│  └─ At top-left of bbox:
│     ├─ Background rectangle (filled, green)
│     └─ Text: "85%" (white, bold)
│
└─ Coordinate Transformation:
   ├─ Input: Normalized [0, 1]
   ├─ Screen Size: MediaQuery.of(context).size
   ├─ Camera Aspect: controller.value.aspectRatio
   └─ Output: Screen pixels (accounting for letterboxing)
```

### **PlateResultCard Design**

```
Material Card:
  Elevation: 8.0
  BorderRadius: 16.0
  Padding: 24.0
  Background: Colors.white
  
Content Layout:
  Column(
    ├─ Row: Header
    │  ├─ Icon(Icons.check_circle, green, 24)
    │  ├─ SizedBox(width: 8)
    │  └─ Text("Plate Detected", bold, 18sp)
    │
    ├─ SizedBox(height: 16)
    │
    ├─ Text: Plate Number
    │  └─ "B 1234 ABC"
    │     ├─ FontSize: 32sp
    │     ├─ FontWeight: bold
    │     ├─ FontFamily: monospace
    │     └─ LetterSpacing: 2.0
    │
    ├─ SizedBox(height: 12)
    │
    ├─ Row: Metadata
    │  ├─ Icon(Icons.analytics, grey, 16)
    │  ├─ Text("Confidence: 87%", 14sp)
    │  ├─ Spacer()
    │  ├─ Icon(Icons.timer, grey, 16)
    │  └─ Text("1.2s", 14sp)
    │
    ├─ SizedBox(height: 16)
    │
    └─ Row: Actions
       ├─ ElevatedButton("Scan Again")
       │  └─ onPressed: clear & re-enable
       ├─ SizedBox(width: 12)
       └─ OutlinedButton("Edit")
          └─ onPressed: show edit dialog
  )

Animation:
  ├─ Entrance: SlideTransition from bottom (300ms)
  ├─ Fade: FadeTransition (200ms)
  └─ Curve: Curves.easeOutCubic
```

---

## 📊 Performance Benchmarks

### **Expected Performance by Device Category**

```
LOW-END DEVICE (Snapdragon 450, 3GB RAM):
┌──────────────────────────────────────────────────┐
│ Component              │ Time    │ Percentage   │
├──────────────────────────────────────────────────┤
│ Pre-processing         │  80ms   │   5%         │
│ TFLite Detection       │ 500ms   │  31%         │
│ YOLO Parsing + NMS     │  15ms   │   1%         │
│ ROI Extraction         │  25ms   │   2%         │
│ ML Kit OCR             │ 900ms   │  56%         │
│ Text Validation        │  10ms   │   1%         │
├──────────────────────────────────────────────────┤
│ TOTAL                  │ 1530ms  │ 100%         │
└──────────────────────────────────────────────────┘
✅ Meets target: < 2 seconds

MEDIUM DEVICE (Snapdragon 665, 4GB RAM):
┌──────────────────────────────────────────────────┐
│ Component              │ Time    │ Percentage   │
├──────────────────────────────────────────────────┤
│ Pre-processing         │  50ms   │   5%         │
│ TFLite Detection       │ 300ms   │  30%         │
│ YOLO Parsing + NMS     │  10ms   │   1%         │
│ ROI Extraction         │  15ms   │   2%         │
│ ML Kit OCR             │ 600ms   │  60%         │
│ Text Validation        │   5ms   │   1%         │
├──────────────────────────────────────────────────┤
│ TOTAL                  │ 980ms   │ 100%         │
└──────────────────────────────────────────────────┘
✅ Exceeds target: Well under 2 seconds
```

### **Memory Usage**

```
Component Memory Footprint:
├─ TFLite Model (Float32): ~8 MB (loaded once)
├─ TFLite Runtime: ~5 MB
├─ ML Kit OCR: ~20 MB (lazy loaded, shared)
├─ Camera Buffer: ~1.2 MB per frame
├─ Processing Buffers: ~2 MB
├─ App Base: ~15 MB
└─ TOTAL: ~50-55 MB sustained

Peak Memory (during processing):
└─ ~65-70 MB (includes temporary buffers)

Rationale: Very reasonable for 2GB+ devices
```

### **Battery Impact**

```
Power Consumption:
├─ Camera Preview (30 FPS): Medium
├─ Processing (1 FPS): Low
├─ NNAPI Acceleration: Low (efficient)
└─ Overall: Medium-Low

Battery Life Impact:
├─ Continuous use: ~2% per minute
├─ Typical session (5 scans): <1%
└─ Standby: Negligible

Optimization:
├─ NNAPI uses dedicated hardware (less CPU)
├─ Low processing rate (1 FPS)
└─ Camera stops when not scanning
```

---

## 🛡️ Error Handling Strategy

### **Error Categories & Handling**

```
1. CAMERA ERRORS:
   ├─ Permission Denied
   │  └─ Show dialog: "Camera access required"
   │     └─ Button: "Open Settings"
   │
   ├─ Camera Not Available
   │  └─ Show error: "No camera found"
   │     └─ Fallback: File picker
   │
   └─ Initialization Failed
      └─ Retry 3 times with exponential backoff
         └─ If still fails: Show manual entry option

2. WORKER ISOLATE ERRORS:
   ├─ Spawn Failed
   │  └─ Log error & show toast
   │     └─ Retry once
   │
   ├─ Worker Crash
   │  └─ Auto-restart worker
   │     └─ Notify user: "Restarting scanner..."
   │
   └─ Timeout (>5 seconds)
      └─ Kill worker & restart
         └─ Show: "Processing timed out. Try again."

3. MODEL ERRORS:
   ├─ Model Not Found
   │  └─ CRITICAL: Show error dialog
   │     └─ "App data corrupted. Please reinstall."
   │
   ├─ Load Failed
   │  └─ Retry once
   │     └─ If fails: Show offline mode
   │
   └─ Inference Error
      └─ Log error & skip frame
         └─ Show: "Detection failed. Retrying..."

4. OCR ERRORS:
   ├─ ML Kit Initialization Failed
   │  └─ Fallback: Manual text entry
   │     └─ Show: "OCR unavailable. Enter manually."
   │
   ├─ Recognition Failed
   │  └─ Retry with enhanced image
   │     └─ If still fails: Manual entry
   │
   └─ No Text Detected
      └─ Show: "No text found. Try better lighting."

5. VALIDATION ERRORS:
   ├─ Invalid Format
   │  └─ Show result with warning
   │     └─ Allow manual correction
   │
   ├─ Low Confidence (<60%)
   │  └─ Show result with "Low confidence" badge
   │     └─ Suggest re-scan
   │
   └─ Empty Result
      └─ Show: "No plate detected. Try again."

GENERAL PRINCIPLE:
├─ Never crash the app
├─ Always provide user feedback
├─ Offer alternatives (manual entry)
└─ Log errors for debugging
```

---

## 🧪 Testing Strategy

### **Unit Tests**

```
Test Modules:
│
├─ image_preprocessor_test.dart
│  ├─ Test YUV → RGB conversion accuracy
│  ├─ Test resize output dimensions
│  ├─ Test normalization range [0, 1]
│  └─ Test performance (<120ms)
│
├─ yolo_parser_test.dart
│  ├─ Test detection parsing
│  ├─ Test confidence filtering
│  ├─ Test coordinate conversion
│  └─ Test edge cases (empty output)
│
├─ nms_processor_test.dart
│  ├─ Test IoU calculation
│  ├─ Test suppression logic
│  └─ Test single detection case
│
├─ text_validator_test.dart
│  ├─ Test regex patterns
│  ├─ Test format validation
│  ├─ Test confidence calculation
│  └─ Test formatting output
│
└─ bbox_calculator_test.dart
   ├─ Test coordinate transformations
   ├─ Test padding calculation
   └─ Test boundary clamping
```

### **Integration Tests**

```
Test Scenarios:
│
├─ end_to_end_test.dart
│  ├─ Full pipeline: Camera → Result
│  ├─ Test with mock images
│  ├─ Verify timing < 2 seconds
│  └─ Verify result accuracy
│
├─ isolate_communication_test.dart
│  ├─ Test message serialization
│  ├─ Test result deserialization
│  ├─ Test error propagation
│  └─ Test timeout handling
│
└─ ui_interaction_test.dart
   ├─ Test scan button
   ├─ Test result display
   ├─ Test re-scan flow
   └─ Test error states
```

### **Performance Tests**

```
Benchmarks:
│
├─ Pre-processing: 