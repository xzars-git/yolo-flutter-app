class DataPekerjaanResult {
  int? code;
  List<DataPekerjaan>? data;
  String? message;
  String? status;

  DataPekerjaanResult({this.code, this.data, this.message, this.status});

  DataPekerjaanResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataPekerjaan>[];
      json['data'].forEach((v) {
        data!.add(DataPekerjaan.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
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

class DataPekerjaan {
  String? kdKerja;
  String? nmPekerjaan;

  DataPekerjaan({this.kdKerja, this.nmPekerjaan});

  DataPekerjaan.fromJson(Map<String, dynamic> json) {
    kdKerja = json['kd_kerja'];
    nmPekerjaan = json['nm_pekerjaan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kd_kerja'] = kdKerja;
    data['nm_pekerjaan'] = nmPekerjaan;
    return data;
  }
}
