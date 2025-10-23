import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo_example/service/api_service.dart';

Future<String> fileToBase64(
  String? filePath, {
  required String? noPolisi1,
  required String? noPolisi2,
  required String? noPolisi3,
  required String? compressFrom,
}) async {
  if (filePath != null && filePath.isNotEmpty) {
    try {
      List<int> originalFileBytes = await File(filePath).readAsBytes();
      String base64String = base64Encode(Uint8List.fromList(originalFileBytes));
      return base64String;
    } catch (e) {
      await ApiService.sendLog(
        logString: e.toString(),
        isAvailableNoPol: true,
        noPolisi1: noPolisi1,
        noPolisi2: noPolisi2,
        noPolisi3: noPolisi3,
        processName: "File to Base 64 Image - $compressFrom",
      ).timeout(const Duration(seconds: 30));
      return "";
    }
  } else {
    return "";
  }
}

Future<XFile?> convertBase64ToXFile(String? base64String) async {
  try {
    // Decode base64 string to bytes
    if (base64String == null) {
      return null;
    }
    Uint8List bytes = base64.decode(base64String);

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // Write bytes to a temporary file
    String tempFilePath = '$tempPath/temp_image.png';
    await File(tempFilePath).writeAsBytes(bytes);

    // Create XFile object from the temporary file
    XFile xFile = XFile(tempFilePath);

    return xFile;
  } catch (error) {
    return null;
  }
}

String? byteDataToBase64(ByteData? byteData) {
  if (byteData == null) {
    return null;
  }

  // Convert ByteData to Uint8List
  Uint8List uint8List = byteData.buffer.asUint8List();

  // Encode Uint8List to base64
  String base64String = base64Encode(uint8List);

  return base64String;
}

ByteData? base64ToByteData(String? base64String) {
  if (base64String == null) {
    return null;
  }

  // Decode base64 to Uint8List
  Uint8List uint8List = base64Decode(base64String);

  // Convert Uint8List to ByteData
  ByteData byteData = ByteData.sublistView(uint8List);

  return byteData;
}

Map<String, dynamic> jsonStringToJSON(String jsonString) {
  // Convert JSON string to Map
  Map<String, dynamic> jsonData = json.decode(jsonString);
  return jsonData;
}

String jsonToJSONString(Map<String, dynamic> jsonData) {
  // Convert Map to JSON string
  String jsonString = json.encode(jsonData);
  return jsonString;
}

Future<File> base64ToFile(String base64String, String filePath) async {
  final decodedBytes = base64Decode(base64String);
  File file = File(filePath);
  await file.writeAsBytes(decodedBytes);
  return file;
}

bool isBase64Valid(String base64String) {
  // Base64 Regex pattern for validation
  final RegExp base64Pattern = RegExp(
    r'^(?:[A-Za-z0-9+/]{4})*?(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$',
  );
  return base64Pattern.hasMatch(base64String);
}
