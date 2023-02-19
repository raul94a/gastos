import 'package:gastos/data/queries/chart_info_queries.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/months_parser.dart';
import 'package:sqflite/sqflite.dart';

class ChartInfoService {
  ChartInfoService() {}

  SqliteManager sqliteManager = SqliteManager.instance;

  ///Current week expenses by date
  Future<List<Map<String, dynamic>>> getCurrentWeekExpensesByDate({bool individual = false}) async {
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
        //we add one day here because the SQL query checks the createdDate to be less than the passed endDate
        //example: the current week goes from day 7 to 13. The checked endDate should be less than 13 + 1 (14), so
        //we take everything between [7,14) (14 is mathematically not included!)
    final endDate = DateTime(lastDate.year, lastDate.month, lastDate.day).add(const Duration(days: 1));

    String sql = ChartInfoQueries.currentWeekExpensesGroupedByDay(
        initialDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch,individual);
    print(sql);
    final result = [...await _db.rawQuery(sql)];

    //rellenamos los que no están
    for (final date in fullDates) {
      if (!result.any((element) => element['date'] == date)) {
        result.add({'date': date, 'price': 0.0});
      }
    }
    print('RESULT(week): $result');
    return result;
  }

  ///Current week expenses by category
  Future<List<Map<String, dynamic>>> getCurrentMonthExpensesByDay({bool individual = false}) async {
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
    print('Full dates $fullDates');

    final monthNumber = month < 10 ? '0$month' : month.toString();
    String sql =
        ChartInfoQueries.currentMonthExpensesGroupedByDay(monthNumber, year,individual);
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
    print('RESULT: $result');
    return result;
  }

  Future<List<Map<String, dynamic>>>
      getCurrentYearExpensesGroupedByMonth({bool individual = false}) async {
    final db = sqliteManager.database;
    final now = DateTime.now();
    final year = now.year;
    String sql = ChartInfoQueries.currentYearExpensesGroupedByMonth(year,individual);
    final results = [...await db.rawQuery(sql)];
    List<String> fullDates = [];
    //we need to fill the dates with no data
    for (int i = 1; i <= 12; i++) {
      final date = '${i < 10 ? "0$i" : i}';
      fullDates.add(date);
    }
    for (final date in fullDates) {
      if (!results.any((element) => element['month'] == date)) {
        results.add({
          'month': date,
          'price': 0.0,
          'year': now.year,
          'date': '$year-$date-01'
        });
      }
    }
    return results;
  }

  ///categories
  ///

  Future<List<Map<String, dynamic>>> getCurrentWeekExpensesByCategory({bool individual = false}) async {
    final db = sqliteManager.database;
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

    final initialDate =
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    final endDate = DateTime(lastDate.year, lastDate.month, lastDate.day).add(Duration(days: 1));

    String sql = ChartInfoQueries.currentWeekExpensesGroupedByCategory(
        initialDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch, individual);
    final List<Map<String, dynamic>> results = [...await db.rawQuery(sql)];

    return results;
  }

  Future<List<Map<String, dynamic>>> getCurrentMonthExpensesByCategory({bool individual = false}) async {
    final _db = sqliteManager.database;
    final now = DateTime.now();
    //i.e 4
    //left = 4 - 1 = 3
    //rigth 7 - 4 = 3
    int month = now.month;
    final year = now.year;

    final monthNumber = month < 10 ? '0$month' : month.toString();
    String sql = ChartInfoQueries.currentMonthExpensesGroupedByCategory(
        monthNumber, year,individual);
    List<Map<String, dynamic>> result = [];

    try {
      result = [...await _db.rawQuery(sql)];
    } catch (err) {
      return [];
    }

    return result;
  }

  Future<List<Map<String, dynamic>>>
      getCurrentYearExpensesGroupedByCategory({bool individual = false}) async {
    final db = sqliteManager.database;
    final now = DateTime.now();
    final year = now.year;
    String sql = ChartInfoQueries.currentYearExpensesGroupedByCategory(year,individual);
    final results = [...await db.rawQuery(sql)];
    return results;
  }
}
