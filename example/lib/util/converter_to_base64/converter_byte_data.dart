import 'dart:typed_data';
import 'dart:io';
import 'package:ultralytics_yolo_example/service/api_service.dart';

import 'package:image_picker/image_picker.dart';

// Convert XFile to ByteData
Future<ByteData?> convertXFileToByteData({
  required XFile xfile,
  required String? noPolisi1,
  required String? noPolisi2,
  required String? noPolisi3,
  required String? compressFrom,
}) async {
  try {
    File file = File(xfile.path);
    Uint8List bytes = await file.readAsBytes();
    ByteData byteData = bytes.buffer.asByteData();
    return byteData;
  } catch (e) {
    await ApiService.sendLog(
      logString: e.toString(),
      isAvailableNoPol: true,
      noPolisi1: noPolisi1,
      noPolisi2: noPolisi2,
      noPolisi3: noPolisi3,
      processName: "Convert XFile To Byte Data - $compressFrom",
    ).timeout(const Duration(seconds: 30));
    return null;
  }
}
