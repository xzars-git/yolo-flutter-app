/// Validation utilities
class Validators {
  // Private constructor
  Validators._();

  /// Validate Indonesian license plate format
  /// Valid formats:
  /// - D 2969 VFB (Region Number Letters)
  /// - B 1234 ABC
  /// - DK 5678 XYZ
  static bool isValidPlateNumber(String? plate) {
    if (plate == null || plate.isEmpty) return false;
    
    // Remove spaces and convert to uppercase
    final clean = plate.replaceAll(' ', '').toUpperCase();
    
    // Pattern: 1-2 letters, 1-4 digits, 1-3 letters
    final regex = RegExp(r'^[A-Z]{1,2}\d{1,4}[A-Z]{1,3}$');
    return regex.hasMatch(clean);
  }

  /// Validate if text contains only numbers
  static bool isNumeric(String? text) {
    if (text == null || text.isEmpty) return false;
    return int.tryParse(text) != null;
  }

  /// Validate if text contains only letters
  static bool isAlpha(String? text) {
    if (text == null || text.isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(text);
  }

  /// Validate if text contains only alphanumeric characters
  static bool isAlphanumeric(String? text) {
    if (text == null || text.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
  }

  /// Check if string is not null or empty
  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String? text, int minLength) {
    return text != null && text.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String? text, int maxLength) {
    return text != null && text.length <= maxLength;
  }
}
