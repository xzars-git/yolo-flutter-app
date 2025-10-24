import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/nominal_pkb_model.dart';

String trimString(String? string) {
  if (string == null) {
    return "";
  } else if (string == "") {
    return "";
  } else if (string.contains("null")) {
    return "";
  } else {
    final trimmedString = string.trim();
    return trimmedString.isEmpty ? "" : trimmedString;
  }
}

trimStringStrip(String? string) {
  if (string == null) {
    return "-";
  } else if (string.contains("null")) {
    return "-";
  } else {
    final trimmedString = string.trim();
    return trimmedString.isEmpty ? "-" : trimmedString;
  }
}

checkNull(String? string) {
  if (string == null) {
    return "";
  } else if (string.contains("null")) {
    return "";
  } else {
    return string;
  }
}

 String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

String splitString(String? originalString, bool isFirstString) {
  if (originalString != null || originalString != "") {
    RegExp regExp = RegExp(r'^(.*?) - (.*?)$');
    Match? match = regExp.firstMatch(originalString!);

    if (match != null) {
      String firstPart = match.group(1)!.trim();
      String secondPart = match.group(2)!.trim();
      if (isFirstString) {
        return firstPart;
      } else {
        return secondPart;
      }
    } else {
      return "";
    }
  } else {
    return "";
  }
}

checkModel(dynamic data) {
  if (data == null || data.toString().contains("null")) return null;

  if (data.runtimeType == String || data.runtimeType == bool || data.runtimeType == double) {
    return data;
  }

  return data.toString();
}

int calcStringNumber(List<dynamic> items) {
  int result = 0;
  for (var item in items) {
    if (item == null || item is num || item is String) {
      result += int.tryParse(item.toString()) ?? 0;
    } else {
      result += 0;
    }
  }
  return result;
}

String calculatePercentage(dynamic current, dynamic total) {
  double currentValue = double.tryParse(current.toString()) ?? 0.0;
  double totalValue = double.tryParse(total.toString()) ?? 0.0;
  if (totalValue == 0) return "0%";
  double percent = (currentValue / totalValue) * 100;
  return "${percent.round()}%";
}

NominalPkbModel getNominalPkb(DataHitungPajak? data) {
  int pkbPokok = calcStringNumber([
    data?.beaPkbPok0,
    data?.beaPkbPok1,
    data?.beaPkbPok2,
    data?.beaPkbPok3,
    data?.beaPkbPok4,
    data?.beaPkbPok5,
  ]);

  int pkbDenda = calcStringNumber([
    data?.beaPkbDen0,
    data?.beaPkbDen1,
    data?.beaPkbDen2,
    data?.beaPkbDen3,
    data?.beaPkbDen4,
    data?.beaPkbDen5,
  ]);

  int pkbOpsPokok = calcStringNumber([
    data?.beaPkbOps0,
    data?.beaPkbOps1,
    data?.beaPkbOps2,
    data?.beaPkbOps3,
    data?.beaPkbOps4,
    data?.beaPkbOps5,
  ]);

  int pkbOpsDenda = calcStringNumber([
    data?.beaPkbOpsDen0,
    data?.beaPkbOpsDen1,
    data?.beaPkbOpsDen2,
    data?.beaPkbOpsDen3,
    data?.beaPkbOpsDen4,
    data?.beaPkbOpsDen5,
  ]);

  int swdklljPokok = calcStringNumber([
    data?.beaSwdklljPok0,
    data?.beaSwdklljPok1,
    data?.beaSwdklljPok2,
    data?.beaSwdklljPok3,
    data?.beaSwdklljPok4,
    data?.beaSwdklljPok5,
  ]);

  int swdklljDenda = calcStringNumber([
    data?.beaSwdklljDen0,
    data?.beaSwdklljDen1,
    data?.beaSwdklljDen2,
    data?.beaSwdklljDen3,
    data?.beaSwdklljDen4,
    data?.beaSwdklljDen5,
  ]);

  int total = calcStringNumber([
    pkbPokok,
    pkbOpsPokok,
    pkbDenda,
    pkbOpsDenda,
    swdklljPokok,
    swdklljDenda,
    data?.beaAdmStnk ?? "0",
    data?.beaAdmTnkb ?? "0",
  ]);

  return NominalPkbModel(
    pkbPokok: pkbPokok.toString(),
    opsenPkbPokok: pkbOpsPokok.toString(),
    pkbDenda: pkbDenda.toString(),
    opsenPkbDenda: pkbOpsDenda.toString(),
    swdklljPokok: swdklljPokok.toString(),
    swdklljDenda: swdklljDenda.toString(),
    pnbpStnk: trimString(data?.beaAdmStnk),
    pnbpTnkb: trimString(data?.beaAdmTnkb),
    total: total.toString(),
  );
}
