class CategoriesQueries {
  static const String _table = 'categories';


  static String getAllSQL() => 'SELECT * from $_table';
}
