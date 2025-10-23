import 'dart:convert';
import 'dart:typed_data';

// Function to convert String to ByteData
ByteData stringToByteData(String? input) {
  if (input == null) {
    return ByteData(0);
  }

  List<int> utf8Bytes = utf8.encode(input);
  Uint8List uint8List = Uint8List.fromList(utf8Bytes);
  return uint8List.buffer.asByteData();
}

String getStringFromBytes(ByteData data) {
  final buffer = data.buffer;
  var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return utf8.decode(list);
}

String byteDataToString(ByteData? byteData) {
  if (byteData == null) {
    return '';
  }

  Uint8List bytes = byteData.buffer.asUint8List();

  // Decode bytes using UTF-8
  String decodedString = utf8.decode(bytes);

  return decodedString;
}
