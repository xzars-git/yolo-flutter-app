import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/controller/input_nomor_polisi_ocr_controller.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/widget/content_input_nopol_ocr.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/widget/button/secondary_button.dart';

class InputNomorPolisiOcrView extends StatefulWidget {
  const InputNomorPolisiOcrView({super.key});

  Widget build(context, InputNomorPolisiOcrController controller) {
    controller.view = this;
    return Scaffold(
      appBar: AppBar(title: const Text("Telusur Mandiri"), actions: const []),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  
                //   YOLOView(
                //   modelPath: 'android/app/src/main/assets/plat_recognation.tflite',
                //   task: YOLOTask.detect,
                //   confidenceThreshold: 0.5,
                //   streamingConfig: const YOLOStreamingConfig(
                //     enableCropping: true,
                //     croppingPadding: 0.1,
                //     croppingQuality: 90,
                //     inferenceFrequency: 15,
                //     includeDetections: true,
                //     includeOriginalImage: true,
                //   ),
                  
                //   onStreamingData: (Map<String, dynamic> data) {
                //     if (_isProcessing) return;
                    
                //     final now = DateTime.now();
                //     final timeSinceLastUpdate = now.difference(_lastCallbackTime).inMilliseconds;
                    
                //     if (timeSinceLastUpdate < _callbackDebounceMs) return;
                //     _lastCallbackTime = now;
                    
                //     final detections = data['detections'] as List?;
                //     final detectionCount = detections?.length ?? 0;
                    
                //     setState(() {
                //       if (detectionCount > 0) {
                //         _totalDetected += detectionCount;
                //       }
                      
                //       if (!_isDetectionActive) {
                //         _statusMessage = '⏸️ Detection paused - Processing OCR...';
                //       } else if (detectionCount == 0) {
                //         _statusMessage = '🔍 Arahkan kamera ke plat nomor...';
                //       } else {
                //         _statusMessage = '✅ $detectionCount plat terdeteksi';
                //       }
                //     });
                //   },
                  
                //   onCroppedImages: (List<YOLOCroppedImage> images) async {
                 
                    
                //     if (images.isEmpty) {
                //       return;
                //     }

                //     if (!_isDetectionActive || _isProcessing) {
                //       return;
                //     }
                    
                //     final now = DateTime.now();
                //     final timeSinceLastCallback = now.difference(_lastCallbackTime).inMilliseconds;
                //     if (timeSinceLastCallback < _callbackDebounceMs) {
                //       return;
                //     }
                //     _lastCallbackTime = now;

                //     final img = images.first;
                    
                //     if (!_ocrService.isReady) {
                //       _resumeDetection();
                //       return;
                //     }

                //     if (img.imageBytes == null || img.imageBytes!.isEmpty) {
                //       _resumeDetection();
                //       return;
                //     }


                //     final plateData = PlateData(croppedImage: img);
                    
                //     setState(() {
                //       _isDetectionActive = false;
                //       _totalCropped++;
                //       _croppedPlates.add(plateData);
                //       if (_croppedPlates.length > 12) {
                //         _croppedPlates.removeAt(0);
                //       }
                //     });

                //     final currentIndex = _croppedPlates.length - 1;
                //     await _processOCR(plateData, currentIndex);
                    
                //   },
                // ),
                  
                  if (controller.isInputNopol)
                    Expanded(child: ContentInputNopolOcr(controller: controller)),
                ],
              ),
            ),
          ),
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
                        controller.update();
                      },
                      text: "Beralih ke Pemindaian",
                    )
                  : SecondaryButton(
                      onPressed: () {
                        controller.isInputNopol = true;
                        controller.dataNopol = const UpdateNopol();
                        controller.pathPhoto = "";
                        controller.noPolisi1 = "";
                        controller.noPolisi2 = "";
                        controller.noPolisi3 = "";
                        controller.kodePlat = "1";
                        controller.update();
                      },
                      text: "Input Nomor Polisi",
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<InputNomorPolisiOcrView> createState() => InputNomorPolisiOcrController();
}
