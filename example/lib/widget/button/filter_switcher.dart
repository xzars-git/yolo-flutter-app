// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class FilterButton extends StatefulWidget {
  final String value;
  final Function()? onPressed;
  final bool status;

  const FilterButton({
    super.key,
    required this.value,
    required this.onPressed,
    required this.status,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.status ? blue800 : gray800,
        side: BorderSide(width: 1.0, color: widget.status ? blue800 : gray300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
      ),
      onPressed: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.value, style: myTextTheme.bodyMedium),
            const SizedBox(width: 6.0),
            widget.status
                ? SvgPicture.asset("assets/icons/input/checkList.svg")
                // ignore: deprecated_member_use
                : SvgPicture.asset("assets/icons/input/check.svg", color: const Color(0xffF3F5F8)),
          ],
        ),
      ),
    );
  }
}
