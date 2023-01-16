class ExpenseQueries {
  static String _table = 'expenses';

  //TODO: DATE TYPE
  static String readExpenses() {
    String sql = '';
    sql =
        'SELECT e.*, date(e.createdDate / 1000 , "unixepoch") as "date" from $_table e where deleted = FALSE order by date asc';
    return sql;
  }
}
