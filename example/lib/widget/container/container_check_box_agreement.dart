// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class ContainerCheckBoxAgreement extends StatefulWidget {
  final void Function() onTap;
  final bool value;
  const ContainerCheckBoxAgreement({super.key, required this.onTap, required this.value});

  @override
  State<ContainerCheckBoxAgreement> createState() => _ContainerCheckBoxAgreementState();
}

class _ContainerCheckBoxAgreementState extends State<ContainerCheckBoxAgreement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: blue50,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: widget.onTap,
          child: Row(
            children: [
              widget.value
                  ? SvgPicture.asset("assets/icons/input/kotak_checklist.svg")
                  : SvgPicture.asset("assets/icons/input/kotak.svg"),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  "Dengan ini, saya siap bertanggung jawab atas pernyataan di atas",
                  style: myTextTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
