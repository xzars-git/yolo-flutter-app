import 'package:ultralytics_yolo/models/yolo_cropped_image.dart';

class PlateData {
  final YOLOCroppedImage croppedImage;
  String? ocrText;
  bool isProcessingOCR;
  String? ocrError;

  PlateData({
    required this.croppedImage,
    this.ocrText,
    this.isProcessingOCR = false,
    this.ocrError,
  });
}