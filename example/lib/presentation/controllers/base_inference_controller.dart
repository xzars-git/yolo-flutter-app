// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import '../../models/models.dart';

/// Base abstract controller for YOLO inference screens
abstract class BaseInferenceController extends ChangeNotifier {
  // Common getters that all inference controllers should have
  int get detectionCount;
  double get currentFps;
  double get confidenceThreshold;
  double get iouThreshold;
  int get numItemsThreshold;
  SliderType get activeSlider;
  ModelType get selectedModel;
  bool get isModelLoading;
  String? get modelPath;
  String get loadingMessage;
  double get downloadProgress;
  double get currentZoomLevel;
  bool get isFrontCamera;
  YOLOViewController get yoloController;

  // Common methods that all inference controllers should implement
  void onDetectionResults(List<YOLOResult> results);
  void onPerformanceMetrics(double fps);
  void onZoomChanged(double zoomLevel);
  void toggleSlider(SliderType type);
  void updateSliderValue(double value);
  void setZoomLevel(double zoomLevel);
  void flipCamera();
  Future<void> initialize();
}
