// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'dart:typed_data';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Service untuk melakukan OCR (Optical Character Recognition) pada gambar plat nomor
///
/// Menggunakan Google ML Kit Text Recognition untuk extract text dari cropped images
class OCRService {
  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  OCRService() {
    _initialize();
  }

  void _initialize() {
    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _isInitialized = true;
      debugPrint('✅ OCR Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize OCR Service: $e');
      _isInitialized = false;
    }
  }

  /// Check apakah OCR service sudah ready
  bool get isReady => _isInitialized;

  /// Extract text dari image bytes (JPEG/PNG)
  ///
  /// Returns cleaned license plate text atau null jika gagal
  Future<String?> extractLicensePlateText(Uint8List imageBytes) async {
    if (!_isInitialized) {
      debugPrint('⚠️ OCR Service not initialized');
      return null;
    }

    try {
      debugPrint('🔍 OCR: Processing image (${imageBytes.length} bytes)...');

      // 🎯 CRITICAL FIX: Untuk JPEG bytes, perlu save ke file temporary dulu
      // Karena InputImage.fromBytes() hanya untuk raw format (NV21/YUV)
      // Tapi JPEG dari cropping perlu di-decode dulu

      // Gunakan file path approach untuk JPEG
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      try {
        // Write JPEG bytes to temp file
        await tempFile.writeAsBytes(imageBytes);
        debugPrint('📝 OCR: Saved temp file: ${tempFile.path}');

        // Create InputImage from file path (ini cara yang benar untuk JPEG)
        final inputImage = InputImage.fromFilePath(tempFile.path);

        // Process image with text recognizer
        debugPrint('🤖 OCR: Processing with ML Kit...');
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

        // Clean up temp file
        await tempFile.delete();
        debugPrint('🗑️ OCR: Temp file deleted');

        if (recognizedText.text.isEmpty) {
          debugPrint('⚠️ No text detected in image');
          debugPrint('   Blocks found: ${recognizedText.blocks.length}');
          return null;
        }

        // Extract and clean the text
        String extractedText = recognizedText.text;
        debugPrint('📄 OCR Raw text: "$extractedText"');
        debugPrint('   Blocks: ${recognizedText.blocks.length}');
        debugPrint(
          '   Lines: ${recognizedText.blocks.map((b) => b.lines.length).reduce((a, b) => a + b)}',
        );

        // Clean up the text (remove extra spaces, newlines, etc)
        extractedText = _cleanLicensePlateText(extractedText);

        debugPrint('✅ OCR Success: "$extractedText"');
        return extractedText;
      } finally {
        // Pastikan temp file dihapus even jika error
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ OCR Error: $e');
      debugPrint('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// Extract text dengan confidence score untuk setiap block
  ///
  /// Returns list of detected text blocks dengan confidence level
  Future<List<OCRResult>> extractDetailedText(Uint8List imageBytes) async {
    if (!_isInitialized) {
      debugPrint('⚠️ OCR Service not initialized');
      return [];
    }

    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(100, 100),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: 100,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      List<OCRResult> results = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String cleanedText = _cleanLicensePlateText(line.text);
          if (cleanedText.isNotEmpty) {
            results.add(
              OCRResult(
                text: cleanedText,
                confidence: _estimateConfidence(line),
                boundingBox: line.boundingBox,
              ),
            );
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('❌ OCR Detailed Error: $e');
      return [];
    }
  }

  /// Clean up text khusus untuk license plate format
  ///
  /// Removes invalid characters, extra spaces, dan normalize format
  /// ✅ TAMBAHAN: Filter tahun yang ada di bawah plat nomor
  String _cleanLicensePlateText(String rawText) {
    // Remove extra whitespace and newlines
    String cleaned = rawText.replaceAll('\n', ' ').trim();

    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Convert to uppercase (standard untuk plat nomor)
    cleaned = cleaned.toUpperCase();

    // Remove common OCR errors (special characters yang tidak valid di plat nomor)
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), '');

    // ✅ FILTER TAHUN: Hapus angka 4 digit atau format tahun (09-27, 0927, dll)
    // Tahun biasanya muncul di bawah plat nomor dan terbaca oleh OCR
    // Pattern: 09-27, 09.27, 0927, 2024, dll
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*\d{2}[-.\s]?\d{2}\s*$'),
      '',
    ); // Format: 09-27 atau 0927
    cleaned = cleaned.replaceAll(RegExp(r'\s*\d{4}\s*$'), ''); // Format: 2024
    cleaned = cleaned.replaceAll(RegExp(r'\s*\d{2}/\d{2}\s*$'), ''); // Format: 09/27

    // Remove extra spaces yang mungkin tersisa
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  /// Estimate confidence level dari TextLine
  /// ML Kit tidak provide confidence directly, jadi kita estimate dari panjang text
  double _estimateConfidence(TextLine line) {
    // Simple heuristic: longer text with expected format = higher confidence
    final textLength = line.text.length;
    if (textLength >= 6) return 0.9; // Format lengkap plat nomor
    if (textLength >= 4) return 0.7;
    return 0.5;
  }

  /// Format text menjadi standard license plate format
  ///
  /// Contoh: "B1234ABC" → "B 1234 ABC"
  /// ✅ REGEX KETAT: Harus sesuai format Indonesia (Huruf-Angka-Huruf)
  String formatLicensePlate(String text) {
    if (text.isEmpty) return text;

    // Remove all spaces first
    String cleaned = text.replaceAll(' ', '');

    // ✅ REGEX INDONESIA KETAT:
    // - Wilayah: 1-2 HURUF (B, DK, AB, dll) - kode wilayah
    // - Nomor: 1-4 ANGKA (1, 123, 1234, dll) - nomor kendaraan
    // - Seri: 1-3 HURUF (T, T8R, ABC, dll) - seri plat
    // Format: [HURUF][ANGKA][HURUF] - WAJIB!
    final RegExp pattern = RegExp(r'^([A-Z]{1,2})(\d{1,4})([A-Z]{1,3})$');
    final match = pattern.firstMatch(cleaned);

    if (match != null) {
      String wilayah = match.group(1)!; // B, DK, AB
      String nomor = match.group(2)!; // 2156, 1234
      String seri = match.group(3)!; // T8R, ABC, A

      return '$wilayah $nomor $seri'; // B 2156 T8R
    }

    // Jika tidak match format Indonesia, return original
    // (kemungkinan invalid plate atau OCR error)
    return text;
  }

  /// Validate apakah text adalah valid Indonesian license plate format
  /// ✅ VALIDASI KETAT: HARUS Huruf-Angka-Huruf
  bool isValidIndonesianPlate(String text) {
    // Remove spaces untuk validasi
    String noSpaces = text.replaceAll(' ', '');

    // ✅ REGEX INDONESIA KETAT:
    // Format WAJIB: [HURUF 1-2][ANGKA 1-4][HURUF 1-3]
    // Contoh VALID:
    //   - B 2156 T8R ✅
    //   - DK 1234 AB ✅
    //   - AB 123 A ✅
    // Contoh INVALID:
    //   - 2156 (hanya angka) ❌
    //   - B 2156 (tidak ada seri huruf) ❌
    //   - 2156 T8R (tidak ada kode wilayah huruf) ❌
    final RegExp pattern = RegExp(r'^[A-Z]{1,2}\d{1,4}[A-Z]{1,3}$');

    bool isValid = pattern.hasMatch(noSpaces);

    if (!isValid) {
      debugPrint('⚠️ Invalid plate format: "$text" (must be: HURUF-ANGKA-HURUF)');
    }

    return isValid;
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _textRecognizer.close();
      debugPrint('🔚 OCR Service disposed');
    }
  }
}

/// Model untuk menyimpan hasil OCR
class OCRResult {
  final String text;
  final double confidence;
  final Rect boundingBox;

  OCRResult({required this.text, required this.confidence, required this.boundingBox});

  @override
  String toString() {
    return 'OCRResult(text: "$text", confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
