// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class SecondaryButton extends StatefulWidget {
  final Function() onPressed;
  final String text;

  const SecondaryButton({super.key, required this.onPressed, required this.text});

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: blue900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(widget.text, style: myTextTheme.titleSmall?.copyWith(color: blue900)),
        ),
      ),
    );
  }
}
