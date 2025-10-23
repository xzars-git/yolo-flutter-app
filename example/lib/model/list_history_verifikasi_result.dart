class ListHistoryVerifikasiResult {
  int? code;
  List<DataListHistoryVerifikasi>? data;
  String? message;

  ListHistoryVerifikasiResult({this.code, this.data, this.message});

  ListHistoryVerifikasiResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataListHistoryVerifikasi>[];
      json['data'].forEach((v) {
        data!.add(DataListHistoryVerifikasi.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class DataListHistoryVerifikasi {
  String? id;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? tglVerifikasi;
  String? verifikatorId;
  String? nmVerifikator;
  String? kdStatus;
  String? nmStatus;
  String? ketDitolak;

  DataListHistoryVerifikasi(
      {this.id,
      this.noPolisi1,
      this.noPolisi2,
      this.noPolisi3,
      this.tglVerifikasi,
      this.verifikatorId,
      this.nmVerifikator,
      this.kdStatus,
      this.nmStatus,
      this.ketDitolak});

  DataListHistoryVerifikasi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    noPolisi1 = json['no_polisi1'];
    noPolisi2 = json['no_polisi2'];
    noPolisi3 = json['no_polisi3'];
    tglVerifikasi = json['tgl_verifikasi'];
    verifikatorId = json['verifikator_id'];
    nmVerifikator = json['nm_verifikator'];
    kdStatus = json['kd_status'];
    nmStatus = json['nm_status'];
    ketDitolak = json['ket_ditolak'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['tgl_verifikasi'] = tglVerifikasi;
    data['verifikator_id'] = verifikatorId;
    data['nm_verifikator'] = nmVerifikator;
    data['kd_status'] = kdStatus;
    data['nm_status'] = nmStatus;
    data['ket_ditolak'] = ketDitolak;
    return data;
  }
}
