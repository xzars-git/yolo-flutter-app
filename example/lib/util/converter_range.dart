String converterRange(String numberOnMeter) {
  try {
    double meters = double.parse(numberOnMeter);

    if (meters < 1000) {
      return '${meters.toInt()} M';
    } else {
      double kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(2)} KM';
    }
  } catch (e) {
    return numberOnMeter;
  }
}
