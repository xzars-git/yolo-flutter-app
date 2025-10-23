// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../services/ocr_service.dart';
import '../services/pajak_service.dart';
import '../../../app/theme.dart';

/// Enhanced license plate recognition demo with cropping + OCR + API
/// 
/// Flow: Detection → Cropping → OCR → API → Display Result
/// Architecture: Modular MVC (features/ocr_plat_nomor/)
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
  List<PlateData> _croppedPlates = [];
  int _totalDetected = 0;
  int _totalCropped = 0;
  int _totalOCRSuccess = 0;
  String _statusMessage = 'Memuat model plat nomor...';
  double _currentConfidence = 0.3;
  late final OCRService _ocrService;
  late final PajakService _pajakService;
  bool _isOCREnabled = true;
  bool _isCheckingAPI = false;
  
  // 🎯 Detection control - HANYA 2 FLAGS (fixed, no more _hasProcessedThisCycle!)
  bool _isDetectionActive = true;  // Control detection ON/OFF
  bool _isProcessing = false;       // Flag: sedang proses OCR
  
  // 🔥 FIX: Debounce callback to prevent rapid setState() calls
  DateTime _lastCallbackTime = DateTime.now();
  static const _callbackDebounceMs = 300; // Min 300ms between callbacks

  @override
  void initState() {
    super.initState();
    _ocrService = OCRService();
    _pajakService = PajakService();
    _statusMessage = 'Siap untuk deteksi & OCR plat nomor!';
    
    // Debug initial state
    print('🚀 ========== LicensePlateCroppingScreen INITIALIZED ==========');
    print('   _isDetectionActive: $_isDetectionActive');
    print('   _isProcessing: $_isProcessing');
    print('   _isOCREnabled: $_isOCREnabled');
    print('   OCR Service Ready: ${_ocrService.isReady}');
    print('===============================================================');
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// Process OCR automatically setelah cropping
  Future<void> _processOCR(PlateData plateData, int index) async {
    if (!_isOCREnabled || !_ocrService.isReady) {
      print('⚠️ OCR disabled or not ready');
      plateData.ocrError = 'OCR service not ready';
      _showOCRResultDialog(plateData);
      return;
    }

    setState(() {
      _isProcessing = true;
      plateData.isProcessingOCR = true;
      _statusMessage = '⏳ Processing OCR... (Detection paused)';
    });

    // Save debug crop
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/debug_crop_$timestamp.jpg');
      await tempFile.writeAsBytes(plateData.croppedImage.imageBytes!);
      debugPrint('💾 Saved debug crop: ${tempFile.path}');
    } catch (e) {
      debugPrint('⚠️ Failed to save debug crop: $e');
    }

    try {
      print('🔍 Starting OCR processing for crop #${index + 1}...');
      final ocrText = await _ocrService.extractLicensePlateText(
        plateData.croppedImage.imageBytes!,
      );

      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          
          if (ocrText != null && ocrText.isNotEmpty) {
            final formatted = _ocrService.formatLicensePlate(ocrText);
            plateData.ocrText = formatted;
            plateData.ocrError = null;
            _totalOCRSuccess++;
            
            print('✅ OCR SUCCESS: "$formatted"');
            _statusMessage = '🚀 Checking pajak info via API...';
          } else {
            plateData.ocrError = 'Tidak ada text terdeteksi';
            print('⚠️ OCR #${index + 1}: No text detected');
            _statusMessage = '⚠️ OCR tidak menemukan text';
          }
        });
        
        // Hit API jika OCR berhasil
        if (plateData.ocrText != null && plateData.ocrText!.isNotEmpty) {
          _checkPajakInfo(plateData.ocrText!);
        } else {
          _showOCRResultDialog(plateData);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          plateData.isProcessingOCR = false;
          plateData.ocrError = 'OCR Error: $e';
          _statusMessage = '❌ OCR Error';
        });
        
        print('❌ OCR Error #${index + 1}: $e');
        _showOCRResultDialog(plateData);
      }
    }
  }

  /// Hit API untuk cek info pajak
  void _checkPajakInfo(String platNomor) async {
    setState(() => _isCheckingAPI = true);

    try {
      print('');
      print('🚀 ========================================');
      print('🚀 CHECKING PAJAK INFO');
      print('🚀 Plat Nomor: $platNomor');
      print('🚀 ========================================');
      
      final pajakInfo = await _pajakService.getInfoPajak(platNomor: platNomor);

      setState(() => _isCheckingAPI = false);

      if (pajakInfo.success) {
        print('✅ API SUCCESS!');
        print('   Message: ${pajakInfo.message}');
        
        if (mounted) {
          _showPajakResultDialog(platNomor, pajakInfo, isSuccess: true);
        }
      } else {
        print('❌ API FAILED: ${pajakInfo.message}');
        
        if (mounted) {
          _showPajakResultDialog(platNomor, pajakInfo, isSuccess: false);
        }
      }

    } catch (e) {
      print('❌ Exception during API call: $e');
      setState(() => _isCheckingAPI = false);
      
      if (mounted) {
        final errorInfo = PajakInfo.error('Exception: $e');
        _showPajakResultDialog(platNomor, errorInfo, isSuccess: false);
      }
    }
  }

  /// Resume detection setelah OCR selesai
  void _resumeDetection() {
    setState(() {
      _isDetectionActive = true;
      _isProcessing = false;
      _statusMessage = '🔍 Detection resumed - Arahkan kamera ke plat nomor...';
    });
    print('▶️ Detection RESUMED: active=$_isDetectionActive, processing=$_isProcessing');
  }

  /// Stop detection permanently
  void _stopDetection() {
    setState(() {
      _isDetectionActive = false;
      _isProcessing = false;
      _statusMessage = '⏹️ Detection stopped - Tekan tombol untuk mulai lagi';
    });
    print('⏹️ Detection STOPPED by user');
  }

  /// Start detection manually
  void _startDetection() {
    setState(() {
      _isDetectionActive = true;
      _isProcessing = false;
      _statusMessage = '🔍 Detection started - Arahkan kamera ke plat nomor...';
    });
    print('▶️ Detection STARTED by user');
  }

  /// Show OCR result dialog
  void _showOCRResultDialog(PlateData plateData) {
    final bool hasError = plateData.ocrText == null || plateData.ocrText!.isEmpty;
    final String displayText = plateData.ocrText ?? 'Error: Tidak ada teks terdeteksi';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasError ? Icons.error : Icons.check_circle, 
              color: hasError ? Colors.red.shade600 : Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(hasError ? 'OCR Error!' : 'OCR Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (plateData.croppedImage.hasImageData)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    plateData.croppedImage.imageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? Colors.red.shade300 : Colors.green.shade300, 
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    hasError ? 'Error OCR:' : 'Hasil OCR Plat Nomor:',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: hasError ? 14 : 24,
                      fontWeight: FontWeight.bold,
                      color: hasError ? Colors.red.shade900 : Colors.green.shade900,
                      letterSpacing: hasError ? 0 : 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            if (!hasError) ...[
              const SizedBox(height: 20),
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
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: hasError
            ? [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    print('🔄 User: OCR error - Coba lagi');
                    _resumeDetection();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: const Text('Coba Lagi', style: TextStyle(color: Colors.orange)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    print('⏹️ User: OCR error - Stop');
                    _stopDetection();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ]
            : [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    print('❌ User: OCR tidak benar - Detect lagi');
                    _resumeDetection();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: const Text('Tidak Benar\nDetect Lagi', style: TextStyle(color: Colors.orange), textAlign: TextAlign.center),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    print('✅ User: OCR sudah benar - Stop');
                    _stopDetection();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data tersimpan: ${plateData.ocrText}'),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Sudah Benar\nSimpan Data', textAlign: TextAlign.center),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
      ),
    );
  }

  /// Show dialog dengan info pajak
  void _showPajakResultDialog(String platNomor, PajakInfo pajakInfo, {required bool isSuccess}) {
    final data = pajakInfo.data;
    final String namaPemilik = data?.nmPemilik ?? '-';
    final String alamat = data?.alPemilik ?? '-';
    final String merkKB = data?.nmMerekKb ?? '-';
    final String modelKB = data?.nmModelKb ?? '-';
    final String tglAkhirPajak = data?.tgAkhirPajak ?? '-';
    
    final dataHitung = data?.dataHitungPajak;
    final int pajakPokok = dataHitung?.beaPkbPok0 ?? 0;
    final int swdkllj = dataHitung?.beaSwdklljPok0 ?? 0;
    final int totalPajak = pajakPokok + swdkllj;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSuccess ? 'Data Ditemukan!' : 'Data Tidak Ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.blue50, AppTheme.blue100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.blue600, width: 2),
                ),
                child: Center(
                  child: Text(
                    platNomor,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppTheme.blue900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? AppTheme.green50 : AppTheme.red50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSuccess ? AppTheme.green600 : AppTheme.red600,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.info_outline : Icons.warning_amber_outlined,
                      color: isSuccess ? AppTheme.green700 : AppTheme.red700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pajakInfo.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSuccess ? AppTheme.green900 : AppTheme.red900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isSuccess && data != null) ...[
                const Divider(height: 24, color: AppTheme.gray300),
                const Text(
                  '📋 Informasi Kendaraan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Pemilik', namaPemilik),
                _buildInfoRow('Alamat', alamat, maxLines: 2),
                const SizedBox(height: 8),
                _buildInfoRow('Merk', merkKB),
                _buildInfoRow('Model', modelKB),
                const SizedBox(height: 8),
                _buildInfoRow('Jatuh Tempo Pajak', tglAkhirPajak),

                const Divider(height: 24, color: AppTheme.gray300),
                const Text(
                  '💰 Informasi Pajak',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('PKB Pokok', 'Rp ${_formatCurrency(pajakPokok)}'),
                _buildInfoRow('SWDKLLJ', 'Rp ${_formatCurrency(swdkllj)}'),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.yellow50, AppTheme.yellow100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.yellow600, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900),
                      ),
                      Text(
                        'Rp ${_formatCurrency(totalPajak)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.yellow900),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _resumeDetection();
              print('▶️ Detection RESUMED by user');
            },
            icon: Icon(Icons.refresh, color: AppTheme.blue600),
            label: Text('🔄 Detect Ulang', style: TextStyle(color: AppTheme.blue600)),
          ),
          
          if (isSuccess)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Data berhasil disimpan!'),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _resumeDetection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.save),
              label: const Text('💾 Simpan Data'),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.gray600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 License Plate Detection & OCR'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats
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
              ],
            ),
          ),

          // API Loading
          if (_isCheckingAPI)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.yellow100,
                border: Border(bottom: BorderSide(color: AppTheme.yellow400, width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.yellow800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '🚀 Checking pajak info via API...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.yellow900),
                  ),
                ],
              ),
            ),

          // Camera
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
                  // showOverlays: true by default - native overlay tetap muncul real-time
                  
                  streamingConfig: YOLOStreamingConfig(
                    enableCropping: true,
                    croppingPadding: 0.1,
                    croppingQuality: 90,
                    inferenceFrequency: 15,
                    includeDetections: true,
                    includeOriginalImage: true,
                  ),
                  
                  // SOLUTION: Use onStreamingData instead of onResult
                  // This callback gets detection data WITHOUT triggering overlay render
                  onStreamingData: (Map<String, dynamic> data) {
                    // Skip if processing to prevent status update spam
                    if (_isProcessing) return;
                    
                    final now = DateTime.now();
                    final timeSinceLastUpdate = now.difference(_lastCallbackTime).inMilliseconds;
                    
                    // Debounce status updates
                    if (timeSinceLastUpdate < _callbackDebounceMs) return;
                    _lastCallbackTime = now;
                    
                    // Parse detection count from streaming data
                    final detections = data['detections'] as List?;
                    final detectionCount = detections?.length ?? 0;
                    
                    setState(() {
                      if (detectionCount > 0) {
                        _totalDetected += detectionCount;
                      }
                      
                      if (!_isDetectionActive) {
                        _statusMessage = '⏸️ Detection paused - Processing OCR...';
                      } else if (detectionCount == 0) {
                        _statusMessage = '🔍 Arahkan kamera ke plat nomor...';
                      } else {
                        _statusMessage = '✅ $detectionCount plat terdeteksi';
                      }
                    });
                  },
                  
                  onCroppedImages: (List<YOLOCroppedImage> images) async {
                    print('');
                    print('🔔 ========== onCroppedImages TRIGGERED ==========');
                    print('   Images count: ${images.length}');
                    print('   _isDetectionActive: $_isDetectionActive');
                    print('   _isProcessing: $_isProcessing');
                    print('   OCR Service Ready: ${_ocrService.isReady}');
                    
                    if (images.isEmpty) {
                      print('❌ No images');
                      print('================================================');
                      return;
                    }

                    // ✅ SKIP if inactive or processing (2 flags only!)
                    if (!_isDetectionActive || _isProcessing) {
                      print('⏸️ Skipping (paused or processing)');
                      print('================================================');
                      return;
                    }
                    
                    // 🔥 FIX: Debounce callback to prevent rapid setState() calls
                    final now = DateTime.now();
                    final timeSinceLastCallback = now.difference(_lastCallbackTime).inMilliseconds;
                    if (timeSinceLastCallback < _callbackDebounceMs) {
                      print('⏭️ Callback DEBOUNCED (only ${timeSinceLastCallback}ms since last)');
                      print('================================================');
                      return;
                    }
                    _lastCallbackTime = now;

                    final img = images.first;
                    print('🟢 Processing image: confidence=${(img.confidence*100).toStringAsFixed(1)}%');
                    
                    if (!_ocrService.isReady) {
                      print('❌ OCR not ready');
                      _resumeDetection();
                      return;
                    }

                    if (img.imageBytes == null || img.imageBytes!.isEmpty) {
                      print('❌ No image bytes');
                      _resumeDetection();
                      return;
                    }

                    print('⏸️ Detection PAUSED - Starting OCR...');

                    final plateData = PlateData(croppedImage: img);
                    
                    // 🔥 FIX: Combine setState() calls to prevent double overlay render
                    setState(() {
                      _isDetectionActive = false;
                      _totalCropped++;
                      _croppedPlates.add(plateData);
                      if (_croppedPlates.length > 12) {
                        _croppedPlates.removeAt(0);
                      }
                    });

                    print('🚗 Crop: ${img.width}x${img.height}px, confidence=${(img.confidence * 100).toStringAsFixed(1)}%');
                    
                    final currentIndex = _croppedPlates.length - 1;
                    await _processOCR(plateData, currentIndex);
                    
                    print('✅ OCR completed');
                    print('================================================');
                  },
                  
                  // ❌ onResult REMOVED - causes double overlay when combined with showOverlays: true
                  // ✅ Detection tracking now handled by onStreamingData above (data-only, no overlay trigger)
               
                ),
              ),
            ),
          ),

          // Gallery
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
                        IconButton(
                          icon: Icon(
                            _isDetectionActive ? Icons.pause_circle : Icons.play_circle,
                            color: _isDetectionActive ? Colors.orange : Colors.greenAccent,
                            size: 28,
                          ),
                          onPressed: _isProcessing ? null : () {
                            if (_isDetectionActive) {
                              _stopDetection();
                            } else {
                              _startDetection();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _croppedPlates.isEmpty
                        ? Center(
                            child: Text(
                              _isDetectionActive 
                                ? 'Belum ada plat nomor yang di-crop'
                                : 'Detection paused',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                              return _buildPlateCard(_croppedPlates[index], index);
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

  Widget _buildPlateCard(PlateData plateData, int index) {
    final plate = plateData.croppedImage;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade300, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (plate.hasImageData)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.all(4),
                child: Image.memory(plate.imageBytes!, fit: BoxFit.contain),
              ),
            ),

          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: plateData.ocrText != null
                    ? Colors.green.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
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
    );
  }
}
