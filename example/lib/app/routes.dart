import 'package:flutter/material.dart';
import '../presentation/screens/simple_ocr_test_screen.dart';

/// Centralized route configuration
class AppRoutes {
  // Private constructor
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String ocrTest = '/ocr-test';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case ocrTest:
        return MaterialPageRoute(
          builder: (_) => const SimpleOCRTestScreen(),
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
      home: (context) => const SimpleOCRTestScreen(),
      ocrTest: (context) => const SimpleOCRTestScreen(),
    };
  }
}
