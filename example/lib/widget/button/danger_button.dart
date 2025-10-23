// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class DangerButton extends StatefulWidget {
  final Function()? onPressed;
  final String text;

  const DangerButton({super.key, required this.onPressed, required this.text});

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: red500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: myTextTheme.titleSmall?.copyWith(color: neutralWhite),
          ),
        ),
      ),
    );
  }
}
