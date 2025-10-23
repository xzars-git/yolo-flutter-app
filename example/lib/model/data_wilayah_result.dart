import 'package:hive/hive.dart';
part 'data_wilayah_result.g.dart';

@HiveType(typeId: 5)
class ResultDataWilayah {
  @HiveField(0)
  int? code;
  @HiveField(1)
  List<DataWilayah>? data;
  @HiveField(2)
  String? message;
  @HiveField(3)
  String? status;

  ResultDataWilayah({this.code, this.data, this.message, this.status});

  ResultDataWilayah.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataWilayah>[];
      json['data'].forEach((v) {
        data!.add(DataWilayah.fromJson(v));
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

@HiveType(typeId: 6)
class DataWilayah {
  @HiveField(0)
  String? kdWil;
  @HiveField(1)
  String? nmWil;
  @HiveField(2)
  String? alUppd;
  @HiveField(3)
  String? kabKota;
  @HiveField(4)
  String? provinsi;
  @HiveField(5)
  String? telp;

  DataWilayah({this.kdWil, this.nmWil, this.alUppd, this.kabKota, this.provinsi, this.telp});

  DataWilayah.fromJson(Map<String, dynamic> json) {
    kdWil = json['kd_wil'];
    nmWil = json['nm_wil'];
    alUppd = json['al_uppd'];
    kabKota = json['kab_kota'];
    provinsi = json['provinsi'];
    telp = json['telp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kd_wil'] = kdWil;
    data['nm_wil'] = nmWil;
    data['al_uppd'] = alUppd;
    data['kab_kota'] = kabKota;
    data['provinsi'] = provinsi;
    data['telp'] = telp;
    return data;
  }
}
