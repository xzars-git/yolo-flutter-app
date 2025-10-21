// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import '../controllers/license_plate_controller.dart';
import '../widgets/camera_inference_content.dart';
import '../widgets/license_plate_overlay.dart';
import '../widgets/camera_logo_overlay.dart';
import '../widgets/camera_controls.dart';
import '../widgets/threshold_slider.dart';

/// A screen dedicated to license plate recognition using YOLO.
///
/// This screen provides:
/// - Live camera feed with license plate detection
/// - Specialized overlay for plate recognition results
/// - Adjustable thresholds for plate detection
/// - Camera controls (flip, zoom)
/// - Performance metrics (FPS)
class LicensePlateScreen extends StatefulWidget {
  const LicensePlateScreen({super.key});

  @override
  State<LicensePlateScreen> createState() => _LicensePlateScreenState();
}

class _LicensePlateScreenState extends State<LicensePlateScreen> {
  late final LicensePlateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LicensePlateController();
    _controller.initialize().catchError((error) {
      if (mounted) {
        _showError('Model Loading Error', error.toString());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('License Plate Recognition'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              CameraInferenceContent(controller: _controller),
              LicensePlateOverlay(
                controller: _controller,
                isLandscape: isLandscape,
              ),
              CameraLogoOverlay(
                controller: _controller,
                isLandscape: isLandscape,
              ),
              CameraControls(
                currentZoomLevel: _controller.currentZoomLevel,
                isFrontCamera: _controller.isFrontCamera,
                activeSlider: _controller.activeSlider,
                onZoomChanged: _controller.setZoomLevel,
                onSliderToggled: _controller.toggleSlider,
                onCameraFlipped: _controller.flipCamera,
                isLandscape: isLandscape,
              ),
              ThresholdSlider(
                activeSlider: _controller.activeSlider,
                confidenceThreshold: _controller.confidenceThreshold,
                iouThreshold: _controller.iouThreshold,
                numItemsThreshold: _controller.numItemsThreshold,
                onValueChanged: _controller.updateSliderValue,
                isLandscape: isLandscape,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showError(String title, String message) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
