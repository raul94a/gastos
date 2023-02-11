import 'package:gastos/data/queries/chart_info_queries.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:sqflite/sqflite.dart';

class ChartInfoService {
  ChartInfoService() {
    _db = sqliteManager.database;
  }

  SqliteManager sqliteManager = SqliteManager.instance;
  late Database _db;

  ///Current week expenses by date
  Future<List<Map<String, dynamic>>> getCurrentWeekExpensesByDate() async {
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
  Future<void> getCurrentWeekExpensesByCategory() async {}
}
