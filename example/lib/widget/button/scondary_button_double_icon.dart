// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class SecondaryButtonDoubleIcon extends StatefulWidget {
  final Function() onPressed;
  final String iconLeft;
  final String iconRight;
  final String text;

  const SecondaryButtonDoubleIcon({
    super.key,
    required this.onPressed,
    required this.iconLeft,
    required this.iconRight,
    required this.text,
  });

  @override
  State<SecondaryButtonDoubleIcon> createState() => _SecondaryButtonIconSDoubletate();
}

class _SecondaryButtonIconSDoubletate extends State<SecondaryButtonDoubleIcon> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: blue900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: widget.onPressed,
      child: Row(
        children: [
          // ignore: deprecated_member_use
          SvgPicture.asset(widget.iconLeft, color: blue800),
          const SizedBox(width: 8.0),
          Text(widget.text, style: myTextTheme.labelSmall?.copyWith(color: blue800)),
          const SizedBox(width: 8.0),
          // ignore: deprecated_member_use
          SvgPicture.asset(widget.iconRight, color: blue800),
        ],
      ),
    );
  }
}
