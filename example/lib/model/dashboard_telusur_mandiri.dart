import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class DashboardTelusurMandiri {
  String? code;
  DataDashboardTelusurMandiri? data;
  String? message;
  String? status;

  DashboardTelusurMandiri({this.code, this.data, this.message, this.status});

  DashboardTelusurMandiri.fromJson(Map<String, dynamic> json) {
    code = checkModel(json['code']);
    data = json['data'] != null ? DataDashboardTelusurMandiri.fromJson(json['data']) : null;
    message = checkModel(json['message']);
    status = checkModel(json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class DataDashboardTelusurMandiri {
  String? totalTelusur;
  String? sudahBayar;
  String? belumBayar;
  String? besaranPajak;
  String? besaranPajakSudahBayar;
  String? besaranOps;
  String? besaranOpsSudahBayar;
  String? besaranDenda;
  String? besaranDendaSudahBayar;
  String? besaranDendaOps;
  String? besaranDendaOpsSudahBayar;
  String? totalPajak;
  String? totalPajakSudahBayar;
  String? totalDenda;
  String? totalDendaSudahBayar;
  String? total;
  String? totalBayar;

  DataDashboardTelusurMandiri({
    this.totalTelusur,
    this.sudahBayar,
    this.belumBayar,
    this.besaranPajak,
    this.besaranPajakSudahBayar,
    this.besaranOps,
    this.besaranOpsSudahBayar,
    this.besaranDenda,
    this.besaranDendaSudahBayar,
    this.besaranDendaOps,
    this.besaranDendaOpsSudahBayar,
    this.totalPajak,
    this.totalPajakSudahBayar,
    this.totalDenda,
    this.totalDendaSudahBayar,
    this.total,
    this.totalBayar,
  });

  DataDashboardTelusurMandiri.fromJson(Map<String, dynamic> json) {
    totalTelusur = checkModel(json['total_telusur']);
    sudahBayar = checkModel(json['sudah_bayar']);
    belumBayar = checkModel(json['belum_bayar']);
    besaranPajak = checkModel(json['besaran_pajak']);
    besaranPajakSudahBayar = checkModel(json['besaran_pajak_sudah_bayar']);
    besaranOps = checkModel(json['besaran_ops']);
    besaranOpsSudahBayar = checkModel(json['besaran_ops_sudah_bayar']);
    besaranDenda = checkModel(json['besaran_denda']);
    besaranDendaSudahBayar = checkModel(json['besaran_denda_sudah_bayar']);
    besaranDendaOps = checkModel(json['besaran_denda_ops']);
    besaranDendaOpsSudahBayar = checkModel(json['besaran_denda_ops_sudah_bayar']);
    totalPajak = checkModel(json['total_pajak']);
    totalPajakSudahBayar = checkModel(json['total_pajak_sudah_bayar']);
    totalDenda = checkModel(json['total_denda']);
    totalDendaSudahBayar = checkModel(json['total_denda_sudah_bayar']);
    total = checkModel(json['total']);
    totalBayar = checkModel(json['total_bayar']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_telusur'] = totalTelusur;
    data['sudah_bayar'] = sudahBayar;
    data['belum_bayar'] = belumBayar;
    data['besaran_pajak'] = besaranPajak;
    data['besaran_pajak_sudah_bayar'] = besaranPajakSudahBayar;
    data['besaran_ops'] = besaranOps;
    data['besaran_ops_sudah_bayar'] = besaranOpsSudahBayar;
    data['besaran_denda'] = besaranDenda;
    data['besaran_denda_sudah_bayar'] = besaranDendaSudahBayar;
    data['besaran_denda_ops'] = besaranDendaOps;
    data['besaran_denda_ops_sudah_bayar'] = besaranDendaOpsSudahBayar;
    data['total_pajak'] = totalPajak;
    data['total_pajak_sudah_bayar'] = totalPajakSudahBayar;
    data['total_denda'] = totalDenda;
    data['total_denda_sudah_bayar'] = totalDendaSudahBayar;
    data['total'] = total;
    data['total_bayar'] = totalBayar;
    return data;
  }
}
