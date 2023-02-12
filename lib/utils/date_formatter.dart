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
  static String weekYearString(DateTime date){
    int week = weekYear(date);
    if(week < 10){
      return '0$week';
    }
    return '$week';
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

  static String monthThreeLetters(String month){
     switch (month) {
      case "01":
        return 'Ene.';
      case "02":
        return 'Feb.';
      case "03":
        return 'Mar.';
      case "04":
        return 'Abr.';
      case "05":
        return 'May.';
      case "06":
        return 'Jun.';
      case "07":
        return 'Jul.';
      case "08":
        return 'Ago.';
      case "09":
        return 'Sep.';
      case "10":
        return 'Oct.';
      case "11":
        return 'Nov.';
      default:
        return 'Dic.';
    }
  }

  static int monthNumber(String month) {
    switch (month) {
      case 'Enero':
        return 1;
      case 'Febrero':
        return 2;
      case 'Marzo':
        return 3;
      case 'Abril':
        return 4;
      case 'Mayo':
        return 5;
      case 'Junio':
        return 6;
      case 'Julio':
        return 7;
      case 'Agosto':
        return 8;
      case 'Septiembre':
        return 9;
      case 'Octubre':
        return 10;
      case 'Noviembre':
        return 11;
      default:
        return 12;
    }
  }
}
