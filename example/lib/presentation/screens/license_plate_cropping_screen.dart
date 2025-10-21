// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Enhanced license plate recognition demo with cropping feature
/// 
/// This shows how to use automatic image cropping specifically for license plates,
/// useful for OCR processing and plate number recognition.
class LicensePlateCroppingScreen extends StatefulWidget {
  const LicensePlateCroppingScreen({super.key});

  @override
  State<LicensePlateCroppingScreen> createState() => _LicensePlateCroppingScreenState();
}

class _LicensePlateCroppingScreenState extends State<LicensePlateCroppingScreen> {
  List<YOLOCroppedImage> _croppedPlates = [];
  int _totalDetected = 0;
  int _totalCropped = 0;
  String _statusMessage = 'Memuat model plat nomor...';
  double _currentConfidence = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 License Plate Detection & Cropping'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Stats and Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Detected', _totalDetected.toString(), Icons.visibility),
                    _buildStatItem('Cropped', _totalCropped.toString(), Icons.crop),
                    _buildStatItem('Stored', _croppedPlates.length.toString(), Icons.storage),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Confidence threshold slider
                Row(
                  children: [
                    const Text('Confidence: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: _currentConfidence,
                        min: 0.1,
                        max: 0.9,
                        divisions: 8,
                        label: '${(_currentConfidence * 100).toStringAsFixed(0)}%',
                        onChanged: (value) {
                          setState(() {
                            _currentConfidence = value;
                          });
                        },
                      ),
                    ),
                    Text('${(_currentConfidence * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ],
            ),
          ),

          // Camera view with enhanced cropping
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: YOLOView(
                  modelPath: 'plat_recognation.tflite',
                  task: YOLOTask.detect,
                  confidenceThreshold: _currentConfidence,
                  
                  // Enhanced streaming configuration for license plates
                  streamingConfig: const YOLOStreamingConfig(
                    enableCropping: true,        // Enable automatic cropping
                    croppingPadding: 0.15,       // 15% padding - same as before
                    croppingQuality: 95,         // High quality
                    inferenceFrequency: 10,      // Balanced performance
                    includeDetections: true,     // Include detection data
                    includeOriginalImage: true,  // CRITICAL: Required for cropping!
                  ),
                  
                  // Handle cropped license plates
                  onCroppedImages: (List<YOLOCroppedImage> images) {
                    setState(() {
                      _totalCropped += images.length;
                      
                      // Add new cropped images
                      _croppedPlates.addAll(images);
                      
                      // Keep only last 12 cropped plates
                      if (_croppedPlates.length > 12) {
                        _croppedPlates = _croppedPlates.skip(_croppedPlates.length - 12).toList();
                      }
                      
                      // Update status
                      if (images.isNotEmpty) {
                        _statusMessage = 'Berhasil crop ${images.length} plat nomor! Siap untuk OCR.';
                      }
                    });

                    // Detailed logging for license plates
                    for (final img in images) {
                      debugPrint('🚗 Cropped License Plate: ${img.clsName} '
                          '| Size: ${img.width}x${img.height} '
                          '| Confidence: ${(img.confidence * 100).toStringAsFixed(1)}% '
                          '| File Size: ${(img.sizeBytes / 1024).toStringAsFixed(1)}KB');
                    }
                  },
                  
                  // Handle detection results
                  onResult: (List<YOLOResult> results) {
                    setState(() {
                      _totalDetected += results.length;
                      
                      if (results.isEmpty) {
                        _statusMessage = 'Arahkan kamera ke plat nomor kendaraan...';
                      } else {
                        _statusMessage = '${results.length} plat terdeteksi - memproses cropping...';
                      }
                    });
                  },
                ),
              ),
            ),
          ),

          // Enhanced cropped plates gallery
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cropped License Plates',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _croppedPlates.clear();
                              _totalCropped = 0;
                              _totalDetected = 0;
                              _statusMessage = 'Gallery cleared. Ready for new detections.';
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _croppedPlates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 64,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada plat nomor yang di-crop',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Arahkan kamera ke plat nomor untuk melihat hasil cropping',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _croppedPlates.length,
                            itemBuilder: (context, index) {
                              return _buildEnhancedPlateCard(_croppedPlates[index], index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.indigo),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedPlateCard(YOLOCroppedImage plate, int index) {
    return GestureDetector(
      onTap: () => _showPlateDetails(plate, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo.shade300, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cropped plate image
            if (plate.hasImageData)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  child: Image.memory(
                    plate.imageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Index number
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Confidence badge
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(plate.confidence),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(plate.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Size info
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${plate.width}×${plate.height}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.7) return Colors.green.shade600;
    if (confidence > 0.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  void _showPlateDetails(YOLOCroppedImage plate, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.indigo),
            const SizedBox(width: 8),
            Text('License Plate #${index + 1}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plate.hasImageData)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      plate.imageBytes!,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Class', plate.clsName, Icons.label),
              _buildDetailRow('Confidence', '${(plate.confidence * 100).toStringAsFixed(2)}%', Icons.percent),
              _buildDetailRow('Dimensions', '${plate.width} × ${plate.height} pixels', Icons.aspect_ratio),
              _buildDetailRow('File Size', '${(plate.sizeBytes / 1024).toStringAsFixed(1)} KB', Icons.storage),
              _buildDetailRow('Original Position', 
                  '(${plate.originalBox.x1.toStringAsFixed(0)}, ${plate.originalBox.y1.toStringAsFixed(0)}) → '
                  '(${plate.originalBox.x2.toStringAsFixed(0)}, ${plate.originalBox.y2.toStringAsFixed(0)})', 
                  Icons.crop),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This cropped image is ready for OCR processing to extract the license plate number.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.indigo),
            SizedBox(width: 8),
            Text('About License Plate Cropping'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This demo shows automatic license plate detection and cropping using YOLO.'),
            SizedBox(height: 8),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Real-time license plate detection'),
            Text('• Automatic cropping with padding'),
            Text('• High-quality image extraction for OCR'),
            Text('• Confidence threshold adjustment'),
            SizedBox(height: 8),
            Text('The cropped images are ready for OCR processing to extract plate numbers.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
