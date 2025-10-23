import 'package:hive/hive.dart';
part 'kriteria_telusur_result.g.dart';

@HiveType(typeId: 7)
class KriteriaTelusurResult {
  @HiveField(0)
  int? code;
  @HiveField(1)
  List<DataKriteriaTelusur>? data;
  @HiveField(2)
  String? message;
  @HiveField(3)
  String? status;

  KriteriaTelusurResult({this.code, this.data, this.message, this.status});

  KriteriaTelusurResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataKriteriaTelusur>[];
      json['data'].forEach((v) {
        data!.add(DataKriteriaTelusur.fromJson(v));
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

@HiveType(typeId: 8)
class DataKriteriaTelusur {
  @HiveField(0)
  String? kdTelusur;
  @HiveField(1)
  String? nmTelusur;

  DataKriteriaTelusur({this.kdTelusur, this.nmTelusur});

  DataKriteriaTelusur.fromJson(Map<String, dynamic> json) {
    kdTelusur = json['kd_telusur'];
    nmTelusur = json['nm_telusur'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kd_telusur'] = kdTelusur;
    data['nm_telusur'] = nmTelusur;
    return data;
  }
}
