import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo_example/features/bukti_penelusuran_ocr/view/bukti_penelusuran_ocr_view.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/service/api_service.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/util/check_connection/check_connection.dart';
import 'package:ultralytics_yolo_example/util/dialog/circle_dialog_loading.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';

class BuktiPenelusuranOcrController extends State<BuktiPenelusuranOcrView> {
  static late BuktiPenelusuranOcrController instance;
  late BuktiPenelusuranOcrView view;

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

  String pathPhoto = '';

  Future<void> openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      pathPhoto = pickedFile.path;
      update();
    }
  }

  Future<void> openGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pathPhoto = pickedFile.path;
      update();
    }
  }

  Future<bool> uploadTelusurMandiri() async {
    showCircleDialogLoading(context);
    try {
      await checkConnection();

      if (widget.dataKendaraan == null) {
        await showInfoDialog("Data kendaraan belum tersedia.");
        return false;
      }

      final result = await ApiService.uploadTelusurMandiri(
        kdPlat: widget.kodePlat ?? "",
        dataKendaraan: widget.dataKendaraan ?? DataKendaraan(),
        pathPhoto: pathPhoto,
      );

      // Show dialog for both 200 and 400 status codes
      if (result["success"] == true) {
        Get.back();
        update();
        await showInfoDialog("Data berhasil disimpan.");
        return true;
      } else {
        Get.back();
        await ApiService.sendLog(
          logString: result["message"] ?? "Gagal upload penelusuran mandiri",
          isAvailableNoPol: true,
          noPolisi1: widget.dataKendaraan?.noPolisi1?.toUpperCase(),
          noPolisi2: widget.dataKendaraan?.noPolisi2,
          noPolisi3: widget.dataKendaraan?.noPolisi3?.toUpperCase(),
          processName: "Upload Telusur Mandiri",
        ).timeout(const Duration(seconds: 30));
        String errorMsg = result["message"] ?? "Terjadi kesalahan saat upload penelusuran mandiri.";
        errorMsg = errorMsg
            .replaceAll(RegExp(r'DioException \[unknown\]: null'), '')
            .replaceAll(RegExp(r'Error: Exception:'), '')
            .trim();
        await showInfoDialog(errorMsg);
        return false;
      }
    } on DioException catch (e) {
      Get.back();
      // Hapus prefix error yang tidak perlu
      String errorMsg = e
          .toString()
          .replaceAll(RegExp(r'DioException \[unknown\]: null'), '')
          .replaceAll(RegExp(r'Error: Exception:'), '')
          .trim();
      await showInfoDialog("Terjadi kesalahan: $errorMsg");
      return false;
    } catch (e) {
      Get.back();
      String errorMsg = e
          .toString()
          .replaceAll(RegExp(r'DioException \[unknown\]: null'), '')
          .replaceAll(RegExp(r'Error: Exception:'), '')
          .trim();
      await showInfoDialog("Terjadi kesalahan: $errorMsg");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
