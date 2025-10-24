class OCRResult {
  final String text;
  final bool isValid;
  final String? errorMessage;

  OCRResult({
    required this.text,
    required this.isValid,
    this.errorMessage,
  });

  factory OCRResult.success(String text) {
    return OCRResult(
      text: text,
      isValid: true,
    );
  }

  factory OCRResult.failure(String message) {
    return OCRResult(
      text: '',
      isValid: false,
      errorMessage: message,
    );
  }

  @override
  String toString() => 'OCRResult(text: $text, isValid: $isValid)';
}
