import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/bukti_penelusuran_ocr/controller/bukti_penelusuran_ocr_controller.dart';
import 'package:ultralytics_yolo_example/features/bukti_penelusuran_ocr/widget/dashed_container.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/view/input_nomor_polisi_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/util/reference.dart';
import 'package:ultralytics_yolo_example/util/show_snackbar/snackbar_nopol.dart';
import 'package:ultralytics_yolo_example/widget/button/primary_button.dart';

class BuktiPenelusuranOcrView extends StatefulWidget {
  final DataKendaraan? dataKendaraan;
  final String? kodePlat;
  const BuktiPenelusuranOcrView({super.key, this.dataKendaraan, this.kodePlat});

  Widget build(context, BuktiPenelusuranOcrController controller) {
    controller.view = this;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Bukti Penelusuran"), actions: const []),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (dataKendaraan != null &&
                  checkTglAkhirPajak(
                        DateTime.parse(dataKendaraan!.tgAkhirPajak ?? DateTime.now().toString()),
                      ) ==
                      true)
                DashedContainerTelusurMandiri(controller: controller),

              if (checkTglAkhirPajak(
                        DateTime.parse(dataKendaraan!.tgAkhirPajak ?? DateTime.now().toString()),
                      ) ==
                      true &&
                  controller.pathPhoto != "") ...[
                const SizedBox(height: 16.0),
                PrimaryButton(
                  onPressed: () async {
                    bool isSucces = await controller.uploadTelusurMandiri();
                    if (isSucces) {
                      controller.pathPhoto = "";
                      controller.update();
                      Get.offAll(const InputNomorPolisiOcrView());
                    } else {
                      showCustomSnackBar(context, "Gagal mengupload foto");
                    }
                  },
                  text: "Simpan",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  State<BuktiPenelusuranOcrView> createState() => BuktiPenelusuranOcrController();
}
