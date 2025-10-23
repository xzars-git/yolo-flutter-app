import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/detail_telusur_mandiri_ocr/view/detail_telusur_mandiri_ocr_view.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/view/input_nomor_polisi_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import '../presentation/screens/simple_ocr_test_screen.dart';

/// Centralized route configuration
class AppRoutes {
  // Private constructor
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String ocrTest = '/ocr-test';
  static const String inputNopol = '/input-nopol';
  static const String detailNopol = '/detail-nopol';

  /// Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const InputNomorPolisiOcrView(),
          settings: settings,
        );
      case ocrTest:
        return MaterialPageRoute(builder: (_) => const SimpleOCRTestScreen(), settings: settings);
      case inputNopol:
        return MaterialPageRoute(
          builder: (_) => const InputNomorPolisiOcrView(),
          settings: settings,
        );
      case detailNopol:
        return MaterialPageRoute(
          builder: (_) => const DetailTelusurMandiriOcrView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  /// All routes map (untuk Navigator with named routes)
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const InputNomorPolisiOcrView(),
      ocrTest: (context) => const SimpleOCRTestScreen(),
      inputNopol: (context) => const InputNomorPolisiOcrView(),
      detailNopol: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as DataKendaraan?;
        return DetailTelusurMandiriOcrView(dataKendaraan: args);
      },
    };
  }
}
