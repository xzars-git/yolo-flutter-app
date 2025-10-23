import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/date_formater/list_year_date.dart';

Future<String?> yearPicker(BuildContext context) async {
  final List<int> years = yearList();
  final DateTime currentDate = DateTime.now();
  String? selectedYear = DateFormat('yyyy').format(currentDate);

  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      int initialYearIndex = years.indexOf(currentDate.year);

      return AlertDialog(
        title: Text(
          "Pilih Tahun",
          style: myTextTheme.headlineSmall?.copyWith(color: blue800, height: 1.5),
        ),
        content: SizedBox(
          height: 100,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: initialYearIndex),
            onSelectedItemChanged: (int index) {
              selectedYear = years[index].toString();
            },
            children: years.map((int year) {
              return Center(child: Text(year.toString(), style: const TextStyle(fontSize: 20)));
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text(
              "Kembali",
              style: myTextTheme.headlineSmall?.copyWith(color: blue800, height: 1.5),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(selectedYear);
            },
            child: Text(
              "Simpan",
              style: myTextTheme.headlineSmall?.copyWith(color: blue800, height: 1.5),
            ),
          ),
        ],
      );
    },
  );

  return selectedYear;
}
