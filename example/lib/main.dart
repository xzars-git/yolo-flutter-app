// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/setup.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme.dart';
import 'app/app.dart';

void main() async {
  await initialize();

  Get.mainTheme.value = getDefaultTheme();

  runApp(const MyApp());
}
