class NumUtil {
  static const KM_TO_MILES = 0.6213711922;

  static double metersToKm(num meters) => meters / 1000;

  static double kmToMiles(num km) => km * KM_TO_MILES;

  static double milesToKm(num miles) => miles / KM_TO_MILES;

  static String durationToPretty(Duration duration) {
    String fmt = "";
    if (duration.inDays >= 1) fmt += "${duration.inDays}days, ";
    if (duration.inHours >= 1) fmt += "${duration.inHours % 24}hrs, ";
    fmt += "${duration.inMinutes % 60} mins";
    return fmt;
  }

  static double trimToPrecision(double num, int dec) => double.parse(num.toStringAsFixed(dec));
}
