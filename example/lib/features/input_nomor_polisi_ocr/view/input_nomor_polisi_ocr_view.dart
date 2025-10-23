import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/controller/input_nomor_polisi_ocr_controller.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/widget/content_input_nopol_ocr.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/widget/button/secondary_button.dart';

class InputNomorPolisiOcrView extends StatefulWidget {
  const InputNomorPolisiOcrView({super.key});

  Widget build(context, InputNomorPolisiOcrController controller) {
    controller.view = this;
    return Scaffold(
      appBar: AppBar(title: const Text("Telusur Mandiri"), actions: const []),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (controller.isInputNopol)
                    Expanded(child: ContentInputNopolOcr(controller: controller)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: neutralWhite,
              child: controller.isInputNopol
                  ? SecondaryButton(
                      onPressed: () {
                        controller.isInputNopol = false;
                        controller.dataNopol = const UpdateNopol();
                        controller.pathPhoto = "";
                        controller.noPolisi1 = "";
                        controller.noPolisi2 = "";
                        controller.noPolisi3 = "";
                        controller.kodePlat = "1";
                        controller.update();
                      },
                      text: "Beralih ke Pemindaian",
                    )
                  : SecondaryButton(
                      onPressed: () {
                        controller.isInputNopol = true;
                        controller.dataNopol = const UpdateNopol();
                        controller.pathPhoto = "";
                        controller.noPolisi1 = "";
                        controller.noPolisi2 = "";
                        controller.noPolisi3 = "";
                        controller.kodePlat = "1";
                        controller.update();
                      },
                      text: "Input Nomor Polisi",
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<InputNomorPolisiOcrView> createState() => InputNomorPolisiOcrController();
}
