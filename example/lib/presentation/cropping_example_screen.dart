import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Example demonstrating the new cropping feature for license plate detection
/// 
/// This shows how to use automatic image cropping for detected license plates,
/// useful for OCR, secondary classification, or any post-processing needs.
class CroppingExampleScreen extends StatefulWidget {
  const CroppingExampleScreen({super.key});

  @override
  State<CroppingExampleScreen> createState() => _CroppingExampleScreenState();
}

class _CroppingExampleScreenState extends State<CroppingExampleScreen> {
  List<YOLOCroppedImage> _croppedImages = [];
  int _totalCropped = 0;
  int _totalDetections = 0;
  String _statusMessage = 'Loading model...';
  bool _enableCropping = true;
  double _croppingPadding = 0.1;
  int _croppingQuality = 85;
  
  @override
  void initState() {
    super.initState();
    // Initialize with debug message
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _statusMessage = 'Model loaded. Arahkan kamera ke plat nomor...';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 License Plate Cropping Demo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Detected', _totalDetections.toString()),
                    _buildStatItem('Cropped', _totalCropped.toString()),
                    _buildStatItem('In Memory', _croppedImages.length.toString()),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Cropping controls
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enable cropping switch
                SwitchListTile(
                  title: const Text('Enable Cropping'),
                  subtitle: Text(_enableCropping ? 'Enabled' : 'Disabled'),
                  value: _enableCropping,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _enableCropping = value;
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                
                // Padding slider
                Text(
                  'Padding: ${(_croppingPadding * 100).toInt()}%',
                  style: const TextStyle(fontSize: 14),
                ),
                Slider(
                  value: _croppingPadding,
                  min: 0.0,
                  max: 0.5,
                  divisions: 10,
                  activeColor: Colors.green,
                  label: '${(_croppingPadding * 100).toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      _croppingPadding = value;
                    });
                  },
                ),
                
                // Quality slider
                Text(
                  'Quality: $_croppingQuality',
                  style: const TextStyle(fontSize: 14),
                ),
                Slider(
                  value: _croppingQuality.toDouble(),
                  min: 50,
                  max: 100,
                  divisions: 10,
                  activeColor: Colors.green,
                  label: '$_croppingQuality',
                  onChanged: (value) {
                    setState(() {
                      _croppingQuality = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ),

          // Camera view with cropping enabled
          Expanded(
            flex: 2,
            child: YOLOView(
              modelPath: 'plat_recognation.tflite',
              task: YOLOTask.detect,
              confidenceThreshold: 0.25,
              
              // 🔥 Enable cropping with configurable parameters
              streamingConfig: YOLOStreamingConfig(
                enableCropping: _enableCropping,
                includeDetections: true,
                includeOriginalImage: true, // REQUIRED for cropping!
                croppingPadding: _croppingPadding,
                croppingQuality: _croppingQuality,
              ),
              
              // Handle cropped license plates
              onCroppedImages: (List<YOLOCroppedImage> images) {
                if (images.isNotEmpty) {
                  setState(() {
                    _totalCropped += images.length;
                    _croppedImages.addAll(images);
                    if (_croppedImages.length > 9) {
                      _croppedImages = _croppedImages.skip(_croppedImages.length - 9).toList();
                    }
                    _statusMessage = 'Berhasil crop ${images.length} plat! Total: $_totalCropped';
                  });
                }
              },
              
              // Handle regular detection results
              onResult: (List<YOLOResult> results) {
                if (results.isNotEmpty) {
                  setState(() {
                    _totalDetections += results.length;
                    final firstConf = results.first.confidence;
                    _statusMessage = '${results.length} plat terdeteksi (${(firstConf * 100).toStringAsFixed(1)}%)';
                  });
                } else {
                  setState(() {
                    _statusMessage = 'Arahkan kamera ke plat nomor...';
                  });
                }
              },
            ),
          ),

          // Cropped images gallery
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Cropped License Plates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _croppedImages.clear();
                              _totalCropped = 0;
                              _totalDetections = 0;
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _croppedImages.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada plat yang dipotong...\nDeteksi plat nomor untuk melihat hasil cropping',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: _croppedImages.length,
                            itemBuilder: (context, index) {
                              return _buildCroppedImageCard(_croppedImages[index]);
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCroppedImageCard(YOLOCroppedImage croppedImage) {
    return GestureDetector(
      onTap: () => _showCroppedImageDetails(croppedImage),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cropped image
            if (croppedImage.hasImageData)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  croppedImage.imageBytes!,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Label overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text(
                  croppedImage.clsName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Confidence badge
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(croppedImage.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCroppedImageDetails(YOLOCroppedImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(image.clsName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.hasImageData)
              Center(
                child: Image.memory(
                  image.imageBytes!,
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailRow('Class', image.clsName),
            _buildDetailRow('Confidence', '${(image.confidence * 100).toStringAsFixed(1)}%'),
            _buildDetailRow('Size', '${image.width} x ${image.height}'),
            _buildDetailRow('File Size', '${(image.sizeBytes / 1024).toStringAsFixed(1)} KB'),
            _buildDetailRow('Original Box', 
                '(${image.originalBox.x1.toStringAsFixed(0)}, '
                '${image.originalBox.y1.toStringAsFixed(0)}) → '
                '(${image.originalBox.x2.toStringAsFixed(0)}, '
                '${image.originalBox.y2.toStringAsFixed(0)})'),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
