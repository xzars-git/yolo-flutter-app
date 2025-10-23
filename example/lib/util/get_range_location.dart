import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:ultralytics_yolo_example/util/dialog/show_info_dialog.dart';

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

final GeolocatorPlatform geolocatorAndroid = GeolocatorPlatform.instance;

double calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Radius of Earth in kilometers

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  return haversine(lat1, lon1, lat2, lon2);
}

String formatDistance(double distance) {
  return '${distance.toStringAsFixed(2)} km';
}

Future<bool> _handlePermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await geolocatorAndroid.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await showInfoDialog("Layanan lokasi tidak diaktifkan.");
    return false;
  }

  permission = await geolocatorAndroid.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await geolocatorAndroid.requestPermission();
    if (permission == LocationPermission.denied) {
      await showInfoDialog("Izin lokasi ditolak.");
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    await showInfoDialog("Izin lokasi ditolak buka pengaturan lokasi.");
    await geolocatorAndroid.openAppSettings();
    return false;
  }

  return true;
}

Future<String> getRange(String targetLatitude, String targetLongitude) async {
  if (targetLatitude.isEmpty || targetLongitude.isEmpty) {
    return 'Jarak Tidak Tersedia';
  }

  final hasPermission = await _handlePermission();

  if (!hasPermission) {
    return 'Permission not granted or an error occurred';
  }

  Position position = await geolocatorAndroid.getCurrentPosition();

  // Calculate the range
  double range = calculateHaversine(
    double.parse(targetLatitude),
    double.parse(targetLongitude),
    position.latitude,
    position.longitude,
  );

  int rangeInMeters = (range * 1000).toInt();

  return '$rangeInMeters';
}
