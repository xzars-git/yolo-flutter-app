import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class FilterButtonPlat extends StatefulWidget {
  final String value;
  final Function()? onPressed;
  final bool status;
  final Color warnaPlat;
  final Color warnaFont;

  const FilterButtonPlat({
    super.key,
    required this.value,
    required this.onPressed,
    required this.status,
    required this.warnaPlat,
    required this.warnaFont,
  });

  @override
  State<FilterButtonPlat> createState() => _FilterButtonPlatState();
}

class _FilterButtonPlatState extends State<FilterButtonPlat> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: widget.status ? widget.warnaPlat : neutralWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: blueGray50),
        ),
      ),
      onPressed: widget.onPressed,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  widget.value,
                  style: myTextTheme.labelLarge?.copyWith(
                    color: widget.status ? widget.warnaFont : gray900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
