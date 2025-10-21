// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../controllers/license_plate_controller.dart';
import 'detection_stats_display.dart';
import 'threshold_pill.dart';

/// Overlay widget specialized for license plate recognition
class LicensePlateOverlay extends StatelessWidget {
  const LicensePlateOverlay({
    super.key,
    required this.controller,
    required this.isLandscape,
  });

  final LicensePlateController controller;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + (isLandscape ? 8 : 16),
      left: isLandscape ? 8 : 16,
      right: isLandscape ? 8 : 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildModelIndicator(),
          SizedBox(height: isLandscape ? 8 : 12),
          DetectionStatsDisplay(
            detectionCount: controller.detectionCount,
            currentFps: controller.currentFps,
          ),
          const SizedBox(height: 8),
          _buildThresholdPills(),
          const SizedBox(height: 8),
          _buildDetectedPlatesInfo(),
        ],
      ),
    );
  }

  Widget _buildModelIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_car,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'PLAT RECOGNITION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (controller.isModelLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThresholdPills() {
    if (controller.activeSlider == SliderType.confidence) {
      return ThresholdPill(
        label:
            'CONFIDENCE THRESHOLD: ${controller.confidenceThreshold.toStringAsFixed(2)}',
      );
    } else if (controller.activeSlider == SliderType.iou) {
      return ThresholdPill(
        label: 'IOU THRESHOLD: ${controller.iouThreshold.toStringAsFixed(2)}',
      );
    } else if (controller.activeSlider == SliderType.numItems) {
      return ThresholdPill(label: 'ITEMS MAX: ${controller.numItemsThreshold}');
    }
    return const SizedBox.shrink();
  }

  Widget _buildDetectedPlatesInfo() {
    if (controller.lastResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Arahkan kamera ke plat nomor kendaraan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '${controller.lastResults.length} Plat Terdeteksi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...controller.lastResults.take(3).map((result) {
            final confidence = (result.confidence * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Confidence: $confidence%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
