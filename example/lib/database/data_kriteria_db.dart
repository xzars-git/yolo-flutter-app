import 'package:ultralytics_yolo_example/model/kriteria_telusur_result.dart';
import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';

class DataKriteriaDatabase {
  static KriteriaTelusurResult? dataKriteria = KriteriaTelusurResult();

  static load() async {
    var data = mainStorage.get("dataKriteria");

    if (data != null && data is KriteriaTelusurResult) {
      dataKriteria = data;
    } else {
      dataKriteria = KriteriaTelusurResult();
    }
  }

  static save(KriteriaTelusurResult? dataKriteria) async {
    mainStorage.put("dataKriteria", dataKriteria);
    DataKriteriaDatabase.dataKriteria = dataKriteria ?? KriteriaTelusurResult();
  }
}
