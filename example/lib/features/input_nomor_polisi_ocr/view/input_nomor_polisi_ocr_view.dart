import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/controller/input_nomor_polisi_ocr_controller.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/widget/content_input_nopol_ocr.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/models/plate_data.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/widget/button/secondary_button.dart';

class InputNomorPolisiOcrView extends StatefulWidget {
  const InputNomorPolisiOcrView({super.key});

  Widget build(context, InputNomorPolisiOcrController controller) {
    controller.view = this;
    
    return Scaffold(
      appBar: AppBar(backgroundColor:  Theme.of(context).colorScheme.primary, title: const Text("Telusur Mandiri"), actions: const []),
      body: Column(
        children: [
          // Info Banner
         controller.isInputNopol
                ?  Container():Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: blue50,
              border: Border(bottom: BorderSide(color: blue200, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: blue600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.ocrStatusMessage,
                    style: const TextStyle(color: blue900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),

          // Main Content
          Expanded(
            child: controller.isInputNopol
                ? ContentInputNopolOcr(controller: controller)
                : _buildCameraView(controller),
          ),
          // Toggle Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: neutralWhite,
              child: controller.isInputNopol
                  ? SecondaryButton(
                      onPressed: () {
                        controller.isInputNopol = false;
                        controller.dataNopol = const UpdateNopol();
                        controller.pathPhoto = "";
                        controller.noPolisi1 = "";
                        controller.noPolisi2 = "";
                        controller.noPolisi3 = "";
                        controller.kodePlat = "1";
                        controller.resumeDetection();
                      },
                      text: "Beralih ke Pemindaian",
                    )
                  : SecondaryButton(
                      onPressed: () {
                        controller.isInputNopol = true;
                        controller.stopDetection();
                      },
                      text: "Input Nomor Polisi",
                    ),
            ),
          ),          
          const SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(InputNomorPolisiOcrController controller) {
    // ✅ Tampilkan loading indicator saat requesting permissions
    if (controller.isRequestingPermissions) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '🔐 Meminta izin akses...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon izinkan akses lokasi dan kamera',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    
    // ✅ Tampilkan error jika permission ditolak
    if (!controller.isPermissionsGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              '❌ Izin Akses Ditolak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi memerlukan izin kamera untuk scan plat nomor',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.onReady(); // Retry permission request
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
    
    // ✅ Camera view - hanya render setelah permission granted
    return YOLOView(
      key: const ValueKey('yolo_camera_view'),
      modelPath: 'plat_recognation.tflite',
      task: YOLOTask.detect,
      iouThreshold: 0.20,
      confidenceThreshold: 0.25,
      showOverlays: true,
      
      streamingConfig: const YOLOStreamingConfig(
        enableCropping: true,
        croppingPadding: 0.15, // Increased padding for better crop context
        croppingQuality: 95, // Higher quality for better OCR
        inferenceFrequency: 15,
        includeDetections: true,
        includeOriginalImage: true, // CRITICAL: Enable original image for cropping
      ),
      
      onStreamingData: (Map<String, dynamic> data) {
        if (controller.isProcessing) return;
        
        final now = DateTime.now();
        final timeSinceLastUpdate = now.difference(controller.lastCallbackTime).inMilliseconds;
        
        if (timeSinceLastUpdate < InputNomorPolisiOcrController.callbackDebounceMs) return;
        controller.lastCallbackTime = now;
        
        final detections = data['detections'] as List?;
        final detectionCount = detections?.length ?? 0;
        
        if (detectionCount > 0) {
          controller.totalDetected += detectionCount;
        }
        
        if (!controller.isDetectionActive) {
          controller.ocrStatusMessage = '⏸️ Detection paused - Processing OCR...';
        } else if (detectionCount == 0) {
          controller.ocrStatusMessage = 'Terhubung ke printer COMSON 77';
        } else {
          controller.ocrStatusMessage = '✅ $detectionCount plat terdeteksi';
        }
      },
      
      onCroppedImages: (List<YOLOCroppedImage> images) async {
        print('[OCR DEBUG] onCroppedImages called with ${images.length} images');
        
        // ✅ HENTIKAN cropping jika sedang processing OCR ATAU checking API
        if (images.isEmpty || !controller.isDetectionActive || controller.isProcessing || controller.isCheckingAPI) {
          print('[OCR DEBUG] Skipped - isEmpty: ${images.isEmpty}, isDetectionActive: ${controller.isDetectionActive}, isProcessing: ${controller.isProcessing}, isCheckingAPI: ${controller.isCheckingAPI}');
          return;
        }
        
        final now = DateTime.now();
        final timeSinceLastCallback = now.difference(controller.lastCallbackTime).inMilliseconds;
        if (timeSinceLastCallback < InputNomorPolisiOcrController.callbackDebounceMs) {
          print('[OCR DEBUG] Skipped - debounce ($timeSinceLastCallback ms < ${InputNomorPolisiOcrController.callbackDebounceMs} ms)');
          return;
        }
        controller.lastCallbackTime = now;

        final img = images.first;
        
        if (!controller.ocrService.isReady) {
          print('[OCR DEBUG] Skipped - OCR service not ready');
          controller.resumeDetection();
          return;
        }

        if (img.imageBytes == null || img.imageBytes!.isEmpty) {
          print('[OCR DEBUG] Skipped - image bytes null or empty');
          controller.resumeDetection();
          return;
        }

        print('[OCR DEBUG] Processing OCR for image with ${img.imageBytes!.length} bytes');
        
        final plateData = PlateData(croppedImage: img);
        
        controller.totalCropped++;
        controller.croppedPlates.add(plateData);
        if (controller.croppedPlates.length > 12) {
          controller.croppedPlates.removeAt(0);
        }

        final currentIndex = controller.croppedPlates.length - 1;
        await controller.processOCR(plateData, currentIndex);
      },
    );
  }

  @override
  State<InputNomorPolisiOcrView> createState() => InputNomorPolisiOcrController();
}
