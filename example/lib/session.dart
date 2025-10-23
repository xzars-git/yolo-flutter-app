import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';

//APPSESSION is used to store the token of the session for know is user is authenticated or not authenticated
class AppSession {
  static String token = "";

  static load() async {
    var data = mainStorage.get("token");
    if (data != null && data is String) {
      token = data;
    } else {
      token = "";
    }
  }

  static save(String token) async {
    mainStorage.put("token", token);
    AppSession.token = token;
  }
}
