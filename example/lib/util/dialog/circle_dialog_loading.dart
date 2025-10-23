import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

Future showCircleDialogLoading() async {
  await showDialog<void>(
    context: globalContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0x00ffffff),
        shadowColor: const Color(0x00ffffff),
        content: SizedBox(
          height: 100,
          width: 100,
          child: CircleAvatar(
            backgroundColor: neutralWhite,
            child: LottieBuilder.asset("assets/files/json/loading.json"),
          ),
        ),
      );
    },
  );
}
