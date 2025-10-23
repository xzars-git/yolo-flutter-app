import 'package:ultralytics_yolo_example/model/login_result.dart';
import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';

class UserDatabase {
  static LoginResult? loginResult = LoginResult();

  static load() async {
    var data = mainStorage.get("loginResult");

    if (data != null && data is LoginResult) {
      loginResult = data;
    } else {
      loginResult = LoginResult();
    }
  }

  static save(LoginResult? loginResult) async {
    mainStorage.put("loginResult", loginResult);
    UserDatabase.loginResult = loginResult ?? LoginResult();
  }
}
