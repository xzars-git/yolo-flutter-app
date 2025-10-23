import 'package:geolocator/geolocator.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';
import 'package:ultralytics_yolo_example/util/get_range_location.dart';

Future<bool> handlePermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await geolocatorAndroid.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Get.back();
    await showInfoDialog("Layanan lokasi tidak diaktifkan.");
    Get.back();
    return false;
  }

  permission = await geolocatorAndroid.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await geolocatorAndroid.requestPermission();
    if (permission == LocationPermission.denied) {
      Get.back();
      await showInfoDialog("Izin lokasi ditolak.");
      Get.back();
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Get.back();
    await showInfoDialog("Izin lokasi ditolak buka pengaturan lokasi.");
    await geolocatorAndroid.openAppSettings();
    return false;
  }

  return true;
}
