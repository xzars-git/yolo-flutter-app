/// Application-wide constants
class AppConstants {
  // Private constructor
  AppConstants._();

  // App info
  static const String appName = 'OCR Plat Nomor';
  static const String appVersion = '1.0.0';

  // OCR Settings
  static const double ocrConfidenceThreshold = 0.5;
  static const int maxRetryAttempts = 3;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultRadius = 8.0;
  static const double cardRadius = 12.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
