import 'package:flutter/cupertino.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:intl/intl.dart';

class MyDateFormatter {
  static String yyyyMMdd = 'yyyy-MM-dd';
  static String yyyyMM = 'yyyy-MM';
  static String toYYYYMMdd(DateTime date) {
    return DateFormat(yyyyMMdd).format(date);
  }

  static DateTime fromYYYYMMdd(String date) {
    return DateFormat(yyyyMMdd).parse(date);
  }

  static String toFormat(String format, DateTime date) {
    return DateFormat(format).format(date);
  }

  static DateTime fromFormat(String format, String date) {
    return DateFormat(format).parse(date);
  }

  static int weekYear(DateTime date) =>
      ((date.difference(DateTime(date.year, 1, 1, 0, 0)).inDays + 1) ~/ 7 + 1);

  static String dateByType(DateType type, String date) {
    DateTime parsedDate = fromYYYYMMdd(date);
    switch (type) {
      case DateType.day:
        return date;
      case DateType.month:
        return '${monthName(parsedDate.month)} de ${parsedDate.year}';
      case DateType.year:
        return parsedDate.year.toString();
      case DateType.week:
        return 'Semana ${weekYear(parsedDate)} de ${parsedDate.year}';
    }
  }

  static String monthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      default:
        return 'Diciembre';
    }
  }
}
