import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo_example/model/update_nopol_model.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
//END OF PROD PURPOSE

Future<int?> getXFileSize(XFile? xFile) async {
  if (xFile != null) {
    File file = File(xFile.path);
    int fileSize = await file.length();
    return fileSize;
  }
  return null;
}

String versionApp = "3.2.0";

UpdateNopol doUpdateNopol({required String kdPlat}) {
  switch (kdPlat) {
    case "1":
      return const UpdateNopol(
        statusHitam: true,
        statusPutih: false,
        statusMerah: false,
        statusKuning: false,
        warnaPlat: gray900,
        warnaBorder: gray100,
        warnaFont: gray100,
        warnaPlaceholder: gray100,
        kodePlat: "1",
      );
    case "2":
      return const UpdateNopol(
        statusMerah: true,
        statusHitam: false,
        statusPutih: false,
        statusKuning: false,
        warnaPlat: red400,
        warnaBorder: neutralWhite,
        warnaFont: neutralWhite,
        warnaPlaceholder: red200,
        kodePlat: "2",
      );
    case "3":
      return const UpdateNopol(
        statusKuning: true,
        statusHitam: false,
        statusPutih: false,
        statusMerah: false,
        warnaPlat: yellow600,
        warnaBorder: neutralBlack,
        warnaFont: neutralBlack,
        warnaPlaceholder: yellow200,
        kodePlat: "3",
      );

    default:
      return const UpdateNopol(
        statusHitam: true,
        statusPutih: false,
        statusMerah: false,
        statusKuning: false,
        warnaPlat: gray900,
        warnaBorder: gray100,
        warnaFont: gray100,
        warnaPlaceholder: gray100,
        kodePlat: "1",
      );
  }
}

bool checkTglAkhirPajak(DateTime? tgAkhirPajak) {
  // Check if the input parameter is null
  if (tgAkhirPajak == null) {
    return false;
  }

  // Get today's date
  DateTime today = DateTime.now();
  // Compare the dates
  return today.isAfter(tgAkhirPajak);
}
