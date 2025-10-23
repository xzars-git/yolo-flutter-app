import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

formatDateDayMonthYear(String? date) {
  if (date == null || date.isEmpty) {
    return "-";
  } else if (date.contains("null")) {
    return "-";
  }
  initializeDateFormatting('id');

  DateTime dateConverted = DateTime.parse(date);
  return "${dateConverted.day.toString().padLeft(2, '0')}-${dateConverted.month.toString().padLeft(2, '0')}-${dateConverted.year.toString().padLeft(2, '0')}";
}

String formatDate(String? date) {
  if (date == null || date.isEmpty || date.contains("null")) {
    return "-";
  }

  initializeDateFormatting('id');

  if (RegExp(r'^\d{4}$').hasMatch(date)) {
    DateTime yearOnlyDate = DateTime(int.parse(date), 1, 1);
    return yearOnlyDate.year.toString().padLeft(2, '0');
  }

  DateTime dateConverted = DateTime.parse(date);
  return "${dateConverted.day.toString().padLeft(2, '0')}/${dateConverted.month.toString().padLeft(2, '0')}/${dateConverted.year.toString().padLeft(2, '0')}";
}

formatSelectedDate(DateTime selectedDate) {
  String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
  return selectedDateString;
}

formatDateFull(String? date) {
  if (date.toString().isEmpty) {
    return "-";
  } else if (date.toString().contains("null")) {
    return "-";
  }
  initializeDateFormatting('id');

  DateTime dateConverted = DateTime.parse(date.toString());
  String formattedDate = DateFormat.yMMMMd('id').format(dateConverted);

  return formattedDate.toUpperCase();
}

formatDateWithTime(String? date) {
  if (date.toString().isEmpty) {
    return "-";
  } else if (date.toString().contains("null")) {
    return "-";
  }
  initializeDateFormatting('id');

  DateTime originalDate = DateTime.parse(date.toString());

  String formattedDate = DateFormat('d MMMM y HH:mm:ss').format(originalDate);

  return formattedDate.toUpperCase();
}

ubahFormatTanggal(String tanggal) {
  DateTime dateTime = DateTime.parse(tanggal);

  String tanggalAkhir =
      "${dateTime.day.toString().padLeft(2, '0')}${dateTime.month.toString().padLeft(2, '0')}${dateTime.year.toString()}";

  return tanggalAkhir;
}

// Function to get the month label
String getMonthLabel(int month) {
  const monthLabels = {
    1: 'JAN',
    2: 'FEB',
    3: 'MAR',
    4: 'APR',
    5: 'MAY',
    6: 'JUN',
    7: 'JUL',
    8: 'AUG',
    9: 'SEP',
    10: 'OCT',
    11: 'NOV',
    12: 'DEC',
  };

  return monthLabels[month] ?? 'Unknown';
}

double findHighestValue(Map<String, int>? dataMap) {
  if (dataMap == null || dataMap.isEmpty) {
    return 0.0; // Return 0.0 if dataMap is null or empty
  }

  int highestValue = dataMap.values.first;

  dataMap.forEach((key, value) {
    if (value > highestValue) {
      highestValue = value;
    }
  });
  if (highestValue <= 200) {
    return highestValue.toDouble() + 20;
  } else if (highestValue >= 1000) {
    return highestValue.toDouble() + 200;
  } else if (highestValue >= 10000) {
    return highestValue.toDouble() + 5000;
  } else {
    return highestValue.toDouble() + 40;
  }
}
