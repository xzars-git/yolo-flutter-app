import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';

class DeviceDatabase {
  static String? id = "";

  static load() async {
    var data = mainStorage.get("idDevice");

    if (data != null && data is String) {
      id = data;
    } else {
      id = "";
    }
  }

  static save(String? id) async {
    mainStorage.put("idDevice", id);
    DeviceDatabase.id = id ?? "";
  }
}
