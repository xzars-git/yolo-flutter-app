// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class ContainerProses extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;

  const ContainerProses({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<ContainerProses> createState() => _ContainerProsesState();
}

class _ContainerProsesState extends State<ContainerProses> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(widget.icon),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: myTextTheme.titleMedium),
              Text(widget.subtitle, style: myTextTheme.bodyMedium?.copyWith(color: gray700)),
            ],
          ),
        ),
      ],
    );
  }
}
