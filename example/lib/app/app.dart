import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'theme.dart';
import 'routes.dart';

/// Main application widget with theme and routing configuration
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Get.mainTheme,
      builder: (context, value, child) {
        return MaterialApp(
          title: 'OCR Plat Nomor',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          // darkTheme: AppTheme.darkTheme, // Uncomment untuk dark mode support

          // Routing
          initialRoute: AppRoutes.home,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
