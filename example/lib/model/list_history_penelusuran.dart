class ListHistoryPenelusuranResult {
  int? code;
  List<DataListHistoryPenelusuran>? data;
  int? limit;
  String? message;
  int? page;
  int? totalData;
  int? totalPage;

  ListHistoryPenelusuranResult(
      {this.code, this.data, this.limit, this.message, this.page, this.totalData, this.totalPage});

  ListHistoryPenelusuranResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataListHistoryPenelusuran>[];
      json['data'].forEach((v) {
        data!.add(DataListHistoryPenelusuran.fromJson(v));
      });
    }
    limit = json['limit'];
    message = json['message'];
    page = json['page'];
    totalData = json['total_data'];
    totalPage = json['total_page'];
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

class DataListHistoryPenelusuran {
  String? id;
  String? kdWil;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? tglTelusur;
  String? kdTelusur;
  String? nmTelusur;
  String? kdStatus;
  String? nmStatus;
  String? nmPenelusur;
  String? nmVerifikator;
  String? tglVerifikasi;

  DataListHistoryPenelusuran(
      {this.id,
      this.kdWil,
      this.noPolisi1,
      this.noPolisi2,
      this.noPolisi3,
      this.tglTelusur,
      this.kdTelusur,
      this.nmTelusur,
      this.kdStatus,
      this.nmStatus,
      this.nmPenelusur,
      this.nmVerifikator,
      this.tglVerifikasi});

  DataListHistoryPenelusuran.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kdWil = json['kd_wil'];
    noPolisi1 = json['no_polisi1'];
    noPolisi2 = json['no_polisi2'];
    noPolisi3 = json['no_polisi3'];
    tglTelusur = json['tgl_telusur'];
    kdTelusur = json['kd_telusur'];
    nmTelusur = json['nm_telusur'];
    kdStatus = json['kd_status'];
    nmStatus = json['nm_status'];
    nmPenelusur = json['nm_penelusur'];
    nmVerifikator = json['nm_verifikator'];
    tglVerifikasi = json['tgl_verifikasi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kd_wil'] = kdWil;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['tgl_telusur'] = tglTelusur;
    data['kd_telusur'] = kdTelusur;
    data['nm_telusur'] = nmTelusur;
    data['kd_status'] = kdStatus;
    data['nm_status'] = nmStatus;
    data['nm_penelusur'] = nmPenelusur;
    data['nm_verifikator'] = nmVerifikator;
    data['tgl_verifikasi'] = tglVerifikasi;
    return data;
  }
}
