class ChartInfoQueries {


  static String currentWeekExpensesGroupedByDay(
      int startTimeMillis, int endTimeMillis) {
    String sql =
        'SELECT date(e.createdDate / 1000 , "unixepoch", "localtime") as "date",  SUM(price) as "price" '
        'from expenses e '
        'where deleted = 0 '
        'AND isCommonExpense = 1 '
        'AND ( createdDate > $startTimeMillis '
        'AND createdDate < $endTimeMillis ) '
        'GROUP BY date '
        '';
    return sql;
  }

  static String currentWeekExpensesGroupedByCategory(){
    return '';
  }
}
