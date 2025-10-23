// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/controller/input_nomor_polisi_ocr_controller.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/reference.dart';
import 'package:ultralytics_yolo_example/util/show_snackbar/snackbar_nopol.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';
import 'package:ultralytics_yolo_example/widget/button/filter_button_plat.dart';
import 'package:ultralytics_yolo_example/widget/button/primary_button.dart';
import 'package:ultralytics_yolo_example/widget/card/container_nopol_telusur_mandiri.dart';

class ContentInputNopolOcr extends StatefulWidget {
  final InputNomorPolisiOcrController controller;
  const ContentInputNopolOcr({super.key, required this.controller});

  @override
  State<ContentInputNopolOcr> createState() => _ContentInputNopolOcrState();
}

class _ContentInputNopolOcrState extends State<ContentInputNopolOcr> {
  @override
  Widget build(BuildContext context) {
    InputNomorPolisiOcrController controller = widget.controller;
    return SingleChildScrollView(
      child: Column(
        children: [
          ContainerNomorPolisiTelusurMandiri(
            onInitState: () {
              controller.nopol1FocusNode.requestFocus();
            },
            isAutoFocus2: false,
            focusNode1: controller.nopol1FocusNode,
            onChangedTextfieldOne: (value) {
              controller.update();
              if (trimString(value).length == 1) {
                controller.nopol2FocusNode.requestFocus();
              }
              controller.noPolisi1 = trimString(value);
            },
            focusNode2: controller.nopol2FocusNode,
            onChangedTextfieldTwo: (value) {
              controller.update();
              if (trimString(value).length >= 4) {
                controller.nopol3FocusNode.requestFocus();
              }
              if (trimString(value).isEmpty) {
                controller.nopol1FocusNode.requestFocus();
              }
              controller.noPolisi2 = trimString(value);
            },
            focusNode3: controller.nopol3FocusNode,
            onChangedTextfieldThree: (value) {
              controller.update();
              if (trimString(value).isEmpty) {
                controller.nopol2FocusNode.requestFocus();
              }
              controller.noPolisi3 = trimString(value);
            },
            onEditingComplete: () {
              controller.getDataBesaranPajak();
              controller.update();
            },
            warnaPlat: controller.dataNopol.warnaPlat,
            warnaBorder: controller.dataNopol.warnaBorder,
            warnaFont: controller.dataNopol.warnaFont,
            warnaPlaceholder: controller.dataNopol.warnaPlaceholder,
          ),
          const SizedBox(height: 24.0),

          Row(
            children: [
              Expanded(
                child: FilterButtonPlat(
                  value: "Hitam/Putih",
                  onPressed: () {
                    controller.dataNopol = doUpdateNopol(kdPlat: "1");
                    controller.kodePlat = "1";
                    controller.update();
                  },
                  status: controller.dataNopol.statusHitam,
                  warnaFont: controller.dataNopol.statusHitam == true
                      ? controller.dataNopol.warnaFont
                      : neutralWhite,
                  warnaPlat: controller.dataNopol.statusHitam == true
                      ? controller.dataNopol.warnaPlat
                      : neutralWhite,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: FilterButtonPlat(
                  value: "Merah",
                  onPressed: () {
                    controller.dataNopol = doUpdateNopol(kdPlat: "2");
                    controller.kodePlat = "2";

                    controller.update();
                  },
                  status: controller.dataNopol.statusMerah,
                  warnaFont: controller.dataNopol.warnaFont,
                  warnaPlat: controller.dataNopol.warnaPlat,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: FilterButtonPlat(
                  value: "Kuning",
                  onPressed: () {
                    controller.dataNopol = doUpdateNopol(kdPlat: "3");
                    controller.kodePlat = "3";
                    controller.update();
                  },
                  status: controller.dataNopol.statusKuning,
                  warnaFont: controller.dataNopol.warnaFont,
                  warnaPlat: controller.dataNopol.warnaPlat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          PrimaryButton(
            isLoading: controller.isLoading,
            onPressed: () {
              if (controller.noPolisi1.isEmpty || controller.noPolisi2.isEmpty) {
                showCustomSnackBar(context, "Mohon isi nomor polisi");
              } else {
                controller.getDataBesaranPajak();
                controller.update();
              }
            },
            text: "Cari",
          ),
        ],
      ),
    );
  }
}
