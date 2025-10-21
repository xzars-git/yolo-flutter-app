// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'dart:typed_data';

/// Represents a cropped image from a detected object.
///
/// This class contains the cropped image data along with metadata about
/// the detection that produced it. Useful for secondary processing like
/// OCR, classification, or further analysis.
///
/// Example usage:
/// ```dart
/// YOLOView(
///   streamingConfig: YOLOStreamingConfig(enableCropping: true),
///   onCroppedImages: (List<YOLOCroppedImage> images) {
///     for (var image in images) {
///       // Send to OCR
///       final text = await performOCR(image.imageBytes);
///       print('Detected ${image.clsName}: $text');
///     }
///   },
/// );
/// ```
class YOLOCroppedImage {
  /// Unique cache key for retrieving the full image data
  final String cacheKey;

  /// Width of the cropped image in pixels
  final int width;

  /// Height of the cropped image in pixels
  final int height;

  /// Size of the image data in bytes
  final int sizeBytes;

  /// Confidence score of the detection (0.0 - 1.0)
  final double confidence;

  /// Class index of the detected object
  final int cls;

  /// Human-readable class name of the detected object
  final String clsName;

  /// Original bounding box coordinates in the source image
  final BoundingBox originalBox;

  /// Cached image bytes (populated after fetching from native)
  Uint8List? _imageBytes;

  /// Get the image bytes (JPEG format)
  ///
  /// Returns null if the image hasn't been fetched yet.
  /// Call `fetchImageData()` first to populate this field.
  Uint8List? get imageBytes => _imageBytes;

  /// Create a cropped image metadata object
  YOLOCroppedImage({
    required this.cacheKey,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.confidence,
    required this.cls,
    required this.clsName,
    required this.originalBox,
    Uint8List? imageBytes,
  }) : _imageBytes = imageBytes;

  /// Create from map received from platform channel
  factory YOLOCroppedImage.fromMap(Map<dynamic, dynamic> map) {
    final originalBoxMap = map['originalBox'] as Map<dynamic, dynamic>;
    
    return YOLOCroppedImage(
      cacheKey: map['cacheKey'] as String,
      width: map['width'] as int,
      height: map['height'] as int,
      sizeBytes: map['sizeBytes'] as int,
      confidence: (map['confidence'] as num).toDouble(),
      cls: map['cls'] as int,
      clsName: map['clsName'] as String,
      originalBox: BoundingBox(
        x1: (originalBoxMap['x1'] as num).toDouble(),
        y1: (originalBoxMap['y1'] as num).toDouble(),
        x2: (originalBoxMap['x2'] as num).toDouble(),
        y2: (originalBoxMap['y2'] as num).toDouble(),
      ),
    );
  }

  /// Set image bytes (used after fetching from native)
  void setImageBytes(Uint8List bytes) {
    _imageBytes = bytes;
  }

  /// Whether image data has been loaded
  bool get hasImageData => _imageBytes != null;

  @override
  String toString() {
    return 'YOLOCroppedImage('
        'cacheKey: $cacheKey, '
        'size: ${width}x$height, '
        'class: $clsName, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'dataLoaded: $hasImageData)';
  }
}

/// Represents a bounding box with pixel coordinates
class BoundingBox {
  /// Left edge x-coordinate
  final double x1;

  /// Top edge y-coordinate
  final double y1;

  /// Right edge x-coordinate
  final double x2;

  /// Bottom edge y-coordinate
  final double y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  /// Width of the bounding box
  double get width => x2 - x1;

  /// Height of the bounding box
  double get height => y2 - y1;

  /// Center x-coordinate
  double get centerX => (x1 + x2) / 2;

  /// Center y-coordinate
  double get centerY => (y1 + y2) / 2;

  @override
  String toString() {
    return 'BoundingBox(x1: $x1, y1: $y1, x2: $x2, y2: $y2)';
  }
}
