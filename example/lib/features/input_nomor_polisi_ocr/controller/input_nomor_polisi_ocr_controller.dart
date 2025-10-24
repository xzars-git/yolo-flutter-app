import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:ultralytics_yolo_example/app/routes.dart';
import 'package:ultralytics_yolo_example/features/input_nomor_polisi_ocr/view/input_nomor_polisi_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/service/api_service.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/check_connection/check_connection.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';

class InputNomorPolisiOcrController extends State<InputNomorPolisiOcrView> {
  static late InputNomorPolisiOcrController instance;
  late InputNomorPolisiOcrView view;

  @override
  void initState() {
    super.initState();
    instance = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  void onReady() {}

  @override
  void dispose() {
    super.dispose();
  }

  bool isInputNopol = false;

  DataKendaraan? dataKendaraan;

  Color warnaPlat = gray900;
  Color warnaBorder = gray100;
  Color warnaFont = gray100;
  Color warnaPlaceholder = gray100;

  FocusNode nopol1FocusNode = FocusNode();
  FocusNode nopol2FocusNode = FocusNode();
  FocusNode nopol3FocusNode = FocusNode();

  String noPolisi1 = '';
  String noPolisi2 = '';
  String noPolisi3 = '';
  String kodePlat = '1';

  String kdBayarParkir = '';
  String idUser = '';
  String tgProsesTetap = '';
  String tgAkhirPajak = '';

  UpdateNopol dataNopol = const UpdateNopol();

  String pathPhoto = '';

  bool isLoading = false;

  getDataBesaranPajak() async {
    DataBesaranPajakResult? result;

    try {
      isLoading = true;
      update();
      await checkConnection();
      try {
        result = await ApiService.getBesaranPajak(
          noPolisi1: noPolisi1,
          noPolisi2: noPolisi2,
          noPolisi3: noPolisi3,
          kdPlat: kodePlat,
          bayarKeDepan: "T",
        ).timeout(const Duration(seconds: 90));
        dataKendaraan = result.data;
        pathPhoto = "";

        isLoading = false;
        update();

        DateTime now = await NTP.now();
        DateTime tgAkhirPajak = DateTime.parse(result.data?.tgAkhirPajak ?? "");

        if (tgAkhirPajak.isBefore(now)) {
          // Get.to(DetailTelusurMandiriOcrView(dataKendaraan: result.data));
          Navigator.pushNamed(
            // ignore: use_build_context_synchronously
            context,
            AppRoutes.detailNopol,
            arguments: {"dataKendaraan": result.data, "kodePlat": kodePlat},
          );
        } else {
          await showInfoDialog("Nomor polisi yang Anda masukkan Taat pajak.");
        }
      } catch (e) {
        isLoading = false;
        update();
        await ApiService.sendLog(
          logString: e.toString(),
          isAvailableNoPol: true,
          noPolisi1: noPolisi1.toUpperCase(),
          noPolisi2: noPolisi2,
          noPolisi3: noPolisi3.toUpperCase(),
          processName: "Get List History Verifikasi - Riwayat Verifikasi",
        ).timeout(const Duration(seconds: 30));
        if (e.toString().contains("TimeoutException")) {
          await showInfoDialog(
            "Mohon maaf, koneksi ke server gagal tersambung setelah 90 detik. Periksa kembali koneksi Anda.",
          );
        } else {
          await showInfoDialog("Terjadi Kesalahan, ${e.toString()}");
        }
      }
    } on DioException {
      isLoading = false;
      update();
      showInfoDialog(
        "Mohon maaf, koneksi ke server gagal tersambung setelah 90 detik. Periksa kembali koneksi Anda.",
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
