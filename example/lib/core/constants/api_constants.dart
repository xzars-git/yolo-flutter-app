/// API Configuration Constants
class ApiConstants {
  // Private constructor
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://devapibapenda.tangerangkota.go.id';

  // Endpoints
  static const String getInfoPajakEndpoint = '/services/v2/getInfoPajak';

  // Full URL helpers
  static String get getInfoPajakUrl => '$baseUrl$getInfoPajakEndpoint';

  // Request headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
}
