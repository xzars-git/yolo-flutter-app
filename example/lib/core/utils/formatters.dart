/// Utility functions for text formatting
class Formatters {
  // Private constructor
  Formatters._();

  /// Format currency (Indonesian Rupiah)
  /// Example: 1000000 -> "Rp 1.000.000"
  static String formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    
    final number = value is String ? int.tryParse(value) ?? 0 : value;
    final str = number.toString();
    final buffer = StringBuffer('Rp ');
    
    int counter = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      counter++;
    }
    
    return buffer.toString().split('').reversed.join();
  }

  /// Format date to Indonesian format
  /// Example: 2024-01-15 -> "15 Januari 2024"
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  /// Format date to short format
  /// Example: 2024-01-15 -> "15/01/2024"
  static String formatDateShort(DateTime? date) {
    if (date == null) return '-';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return '$day/$month/$year';
  }

  /// Capitalize first letter of each word
  /// Example: "gungun gunawan" -> "Gungun Gunawan"
  static String capitalizeWords(String? text) {
    if (text == null || text.isEmpty) return '';
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Format license plate number
  /// Example: "D2969VFB" -> "D 2969 VFB"
  static String formatPlateNumber(String? plate) {
    if (plate == null || plate.isEmpty) return '';
    
    // Remove spaces and convert to uppercase
    final clean = plate.replaceAll(' ', '').toUpperCase();
    
    // Try to match pattern: Letter(s) Number(s) Letter(s)
    final regex = RegExp(r'^([A-Z]+)(\d+)([A-Z]+)$');
    final match = regex.firstMatch(clean);
    
    if (match != null) {
      return '${match.group(1)} ${match.group(2)} ${match.group(3)}';
    }
    
    return plate;
  }
}
