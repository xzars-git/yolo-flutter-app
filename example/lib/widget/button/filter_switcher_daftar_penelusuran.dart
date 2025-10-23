// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class FilterButtonDaftarPenelusuran extends StatefulWidget {
  final String value;
  final Function()? onPressed;
  final bool status;

  const FilterButtonDaftarPenelusuran({
    super.key,
    required this.value,
    required this.onPressed,
    required this.status,
  });

  @override
  State<FilterButtonDaftarPenelusuran> createState() => _FilterButtonDaftarPenelusuranState();
}

class _FilterButtonDaftarPenelusuranState extends State<FilterButtonDaftarPenelusuran> {
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
        child: Text(widget.value, style: myTextTheme.bodyMedium),
      ),
    );
  }
}
