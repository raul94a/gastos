class ExpenseQueries {
  static const String _table = 'expenses';

  static String readExpensesByDate(String date, [int offset = 0]) {
    const limit = 100;
    String sql = '';
    sql =
        'SELECT e.*, date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" from $_table e where deleted = 0 AND date = "$date" order by createdDate desc';

    // print(sql);
    return sql;
  }

  static String readExpensesByWeek(String weekNumber, int year) {
    String sql =
        'select e.*, strftime("%W", e.createdDate / 1000, "unixepoch") as "week", '
        'strftime("%Y", e.createdDate/1000,"unixepoch") as "year", '
        'date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" '
        'from expenses e where week = "$weekNumber" AND year = "$year" AND deleted = 0 order by createdDate desc';

    return sql;
  }

  static String readExpensesByMonth(String monthNumber, int year) {
    String sql =
        'select e.*, strftime("%m", e.createdDate / 1000, "unixepoch") as "month", '
        'strftime("%Y", e.createdDate/1000,"unixepoch") as "year", '
        'date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" '
        'from expenses e where month = "$monthNumber" AND year = "$year" AND deleted = 0 order by createdDate desc';

    return sql;
  }

  static String readExpensesByYear(int year) {
    String sql =
        'select e.*, date(e.createdDate / 1000 , "unixepoch", "localtime") as "date"'
        ',strftime("%m", e.createdDate / 1000, "unixepoch") as "month", '
        'strftime("%Y", e.createdDate/1000,"unixepoch") as "year" '
        'from expenses e where year = "$year" AND deleted = 0 order by createdDate desc';

    return sql;
  }

  static String readExpenses([int offset = 0]) {
    const limit = 100;
    String sql = '';
    sql =
        'SELECT e.*, date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" from $_table e where deleted = 0 order by createdDate desc LIMIT $limit OFFSET $offset';

    // print(sql);
    return sql;
  }

  static String readExpensesOfUserByDate(String name) {
    String sql =
        'SELECT SUM(price) as "total" from $_table e where deleted = FALSE AND isCommonExpense = 1 AND person = "$name"';

    return sql;
  }

  //individual
  static String readExpensesIndividual(String id, [int offset = 0]) {
    const limit = 100;
    String sql = '';
    sql =
        'SELECT e.*, date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" from $_table e where deleted = 0 AND isCommonExpense = 0 AND personFirebaseUID = "$id" order by createdDate desc LIMIT $limit OFFSET $offset';

    // print(sql);
    return sql;
  }

  static String readExpensesOfUserByDateIndividual(String id) {
    String sql =
        'SELECT SUM(price) as "total" from $_table e where deleted = 0 AND isCommonExpense = 0 AND personFirebaseUID = "$id"';

    return sql;
  }
}
