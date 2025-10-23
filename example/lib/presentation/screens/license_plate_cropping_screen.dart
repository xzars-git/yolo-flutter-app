// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../../features/ocr_plat_nomor/services/ocr_service.dart';

/// Enhanced license plate recognition demo with cropping + OCR feature
///
/// Flow: Detection → Cropping → OCR → Display Result
/// Automatically extracts license plate numbers from detected plates
class LicensePlateCroppingScreen extends StatefulWidget {
  const LicensePlateCroppingScreen({super.key});

  @override
  State<LicensePlateCroppingScreen> createState() => _LicensePlateCroppingScreenState();
}

/// Model untuk menyimpan plate data + OCR result
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

class _LicensePlateCroppingScreenState extends State<LicensePlateCroppingScreen> {
  final List<PlateData> _croppedPlates = [];
  int _totalDetected = 0;
  int _totalCropped = 0;
  int _totalOCRSuccess = 0;
  String _statusMessage = 'Memuat model plat nomor...';
  double _currentConfidence = 0.3;
  late final OCRService _ocrService;
  bool _isOCREnabled = true;

  // 🎯 NEW: Detection control untuk hemat CPU/memory
  bool _isDetectionActive = true; // Control detection ON/OFF
  bool _isProcessing = false; // Flag: sedang proses OCR
  bool _hasProcessedThisCycle = false; // 🎯 NEW: Prevent multiple crops di cycle yang sama
  // ignore: unused_field
  PlateData? _currentPlateProcessing; // Plate yang sedang diproses

  @override
  void initState() {
    super.initState();
    _ocrService = OCRService();
    _statusMessage = 'Siap untuk deteksi & OCR plat nomor!';
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// Process OCR automatically setelah cropping
  /// 🎯 NEW: Dengan auto-pause detection untuk hemat CPU
  Future<void> _processOCR(PlateData plateData, int index) async {
    if (!_isOCREnabled || !_ocrService.isReady) {
      debugPrint('⚠️ OCR disabled or not ready');
      _resumeDetection(); // Resume jika OCR disabled
      return;
    }

    setState(() {
      _isProcessing = true;
      _currentPlateProcessing = plateData;
      plateData.isProcessingOCR = true;
      _statusMessage = '⏳ Processing OCR... (Detection paused)';
    });

    try {
      // Extract text using OCR
      final ocrText = await _ocrService.extractLicensePlateText(plateData.croppedImage.imageBytes!);

      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;

          if (ocrText != null && ocrText.isNotEmpty) {
            // Format text jadi format plat nomor standar
            plateData.ocrText = _ocrService.formatLicensePlate(ocrText);
            plateData.ocrError = null;
            _totalOCRSuccess++;

            debugPrint('✅ OCR Result #${index + 1}: "${plateData.ocrText}"');
            _statusMessage = '✅ OCR Berhasil: ${plateData.ocrText}';

            // 🎯 Show confirmation dialog
            _showOCRResultDialog(plateData);
          } else {
            plateData.ocrError = 'Tidak ada text terdeteksi';
            debugPrint('⚠️ OCR #${index + 1}: No text detected');
            _statusMessage = '⚠️ OCR tidak menemukan text';

            // Resume detection jika gagal
            _resumeDetection();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          plateData.ocrError = 'OCR Error: $e';
          _statusMessage = '❌ OCR Error';
        });

        // Resume detection jika error
        _resumeDetection();
      }
      debugPrint('❌ OCR Error #${index + 1}: $e');
    }
  }

  /// Resume detection setelah OCR selesai atau error
  void _resumeDetection() {
    setState(() {
      _isDetectionActive = true;
      _isProcessing = false;
      _hasProcessedThisCycle = false; // 🎯 Reset flag
      _currentPlateProcessing = null;
      _statusMessage = '🔍 Detection resumed - Arahkan kamera ke plat nomor...';
    });
    debugPrint('▶️ Detection RESUMED');
  }

  /// Stop detection permanently (user choice)
  void _stopDetection() {
    setState(() {
      _isDetectionActive = false;
      _isProcessing = false;
      _hasProcessedThisCycle = false; // 🎯 Reset flag
      _currentPlateProcessing = null;
      _statusMessage = '⏹️ Detection stopped - Tekan tombol untuk mulai lagi';
    });
    debugPrint('⏹️ Detection STOPPED by user');
  }

  /// Start detection manually
  void _startDetection() {
    setState(() {
      _isDetectionActive = true;
      _isProcessing = false;
      _hasProcessedThisCycle = false; // 🎯 Reset flag
      _statusMessage = '🔍 Detection started - Arahkan kamera ke plat nomor...';
    });
    debugPrint('▶️ Detection STARTED by user');
  }

  /// Show OCR result dialog dengan konfirmasi
  void _showOCRResultDialog(PlateData plateData) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus pilih
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('OCR Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show cropped image
            if (plateData.croppedImage.hasImageData)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(plateData.croppedImage.imageBytes!, fit: BoxFit.contain),
                ),
              ),
            const SizedBox(height: 16),

            // OCR Result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Hasil OCR Plat Nomor:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plateData.ocrText ?? 'N/A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${(plateData.croppedImage.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🎯 Pertanyaan konfirmasi yang jelas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline, color: Colors.blue.shade700, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Apakah hasil OCR sudah benar?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Periksa apakah plat nomor di atas sudah sesuai dengan gambar',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tidak Benar - Detect lagi
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('❌ User: OCR tidak benar - Detect lagi');
              _resumeDetection();
            },
            icon: const Icon(Icons.refresh, color: Colors.orange),
            label: const Text(
              'Tidak Benar\nDetect Lagi',
              style: TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ),

          // Sudah Benar - Stop
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('✅ User: OCR sudah benar - Stop detection');
              _stopDetection();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Data tersimpan: ${plateData.ocrText}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Sudah Benar\nSimpan Data', textAlign: TextAlign.center),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 License Plate Detection & Cropping'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: _showInfoDialog)],
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
                    _buildStatItem('OCR Success', _totalOCRSuccess.toString(), Icons.text_fields),
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
                  // 🎯 Dynamic config based on detection state
                  streamingConfig: YOLOStreamingConfig(
                    enableCropping: true, // 🎯 FORCE ENABLE untuk test OCR
                    croppingPadding: 0.1, // Small padding untuk OCR
                    croppingQuality: 90, // High quality JPEG compression
                    inferenceFrequency: _isDetectionActive && !_isProcessing
                        ? 15
                        : 1, // 🎯 1 FPS saat pause (hemat CPU)
                    includeDetections:
                        _isDetectionActive && !_isProcessing, // 🎯 Disable saat processing
                    includeOriginalImage:
                        _isDetectionActive && !_isProcessing, // 🎯 Disable saat processing
                    includeFps: false,
                    includeProcessingTimeMs: false,
                  ),

                  // Handle cropped license plates → Auto OCR
                  // 🎯 NEW: Process hanya 1 plate, pause detection
                  onCroppedImages: (List<YOLOCroppedImage> images) async {
                    // 🎯 CRITICAL: Skip jika sedang processing atau detection inactive atau sudah proses
                    if (_isProcessing ||
                        !_isDetectionActive ||
                        images.isEmpty ||
                        _hasProcessedThisCycle) {
                      debugPrint(
                        '⚠️ Skipping crop: processing=$_isProcessing, active=$_isDetectionActive, hasProcessed=$_hasProcessedThisCycle',
                      );
                      return;
                    }

                    // 🎯 Set flag IMMEDIATELY untuk prevent multiple calls
                    _hasProcessedThisCycle = true;

                    // 🎯 Ambil hanya plate PERTAMA (ignore sisanya untuk hemat CPU)
                    final img = images.first;

                    // 🎯 PAUSE detection immediately
                    setState(() {
                      _isDetectionActive = false; // Stop detection
                      _totalCropped++;
                    });

                    debugPrint('⏸️ Detection PAUSED - Starting OCR...');

                    // Create PlateData object
                    final plateData = PlateData(croppedImage: img);

                    setState(() {
                      _croppedPlates.add(plateData);

                      // Keep only last 12 cropped plates
                      if (_croppedPlates.length > 12) {
                        _croppedPlates.removeAt(0);
                      }
                    });

                    // Debug logging
                    debugPrint('🚗 ========== CROPPED PLATE DETAILS ==========');
                    debugPrint('   Class: ${img.clsName}');
                    debugPrint('   Confidence: ${(img.confidence * 100).toStringAsFixed(1)}%');
                    debugPrint('   Crop Size: ${img.width}x${img.height} pixels');
                    debugPrint('   Aspect Ratio: ${(img.width / img.height).toStringAsFixed(2)}');

                    // ✨ AUTO OCR PROCESSING ✨
                    final currentIndex = _croppedPlates.length - 1;
                    await _processOCR(plateData, currentIndex);

                    debugPrint('==========================================');
                  },

                  // Handle detection results
                  // 🎯 NEW: Update status hanya jika detection active
                  onResult: (List<YOLOResult> results) {
                    if (!_isProcessing) {
                      setState(() {
                        _totalDetected += results.length;

                        if (!_isDetectionActive) {
                          _statusMessage = '⏸️ Detection paused - Processing OCR...';
                        } else if (results.isEmpty) {
                          _statusMessage = '🔍 Arahkan kamera ke plat nomor kendaraan...';
                        } else {
                          _statusMessage =
                              '✅ ${results.length} plat terdeteksi - memproses cropping...';
                        }
                      });
                    }
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
                        Row(
                          children: [
                            // 🎯 Start/Stop Detection Button
                            IconButton(
                              icon: Icon(
                                _isDetectionActive ? Icons.pause_circle : Icons.play_circle,
                                color: _isDetectionActive ? Colors.orange : Colors.greenAccent,
                                size: 28,
                              ),
                              tooltip: _isDetectionActive ? 'Pause Detection' : 'Start Detection',
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      if (_isDetectionActive) {
                                        _stopDetection();
                                      } else {
                                        _startDetection();
                                      }
                                    },
                            ),

                            // OCR Toggle
                            IconButton(
                              icon: Icon(
                                _isOCREnabled ? Icons.text_fields : Icons.text_fields_outlined,
                                color: _isOCREnabled ? Colors.greenAccent : Colors.white54,
                              ),
                              tooltip: _isOCREnabled ? 'OCR Enabled' : 'OCR Disabled',
                              onPressed: () {
                                setState(() {
                                  _isOCREnabled = !_isOCREnabled;
                                  _statusMessage = _isOCREnabled
                                      ? '✅ OCR Activated!'
                                      : '⏹️ OCR Deactivated';
                                });
                              },
                            ),

                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _croppedPlates.clear();
                                  _totalCropped = 0;
                                  _totalDetected = 0;
                                  _totalOCRSuccess = 0;
                                  _statusMessage = '🗑️ Gallery cleared. Ready for new detections.';
                                });
                              },
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('Clear'),
                              style: TextButton.styleFrom(foregroundColor: Colors.white70),
                            ),
                          ],
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
                                  _isDetectionActive
                                      ? Icons.directions_car_outlined
                                      : Icons.pause_circle_outlined,
                                  size: 64,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isDetectionActive
                                      ? 'Belum ada plat nomor yang di-crop'
                                      : 'Detection paused',
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isDetectionActive
                                      ? 'Arahkan kamera ke plat nomor untuk auto-crop & OCR'
                                      : 'Tekan tombol play untuk mulai detection',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEnhancedPlateCard(PlateData plateData, int index) {
    final plate = plateData.croppedImage;
    return GestureDetector(
      onTap: () => _showPlateDetails(plateData, index),
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
                  child: Image.memory(plate.imageBytes!, fit: BoxFit.contain),
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

            // OCR Result Badge
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: plateData.isProcessingOCR
                      ? Colors.orange.withValues(alpha: 0.9)
                      : plateData.ocrText != null
                      ? Colors.green.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: plateData.isProcessingOCR
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'OCR...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        plateData.ocrText ?? '${plate.width}×${plate.height}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: plateData.ocrText != null ? 7 : 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  void _showPlateDetails(PlateData plateData, int index) {
    final plate = plateData.croppedImage;
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
                    child: Image.memory(plate.imageBytes!, height: 150, fit: BoxFit.contain),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Class', plate.clsName, Icons.label),
              _buildDetailRow(
                'Confidence',
                '${(plate.confidence * 100).toStringAsFixed(2)}%',
                Icons.percent,
              ),
              _buildDetailRow(
                'Dimensions',
                '${plate.width} × ${plate.height} pixels',
                Icons.aspect_ratio,
              ),
              _buildDetailRow(
                'File Size',
                '${(plate.sizeBytes / 1024).toStringAsFixed(1)} KB',
                Icons.storage,
              ),
              _buildDetailRow(
                'Original Position',
                '(${plate.originalBox.x1.toStringAsFixed(0)}, ${plate.originalBox.y1.toStringAsFixed(0)}) → '
                    '(${plate.originalBox.x2.toStringAsFixed(0)}, ${plate.originalBox.y2.toStringAsFixed(0)})',
                Icons.crop,
              ),

              // OCR Result Section
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.text_fields, size: 20, color: Colors.indigo.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'OCR Result:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (plateData.isProcessingOCR)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processing OCR...',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else if (plateData.ocrText != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              plateData.ocrText!,
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Valid: ${_ocrService.isValidIndonesianPlate(plateData.ocrText!) ? "Yes ✓" : "Unknown"}',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else if (plateData.ocrError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plateData.ocrError!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'OCR not processed',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

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
                        'OCR automatically processes each cropped license plate to extract the text.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
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
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
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
            Text('About License Plate Cropping + OCR'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This demo shows automatic license plate detection, cropping, and OCR using YOLO + ML Kit.',
            ),
            SizedBox(height: 8),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Real-time license plate detection'),
            Text('• Automatic cropping with padding'),
            Text('• Instant OCR text extraction'),
            Text('• Smart pause/resume (hemat CPU)'),
            Text('• User confirmation after OCR'),
            Text('• Confidence threshold adjustment'),
            SizedBox(height: 8),
            Text(
              'The system automatically pauses detection during OCR processing to save CPU/memory, then asks for confirmation before continuing.',
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }
}
