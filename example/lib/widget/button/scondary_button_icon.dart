// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class SecondaryButtonIcon extends StatefulWidget {
  final Function()? onPressed;
  final String icon;
  final String text;

  const SecondaryButtonIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  @override
  State<SecondaryButtonIcon> createState() => _SecondaryButtonIconState();
}

class _SecondaryButtonIconState extends State<SecondaryButtonIcon> {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(widget.icon),
            const SizedBox(width: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(widget.text, style: myTextTheme.titleSmall?.copyWith(color: blue900)),
            ),
          ],
        ),
      ),
    );
  }
}
