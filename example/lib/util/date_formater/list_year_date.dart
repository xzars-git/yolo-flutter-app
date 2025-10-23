List<int> yearList() {
  final currentYear = DateTime.now().year;
  final startYear = currentYear - 10;
  final endYear = currentYear + 20;

  List<int> years = [];
  for (int year = startYear; year <= endYear; year++) {
    years.add(year);
  }

  return years;
}
