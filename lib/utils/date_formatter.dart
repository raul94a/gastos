import 'package:intl/intl.dart';

class MyDateFormatter {
  static String yyyyMMdd = 'yyyy-MM-dd';

  static String toYYYYMMdd(DateTime date) {
    return DateFormat(yyyyMMdd).format(date);
  }

  static DateTime fromYYYYMMdd(String date) {
    return DateFormat(yyyyMMdd).parse(date);
  }
}
