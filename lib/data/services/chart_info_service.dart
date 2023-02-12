import 'package:gastos/data/queries/chart_info_queries.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/months_parser.dart';
import 'package:sqflite/sqflite.dart';

class ChartInfoService {
  ChartInfoService() {}

  SqliteManager sqliteManager = SqliteManager.instance;

  ///Current week expenses by date
  Future<List<Map<String, dynamic>>> getCurrentWeekExpensesByDate() async {
    final _db = sqliteManager.database;
    final now = DateTime.now();
    //i.e 4
    //left = 4 - 1 = 3
    //rigth 7 - 4 = 3
    final weekDay = now.weekday;
    int pastDays = weekDay - 1;
    int futureDays = 7 - weekDay;
    DateTime firstDate = now;
    DateTime lastDate = now;
    if (pastDays != 0) {
      firstDate = firstDate.subtract(Duration(days: pastDays));
    }
    if (futureDays != 0) {
      lastDate = lastDate.add(Duration(days: futureDays));
    }
    List<String> fullDates = [];
    for (int i = 0; i < 7; i++) {
      final date = MyDateFormatter.toYYYYMMdd(firstDate.add(Duration(days: i)));
      fullDates.add(date);
    }
    final initialDate =
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    final endDate = DateTime(lastDate.year, lastDate.month, lastDate.day);

    String sql = ChartInfoQueries.currentWeekExpensesGroupedByDay(
        initialDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch);

    final result = [...await _db.rawQuery(sql)];

    //rellenamos los que no están
    for (final date in fullDates) {
      if (!result.any((element) => element['date'] == date)) {
        result.add({'date': date, 'price': 0.0});
      }
    }
    return result;
  }

  ///Current week expenses by category
  Future<List<Map<String, dynamic>>> getCurrentMonthExpensesByDay() async {
    final _db = sqliteManager.database;
    final now = DateTime.now();
    //i.e 4
    //left = 4 - 1 = 3
    //rigth 7 - 4 = 3
    int month = now.month;
    final year = now.year;

    int monthDays = days(month: month, year: year);

    List<String> fullDates = [];
    for (int i = 1; i <= monthDays; i++) {
      final date =
          '$year-${month < 10 ? "0$month" : month}-${i < 10 ? "0$i" : i}';
      fullDates.add(date);
    }
    print(fullDates);

    final monthNumber = month < 10 ? '0$month' : month.toString();
    String sql =
        ChartInfoQueries.currentMonthExpensesGroupedByDay(monthNumber, year);
    List<Map<String, dynamic>> result = [];

    try {
      result = [...await _db.rawQuery(sql)];
    } catch (err) {
      return [];
    }

    //rellenamos los que no están
    for (final date in fullDates) {
      if (!result.any((element) => element['date'] == date)) {
        result.add({'date': date, 'price': 0.0});
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>>
      getCurrentYearExpensesGroupedByMonth() async {
    final db = sqliteManager.database;
    final now = DateTime.now();
    final year = now.year;
    String sql = ChartInfoQueries.currentYearExpensesGroupedByMonth(year);
    final results = [...await db.rawQuery(sql)];
    List<String> fullDates = [];
    for (int i = 1; i <= 12; i++) {
      final date = '${i < 10 ? "0$i" : i}';
      fullDates.add(date);
    }
     for (final date in fullDates) {
      if (!results.any((element) => element['month'] == date)) {
        results.add({'month': date, 'price': 0.0, 'year': now.year, 'date': '$year-$date-01'});
      }
    }
    return results;

  }
}
