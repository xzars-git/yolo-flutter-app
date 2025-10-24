import 'dart:typed_data';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


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

  bool get isReady => _isInitialized;


  Future<String?> extractLicensePlateText(Uint8List imageBytes) async {
    if (!_isInitialized) {
      debugPrint('⚠️ OCR Service not initialized');
      return null;
    }

    try {
      debugPrint('🔍 OCR: Processing image (${imageBytes.length} bytes)...');

      // ✅ STEP 1: Preprocess image untuk meningkatkan akurasi OCR
      Uint8List enhancedBytes = await _enhanceImageForOCR(imageBytes);
      debugPrint('✨ OCR: Image enhanced (${enhancedBytes.length} bytes)');

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      try {
        // Write enhanced JPEG bytes to temp file
        await tempFile.writeAsBytes(enhancedBytes);
        debugPrint('📝 OCR: Saved enhanced temp file: ${tempFile.path}');

        // Create InputImage from file path (ini cara yang benar untuk JPEG)
        final inputImage = InputImage.fromFilePath(tempFile.path);

        // Process image with text recognizer
        debugPrint('🤖 OCR: Processing with ML Kit...');
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

        // Clean up temp file
        await tempFile.delete();
        debugPrint('🗑️ OCR: Temp file deleted');

        debugPrint('📊 OCR Results:');
        debugPrint('   Blocks found: ${recognizedText.blocks.length}');
        debugPrint('   Full text: "${recognizedText.text}"');
        
        // Log detailed block information
        for (int i = 0; i < recognizedText.blocks.length; i++) {
          final block = recognizedText.blocks[i];
          debugPrint('   Block $i: "${block.text}" (${block.lines.length} lines)');
          for (int j = 0; j < block.lines.length; j++) {
            final line = block.lines[j];
            debugPrint('     Line $j: "${line.text}" (confidence: ${_estimateConfidence(line)})');
          }
        }

        if (recognizedText.text.isEmpty) {
          debugPrint('⚠️ No text detected in image');
          return null;
        }

        // Extract and clean the text
        String extractedText = recognizedText.text;
        debugPrint('📄 OCR Raw text: "$extractedText"');

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

  /// ✨ Enhance image untuk meningkatkan akurasi OCR
  Future<Uint8List> _enhanceImageForOCR(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('⚠️ Failed to decode image, using original');
        return imageBytes;
      }

      debugPrint('🖼️ Original image: ${image.width}x${image.height}');

      // ✅ STEP 1: Resize jika terlalu kecil (min 200px width for better OCR)
      if (image.width < 200) {
        final scaleFactor = 200 / image.width;
        image = img.copyResize(
          image,
          width: 200,
          height: (image.height * scaleFactor).round(),
          interpolation: img.Interpolation.cubic,
        );
        debugPrint('📐 Resized to: ${image.width}x${image.height}');
      }

      // ✅ STEP 2: Increase contrast untuk teks lebih jelas
      image = img.adjustColor(
        image,
        contrast: 1.3, // Increase contrast
        brightness: 1.1, // Slightly brighter
      );
      debugPrint('🎨 Enhanced contrast and brightness');

      // ✅ STEP 3: Sharpen untuk edge detection lebih baik
      image = img.convolution(
        image,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0], // Sharpen kernel
      );
      debugPrint('🔪 Sharpened image');

      // ✅ STEP 4: Convert to grayscale untuk OCR lebih fokus
      // (License plates biasanya hitam text on white/colored background)
      image = img.grayscale(image);
      debugPrint('⚫ Converted to grayscale');

      // Encode back to JPEG with high quality
      final enhancedBytes = img.encodeJpg(image, quality: 95);
      debugPrint('✅ Image enhancement complete');

      return Uint8List.fromList(enhancedBytes);
    } catch (e) {
      debugPrint('⚠️ Image enhancement failed: $e, using original');
      return imageBytes;
    }
  }

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

  double _estimateConfidence(TextLine line) {
    // Simple heuristic: longer text with expected format = higher confidence
    final textLength = line.text.length;
    if (textLength >= 6) return 0.9; // Format lengkap plat nomor
    if (textLength >= 4) return 0.7;
    return 0.5;
  }

  String formatLicensePlate(String text) {
    if (text.isEmpty) return text;

    // ✅ CERDAS: Parse berdasarkan POLA HURUF-ANGKA-HURUF
    // TIDAK ADA NORMALISASI - Biarkan hasil OCR asli
    String cleaned = text.replaceAll(' ', '').toUpperCase();

    debugPrint('🔍 Parsing: "$cleaned"');
    
    // ✅ STRATEGI 1: Ideal case - HURUF + ANGKA + HURUF
    final idealPattern = RegExp(r'^([A-Z]{1,2})([0-9]{1,4})([A-Z]{1,3})$');
    var idealMatch = idealPattern.firstMatch(cleaned);
    if (idealMatch != null) {
      String part1 = idealMatch.group(1)!;
      String part2 = idealMatch.group(2)!;
      String part3 = idealMatch.group(3)!;
      debugPrint('✅ Ideal match: "$part1 $part2 $part3"');
      return '$part1 $part2 $part3';
    }
    
    // ✅ STRATEGI 2: STRICT parsing with MAX constraints
    // Format: [1-2 chars] [1-4 chars] [1-3 chars]
    // Rule: nopol1 MAX 2, nopol2 MAX 4, nopol3 MAX 3
    if (cleaned.length >= 5) { // Minimal "E1T" = 3 chars
      
      // STEP 1: Ambil nopol1 (1-2 chars dari DEPAN)
      int part1Length = 1; // Default 1 char
      // Ambil 2 chars jika char kedua BUKAN digit (untuk DK, AB, dll)
      if (cleaned.length > 1) {
        final char2 = cleaned[1];
        // Ambil 2 hanya jika bukan digit DAN total string cukup panjang
        if (!RegExp(r'[0-9]').hasMatch(char2) && cleaned.length > 3) {
          part1Length = 2;
        }
      }
      
      // STEP 2: Ambil nopol3 (MAX 3 chars dari BELAKANG)
      // Cari berapa banyak huruf/angka di akhir, max 3
      int part3Length = 0;
      for (int i = cleaned.length - 1; i >= part1Length && part3Length < 3; i--) {
        part3Length++;
      }
      // Minimal harus ada 1 char untuk part3
      if (part3Length < 1) part3Length = 1;
      // Max 3 chars
      if (part3Length > 3) part3Length = 3;
      
      // STEP 3: Part2 adalah SISANYA (harus 1-4 chars)
      int part2Length = cleaned.length - part1Length - part3Length;
      
      // ✅ VALIDASI: part2 tidak boleh lebih dari 4!
      if (part2Length > 4) {
        // Kurangi part3Length, pindahkan ke part2
        int excess = part2Length - 4;
        part3Length += excess;
        part2Length = 4;
        
        // Double check: part3Length tidak boleh lebih dari 3
        if (part3Length > 3) {
          // Pindahkan kelebihan ke part2 (relax constraint)
          int part3Excess = part3Length - 3;
          part2Length += part3Excess;
          part3Length = 3;
        }
      }
      
      // Validasi final: semua part minimal 1 char
      if (part1Length >= 1 && part2Length >= 1 && part3Length >= 1) {
        int part1End = part1Length;
        int part2End = part1End + part2Length;
        
        String part1 = cleaned.substring(0, part1End);
        String part2 = cleaned.substring(part1End, part2End);
        String part3 = cleaned.substring(part2End);
        
        debugPrint('📋 STRICT split: "$part1 $part2 $part3" (lengths: ${part1.length}-${part2.length}-${part3.length})');
        return '$part1 $part2 $part3';
      }
    }

    // Jika gagal parse, return as-is
    debugPrint('⚠️ Could not parse: "$cleaned"');
    return text;
  }

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
