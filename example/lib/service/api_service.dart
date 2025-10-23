import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ultralytics_yolo_example/config.dart';
import 'package:ultralytics_yolo_example/database/user_db.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/login_result.dart';
import 'package:ultralytics_yolo_example/session.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseUrl; // PROD
  // static const String _baseUrl = AppConfig.domain; // DEV
  static final String idUser = UserDatabase.loginResult?.data?.dataUser?.id ?? "";

  static final CancelToken cancelToken = CancelToken();

  static final Options options = Options(
    headers: {"Content-Type": "application/json", 'Authorization': 'Bearer ${AppSession.token}'},
  );

  static final Interceptor interceptor = InterceptorsWrapper(
    onError: (DioException error, ErrorInterceptorHandler handler) {
      throw Exception(error.response?.data["message"]);
    },
  );
  static Future<LoginResult> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    Dio dio = Dio();

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          throw Exception(error.response?.data["message"]);
        },
      ),
    );

    Map<String, dynamic> payload = {
      "username": username,
      "password": password,
      "device_id": deviceId,
    };

    // Tambahkan wilayah info
    payload.addAll(getWilayahPayload());

    var response = await dio.post(
      "${_baseUrl}atos-pamor/v1/auth/login",
      options: options,
      data: payload,
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      if (response.data["code"] == 200) {
        return LoginResult.fromJson(json.decode(response.toString()));
      } else {
        throw Exception(response.data["message"]);
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map> telusurUlang({required String idTelusur}) async {
    Dio dio = Dio();
    dio.interceptors.add(interceptor);

    final Map<String, dynamic> payload = {"id_telusur": idTelusur};

    final response = await dio.post(
      "${_baseUrl}atos-pamor/v1/penelusuran/telusur-ulang",
      options: options,
      data: payload,
      cancelToken: cancelToken,
    );

    final Map result = response.data;

    if (response.statusCode == 200) {
      if (response.data["code"] == 200) {
        return result;
      } else {
        throw Exception(response.data["message"]);
      }
    } else {
      throw Exception('Failed to telusurUlang');
    }
  }

  static Future<Map> sendLog({
    required String logString,
    required bool isAvailableNoPol,
    required String processName,
    String? noPolisi1,
    String? noPolisi2,
    String? noPolisi3,
  }) async {
    Dio dio = Dio();
    dio.interceptors.add(interceptor);

    String errorName = isAvailableNoPol
        ? "$processName : ${noPolisi1?.toUpperCase()}-$noPolisi2-${noPolisi3?.toUpperCase()} - $logString"
        : "$processName : $logString";

    Map<String, dynamic> payload = {
      "id_penelusur": idUser,
      "ket_error": errorName,
      ...getWilayahPayload(), // Reusable wilayah payload
    };

    var response = await dio.post(
      "${_baseUrl}atos-pamor/v1/send-log-error",
      options: options,
      data: payload,
      cancelToken: cancelToken,
    );

    Map result = response.data;

    if (response.statusCode == 200) {
      if (response.data["code"] == 200) {
        return result;
      } else {
        throw Exception(response.data["message"]);
      }
    } else {
      throw Exception('Failed to sendLog');
    }
  }

  static Future<DataBesaranPajakResult> getBesaranPajak({
    required String noPolisi1,
    required String noPolisi2,
    required String noPolisi3,
    required String kdPlat,
    required String bayarKeDepan,
  }) async {
    Dio dio = Dio();
    dio.interceptors.add(interceptor);

    Map<String, dynamic> payload = {
      "where": [
        ["objek_pajak_no_polisi1", "=", noPolisi1.toUpperCase()],
        ["objek_pajak_no_polisi2", "=", noPolisi2],
        ["objek_pajak_no_polisi3", "=", noPolisi3.toUpperCase()],
        ["objek_pajak_kd_plat", "=", kdPlat],
      ],
      "bayar_kedepan": bayarKeDepan,
    };

    // Tambahkan wilayah (sub_kd_wil dan kd_kabkota) jika valid
    payload.addAll(getWilayahPayload());

    final response = await dio.post(
      "${_baseUrl}atos-pamor/v1/get-info-pajak",
      options: options,
      data: payload,
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      if (response.data["code"] == "0000") {
        return DataBesaranPajakResult.fromJson(json.decode(response.toString()));
      } else {
        throw Exception(response.data["message"]);
      }
    } else {
      throw Exception('Failed to getInfoPajak');
    }
  }

  static Future<Map<String, dynamic>> uploadTelusurMandiri({
    required String kdPlat,
    required DataKendaraan dataKendaraan,
    required String pathPhoto,
  }) async {
    Dio dio = Dio();
    dio.interceptors.add(interceptor);

    // Konversi foto ke base64
    String fotoStikerKb = "";
    if (pathPhoto.isNotEmpty) {
      final bytes = await File(pathPhoto).readAsBytes();
      fotoStikerKb = base64Encode(bytes);
    }

    // Siapkan payload dari DataKendaraan
    final Map<String, dynamic> payload = {
      "id_penelusur": UserDatabase.loginResult?.data?.dataUser?.id ?? "",
      "no_identitas": dataKendaraan.noIdentitas ?? "",
      "no_mesin": dataKendaraan.noMesin ?? "",
      "no_polisi1": dataKendaraan.noPolisi1 ?? "",
      "no_polisi2": dataKendaraan.noPolisi2 ?? "",
      "no_polisi3": dataKendaraan.noPolisi3 ?? "",
      "no_rangka": dataKendaraan.noRangka ?? "",
      "tg_akhir_pajak": dataKendaraan.tgAkhirPajak ?? "",
      "tg_akhir_stnk": dataKendaraan.tgAkhirStnk ?? "",
      "tg_proses_tetap": dataKendaraan.tgProsesTetap ?? "",
      "th_buatan": dataKendaraan.thBuatan ?? "",
      "warna_kb": dataKendaraan.warnaKb ?? "",
      "al_pemilik": dataKendaraan.alPemilik ?? "",
      "nm_pemilik": dataKendaraan.nmPemilik ?? "",
      "bobot": dataKendaraan.bobot ?? "",
      "email": dataKendaraan.email, // isi jika ada
      "jenis_identitas": dataKendaraan.jenisIdentitas ?? "",
      "kd_blockir": dataKendaraan.kodeBlockir ?? "",
      "kd_fungsi_kb": dataKendaraan.kdFungsiKb ?? "",
      "kd_merek_kb": dataKendaraan.kdMerekKb ?? "",
      "kd_proteksi": dataKendaraan.kodeTerproteksi ?? "",
      "milik_ke": dataKendaraan.milikKe ?? "",
      "nilai_jual": dataKendaraan.nilaiJual ?? "",
      "nm_fungsi_kb": dataKendaraan.nmFungsiKb ?? "",
      "nm_jenis_kb": dataKendaraan.nmJenisKb ?? "",
      "nm_merek_kb": dataKendaraan.nmMerekKb ?? "",
      "nm_wil": dataKendaraan.nmWil ?? "",
      "no_wa": dataKendaraan.noWa, // isi jika ada
      "no_hp": dataKendaraan.noHp, // isi jika ada
      "foto_stiker_kb": fotoStikerKb,
      "kd_wil": UserDatabase.loginResult?.data?.dataUser?.kdWil ?? "",
      "kd_wil_kb": dataKendaraan.kdWil ?? "",
      "sub_kd_wil": UserDatabase.loginResult?.data?.dataUser?.subKdWil,
      "kd_plat": kdPlat,
      "nm_model_kb": dataKendaraan.nmModelKb ?? "",
      // Tambahkan field lain jika diperlukan
    };

    // Tambahkan wilayah payload jika perlu
    payload.addAll(getWilayahPayload());

    final response = await dio.post(
      "${_baseUrl}atos-pamor/v1/telusur-stiker/create",
      // "${_baseUrl}atos-pamor/v1/telusur-stiker/create",
      options: options,
      data: payload,
      cancelToken: cancelToken,
    );

    // Handle response sesuai format API
    if (response.statusCode == 200) {
      final data = response.data;
      if (data["code"] == 200 && data["status"] == "success") {
        return {"success": true, "message": data["message"] ?? "", "data": data["data"]};
      } else {
        return {"success": false, "message": data["message"] ?? ""};
      }
    } else {
      return {"success": false, "message": response.data["message"] ?? ""};
    }
  }

  static Map<String, String> getWilayahPayload() {
    // Ambil dan trim data dari user database
    final subKdWil = trimString(UserDatabase.loginResult?.data?.dataUser?.subKdWil);
    final kdKabKota = trimString(UserDatabase.loginResult?.data?.dataUser?.kdKabKota);

    // Siapkan map kosong
    final Map<String, String> result = {};

    // Jika sub wilayah ada, masukkan
    if (subKdWil.isNotEmpty) {
      result["sub_kd_wil"] = subKdWil;

      // Jika sub wilayah = "2" (provinsi level 2) dan kab/kota tersedia, masukkan juga
      if (subKdWil == "2" && kdKabKota.isNotEmpty) {
        result["kd_kabkota"] = kdKabKota;
      }
    }

    // Print hanya di debug mode
    // assert(() {
    //   print("Wilayah payload: $result");
    //   return true;
    // }());

    return result;
  }
}
