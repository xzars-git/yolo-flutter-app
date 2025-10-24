import 'package:flutter/material.dart';
import '../../input_nomor_polisi_ocr/models/ocr_result.dart';
import '../../../service/ocr_service.dart' hide OCRResult; // Hide internal OCRResult class
import '../services/pajak_service.dart';

/// Controller untuk OCR Screen
/// Menangani business logic dan state management
class OCRController extends ChangeNotifier {
  // Services
  // ignore: unused_field
  final OCRService _ocrService = OCRService();
  final PajakService _pajakService = PajakService();

  // State variables
  int _totalCropped = 0;
  int _totalOCRSuccess = 0;
  int _totalOCRFailed = 0;
  bool _isDetectionActive = true;
  bool _isProcessing = false;
  bool _isCheckingAPI = false;
  String? _lastProcessedPlate;

  // Getters
  int get totalCropped => _totalCropped;
  int get totalOCRSuccess => _totalOCRSuccess;
  int get totalOCRFailed => _totalOCRFailed;
  bool get isDetectionActive => _isDetectionActive;
  bool get isProcessing => _isProcessing;
  bool get isCheckingAPI => _isCheckingAPI;
  String? get lastProcessedPlate => _lastProcessedPlate;

  /// Initialize controller
  void initialize() {
    _resetStats();
  }

  /// Reset statistics
  void _resetStats() {
    _totalCropped = 0;
    _totalOCRSuccess = 0;
    _totalOCRFailed = 0;
    _isDetectionActive = true;
    _isProcessing = false;
    _isCheckingAPI = false;
    _lastProcessedPlate = null;
    notifyListeners();
  }

  /// Process cropped images dengan OCR
  ///
  /// ⚠️ NOTE: Method ini belum diimplementasi karena masih menggunakan
  /// SimpleOCRTestScreen yang lama. Untuk full MVC implementation,
  /// perlu refactor processImageFile dari cropped image paths.
  Future<OCRResult?> processCroppedImages(List<String> croppedPaths) async {
    // Skip jika detection tidak aktif atau sedang processing
    if (!_isDetectionActive || _isProcessing) {
      return null;
    }

    _totalCropped += croppedPaths.length;
    notifyListeners();

    // TODO: Implement image processing
    // OCRService menggunakan Uint8List, bukan file path
    // Perlu convert file path -> Uint8List dulu

    debugPrint('⚠️ processCroppedImages not yet fully implemented');
    return null;

    /* ORIGINAL IMPLEMENTATION - Needs refactor
    for (final imagePath in croppedPaths) {
      try {
        // Need to read file as bytes first
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        final extractedText = await _ocrService.extractLicensePlateText(bytes);

        if (extractedText != null && extractedText.isNotEmpty) {
          _totalOCRSuccess++;
          _lastProcessedPlate = extractedText;
          _isProcessing = true;
          _isDetectionActive = false;
          notifyListeners();

          debugPrint('✅ OCR SUCCESS: $extractedText');
          return OCRResult.success(extractedText);
        }

        _totalOCRFailed++;
        notifyListeners();
      } catch (e) {
        debugPrint('❌ OCR Error: $e');
        _totalOCRFailed++;
        notifyListeners();
      }
    }

    return null;
    */
  }

  /// Check pajak info via API
  Future<PajakInfo> checkPajakInfo(String platNomor) async {
    _isCheckingAPI = true;
    notifyListeners();

    try {
      final pajakInfo = await _pajakService.getInfoPajak(platNomor: platNomor);

      _isCheckingAPI = false;
      notifyListeners();

      if (pajakInfo.success) {
        debugPrint('✅ API SUCCESS: ${pajakInfo.message}');
      } else {
        debugPrint('❌ API FAILED: ${pajakInfo.message}');
      }

      return pajakInfo;
    } catch (e) {
      debugPrint('❌ API Exception: $e');
      _isCheckingAPI = false;
      notifyListeners();
      return PajakInfo.error('Exception: $e');
    }
  }

  /// Resume detection setelah user konfirmasi
  void resumeDetection() {
    _isDetectionActive = true;
    _isProcessing = false;
    _lastProcessedPlate = null;
    notifyListeners();
    debugPrint('🔄 Detection resumed');
  }

  /// Reset dan mulai dari awal
  void resetAndRestart() {
    _resetStats();
    debugPrint('🔄 Reset and restart');
  }

  @override
  void dispose() {
    // Cleanup jika diperlukan
    super.dispose();
  }
}
