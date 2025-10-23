import 'package:flutter/material.dart';
import '../features/ocr_plat_nomor/screens/license_plate_cropping_screen.dart';

/// Centralized route configuration
class AppRoutes {
  // Private constructor
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String ocrPlatNomor = '/ocr-plat-nomor';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case ocrPlatNomor:
        return MaterialPageRoute(
          builder: (_) => const LicensePlateCroppingScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// All routes map (untuk Navigator with named routes)
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const LicensePlateCroppingScreen(),
      ocrPlatNomor: (context) => const LicensePlateCroppingScreen(),
    };
  }
}
