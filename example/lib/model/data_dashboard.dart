import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class DashboardResult {
  dynamic code;
  List<DataDashboard>? data;
  String? message;
  String? status;

  DashboardResult({this.code, this.data, this.message, this.status});

  DashboardResult.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? "";
    if (json['data'] != null) {
      data = <DataDashboard>[];
      json['data'].forEach((v) {
        data!.add(DataDashboard.fromJson(v));
      });
    }
    message = checkModel(json['message']);
    status = checkModel(json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class DataDashboard {
  String? tglRekap;
  String? kdWil;
  String? nmWil;
  String? jmlKtmdu;
  String? jmlKbmdu;
  String? jmlSudahCetak;
  String? jmlSudahDitugaskan;
  String? jmlSudahDitelusur;
  String? jmlSudahDiverifikasi;
  String? jmlSudahDibayar;
  String? jmlBelumDiverifikasi;
  String? jmlVerifDisetujui;
  String? jmlVerifDitolak;
  String? jmlKriteria1;
  String? jmlKriteria2;
  String? jmlKriteria3;
  String? jmlKriteria4;
  String? jmlKriteria5;
  String? jmlKriteria6;
  String? jmlKriteria7;
  String? jmlPembayaranPkbPok;
  String? jmlPembayaranPkbDen;
  String? jmlPembayaranOpsenPok;
  String? jmlPembayaranOpsenDen;
  String? totalBayar;

  DataDashboard({
    this.tglRekap,
    this.kdWil,
    this.nmWil,
    this.jmlKtmdu,
    this.jmlKbmdu,
    this.jmlSudahCetak,
    this.jmlSudahDitugaskan,
    this.jmlSudahDitelusur,
    this.jmlSudahDiverifikasi,
    this.jmlSudahDibayar,
    this.jmlBelumDiverifikasi,
    this.jmlVerifDisetujui,
    this.jmlVerifDitolak,
    this.jmlKriteria1,
    this.jmlKriteria2,
    this.jmlKriteria3,
    this.jmlKriteria4,
    this.jmlKriteria5,
    this.jmlKriteria6,
    this.jmlKriteria7,
    this.jmlPembayaranPkbPok,
    this.jmlPembayaranPkbDen,
    this.jmlPembayaranOpsenPok,
    this.jmlPembayaranOpsenDen,
    this.totalBayar,
  });

  DataDashboard.fromJson(Map<String, dynamic> json) {
    tglRekap = checkModel(json['tgl_rekap']);
    kdWil = checkModel(json['kd_wil']);
    nmWil = checkModel(json['nm_wil']);
    jmlKtmdu = checkModel(json['jml_ktmdu']);
    jmlKbmdu = checkModel(json['jml_kbmdu']);
    jmlSudahCetak = checkModel(json['jml_sudah_cetak']);
    jmlSudahDitugaskan = checkModel(json['jml_sudah_ditugaskan']);
    jmlSudahDitelusur = checkModel(json['jml_sudah_ditelusur']);
    jmlSudahDiverifikasi = checkModel(json['jml_sudah_diverifikasi']);
    jmlSudahDibayar = checkModel(json['jml_sudah_dibayar']);
    jmlBelumDiverifikasi = checkModel(json['jml_belum_diverifikasi']);
    jmlVerifDisetujui = checkModel(json['jml_verif_disetujui']);
    jmlVerifDitolak = checkModel(json['jml_verif_ditolak']);
    jmlKriteria1 = checkModel(json['jml_kriteria_1']);
    jmlKriteria2 = checkModel(json['jml_kriteria_2']);
    jmlKriteria3 = checkModel(json['jml_kriteria_3']);
    jmlKriteria4 = checkModel(json['jml_kriteria_4']);
    jmlKriteria5 = checkModel(json['jml_kriteria_5']);
    jmlKriteria6 = checkModel(json['jml_kriteria_6']);
    jmlKriteria7 = checkModel(json['jml_kriteria_7']);
    jmlPembayaranPkbPok = checkModel(json['jml_pembayaran_pkb_pokok']);
    jmlPembayaranPkbDen = checkModel(json['jml_pembayaran_pkb_denda']);
    jmlPembayaranOpsenPok = checkModel(json['jml_pembayaran_opsen_pokok']);
    jmlPembayaranOpsenDen = checkModel(json['jml_pembayaran_opsen_denda']);
    totalBayar = checkModel(json['total_bayar']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tgl_rekap'] = tglRekap;
    data['kd_wil'] = kdWil;
    data['nm_wil'] = nmWil;
    data['jml_ktmdu'] = jmlKtmdu;
    data['jml_kbmdu'] = jmlKbmdu;
    data['jml_sudah_cetak'] = jmlSudahCetak;
    data['jml_sudah_ditugaskan'] = jmlSudahDitugaskan;
    data['jml_sudah_ditelusur'] = jmlSudahDitelusur;
    data['jml_sudah_diverifikasi'] = jmlSudahDiverifikasi;
    data['jml_sudah_dibayar'] = jmlSudahDibayar;
    data['jml_belum_diverifikasi'] = jmlBelumDiverifikasi;
    data['jml_verif_disetujui'] = jmlVerifDisetujui;
    data['jml_verif_ditolak'] = jmlVerifDitolak;
    data['jml_kriteria_1'] = jmlKriteria1;
    data['jml_kriteria_2'] = jmlKriteria2;
    data['jml_kriteria_3'] = jmlKriteria3;
    data['jml_kriteria_4'] = jmlKriteria4;
    data['jml_kriteria_5'] = jmlKriteria5;
    data['jml_kriteria_6'] = jmlKriteria6;
    data['jml_kriteria_7'] = jmlKriteria7;
    data['jml_pembayaran_pkb_pokok'] = jmlPembayaranPkbPok;
    data['jml_pembayaran_pkb_denda'] = jmlPembayaranPkbDen;
    data['jml_pembayaran_opsen_pokok'] = jmlPembayaranOpsenPok;
    data['jml_pembayaran_opsen_denda'] = jmlPembayaranOpsenDen;
    data['total_bayar'] = totalBayar;
    return data;
  }
}
