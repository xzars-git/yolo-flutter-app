import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

PermissionStatus? statusCamera;
PermissionStatus? statusStorage;
PermissionStatus? statusLocation;
Future<void> requestPermissions() async {
  final plugin = DeviceInfoPlugin();
  final android = await plugin.androidInfo;
  if (statusCamera != PermissionStatus.granted) {
    statusCamera = await Permission.camera.request();
  }
  if (statusStorage != PermissionStatus.granted) {
    statusStorage = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;
  }
  if (statusLocation != PermissionStatus.granted) {
    statusLocation = await Permission.location.request();
  }
}
