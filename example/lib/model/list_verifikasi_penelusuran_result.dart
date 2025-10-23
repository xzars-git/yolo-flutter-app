import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class ListVerifikasiPenelusuranResult {
  int? code;
  List<DataListVerifikasiPenelusuran>? data;
  String? limit;
  String? message;
  String? page;
  String? totalData;
  String? totalPage;

  ListVerifikasiPenelusuranResult({
    this.code,
    this.data,
    this.limit,
    this.message,
    this.page,
    this.totalData,
    this.totalPage,
  });

  ListVerifikasiPenelusuranResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataListVerifikasiPenelusuran>[];
      json['data'].forEach((v) {
        data!.add(DataListVerifikasiPenelusuran.fromJson(v));
      });
    } else {
      data = <DataListVerifikasiPenelusuran>[];
    }
    limit = checkModel(json['limit']);
    message = checkModel(json['message']);
    page = checkModel(json['page']);
    totalData = checkModel(json['total_data']);
    totalPage = checkModel(json['total_page']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['message'] = message;
    data['page'] = page;
    data['total_data'] = totalData;
    data['total_page'] = totalPage;
    return data;
  }
}

class DataListVerifikasiPenelusuran {
  String? id;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? tglTelusur;
  String? kdTelusur;
  String? nmTelusur;
  String? nmPenelusur;
  String? kdWil;
  String? nmWil;

  DataListVerifikasiPenelusuran({
    this.id,
    this.noPolisi1,
    this.noPolisi2,
    this.noPolisi3,
    this.tglTelusur,
    this.kdTelusur,
    this.nmTelusur,
    this.nmPenelusur,
    this.kdWil,
    this.nmWil,
  });

  DataListVerifikasiPenelusuran.fromJson(Map<String, dynamic> json) {
    id = checkModel(json['id']);
    noPolisi1 = checkModel(json['no_polisi1']);
    noPolisi2 = checkModel(json['no_polisi2']);
    noPolisi3 = checkModel(json['no_polisi3']);
    tglTelusur = checkModel(json['tgl_telusur']);
    kdTelusur = checkModel(json['kd_telusur']);
    nmTelusur = checkModel(json['nm_telusur']);
    nmPenelusur = checkModel(json['nm_penelusur']);
    kdWil = checkModel(json['kd_wil']);
    nmWil = checkModel(json['nm_wil']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['tgl_telusur'] = tglTelusur;
    data['kd_telusur'] = kdTelusur;
    data['nm_telusur'] = nmTelusur;
    data['nm_penelusur'] = nmPenelusur;
    data['kd_wil'] = kdWil;
    data['nm_wil'] = nmWil;
    return data;
  }
}
