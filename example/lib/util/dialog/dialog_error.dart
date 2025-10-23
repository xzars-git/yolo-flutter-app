import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/widget/button/primary_button.dart';

Future showDialogError(
  final String title,
  final String subtite,
  final VoidCallback callback,
) async {
  await showDialog<void>(
    context: globalContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Text(title, style: myTextTheme.headlineLarge?.copyWith(color: blue900)),
                const SizedBox(height: 16.0),
                Text(
                  subtite,
                  textAlign: TextAlign.center,
                  style: myTextTheme.bodyMedium?.copyWith(color: gray800),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: PrimaryButton(onPressed: callback, text: "Ya, saya mengerti"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
