import 'package:ultralytics_yolo_example/model/data_wilayah_result.dart';
import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';

class DataWilayahDatabase {
  static ResultDataWilayah? dataWilayah = ResultDataWilayah();

  static load() async {
    var data = mainStorage.get("dataWilayah");

    if (data != null && data is ResultDataWilayah) {
      dataWilayah = data;
    } else {
      dataWilayah = ResultDataWilayah();
    }
  }

  static save(ResultDataWilayah? dataWilayah) async {
    mainStorage.put("dataWilayah", dataWilayah);
    DataWilayahDatabase.dataWilayah = dataWilayah ?? ResultDataWilayah();
  }
}
