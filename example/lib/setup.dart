import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo_example/database/data_kriteria_db.dart';
import 'package:ultralytics_yolo_example/database/data_wilayah_db.dart';
import 'package:ultralytics_yolo_example/database/user_db.dart';
import 'package:ultralytics_yolo_example/model/data_konfirmasi_penelusuran.dart';
import 'package:ultralytics_yolo_example/model/data_wilayah_result.dart';
import 'package:ultralytics_yolo_example/model/kriteria_telusur_result.dart';
import 'package:ultralytics_yolo_example/model/login_result.dart';
import 'package:ultralytics_yolo_example/service/main_storage_service/main_storage.dart';
import 'package:ultralytics_yolo_example/service/bluetooth_printer_service.dart';
import 'package:ultralytics_yolo_example/session.dart';

Future initialize() async {
  // Ensure that the Flutter framework is fully initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Set the preferred orientations to portrait up and down.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage, only if the platform is not web.
  if (!kIsWeb) {
    var path = await getTemporaryDirectory();
    Hive.init(path.path);
  }

  // Register Hive adapters if they are not already registered.
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(LoginResultAdapter());
    Hive.registerAdapter(DataLoginAdapter());
    Hive.registerAdapter(DataUserAdapter());
    Hive.registerAdapter(DataKonfirmasiPenelusuranResultAdapter());
    Hive.registerAdapter(DataKonfirmasiPenelusuranAdapter());
    Hive.registerAdapter(ResultDataWilayahAdapter());
    Hive.registerAdapter(DataWilayahAdapter());
    Hive.registerAdapter(KriteriaTelusurResultAdapter());
    Hive.registerAdapter(DataKriteriaTelusurAdapter());
  }

  // Open the main storage box in Hive.
  mainStorage = await Hive.openBox('mainStorage');

  // Load data from various local databases.
  UserDatabase.load();
  DataWilayahDatabase.load();
  DataKriteriaDatabase.load();
  AppSession.load();

  // Initialize Bluetooth Printer Service
  await BluetoothPrinterService().initialize();
}
