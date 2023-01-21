class ExpenseQueries {
  static const String _table = 'expenses';


  static String readExpenses([int offset = 0]) {
    const limit = 100;
    String sql = '';
    sql =
        'SELECT e.*, date(e.createdDate / 1000 , "unixepoch", "localtime") as "date" from $_table e where deleted = FALSE order by createdDate desc LIMIT $limit OFFSET $offset';
   
    // print(sql);
    return sql;
  }
}
