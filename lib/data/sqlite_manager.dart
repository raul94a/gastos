import 'dart:async';

import 'package:sqflite/sqflite.dart';

class SqliteManager {
  final String dbName = "expenses.db";

  //singleton
  SqliteManager._();
  static SqliteManager? _sqliteManager;
  static SqliteManager get instance => _sqliteManager ??= SqliteManager._();

  Database? _database;

  Database get database => _database!;

  //tables
  String _expensesTable = "expenses";
  String get expensesTable => _expensesTable;

  Future<void> open() async {
    _database = await openDatabase(dbName, version: 1, onCreate: _onCreate, onOpen: (db) async{
      
      // final res  =await db.rawQuery('delete from expenses');
      // print(res);
      
    },);
  }

  FutureOr<void> _onCreate(Database db, int descriptor) async {
    await db.execute(
        'CREATE TABLE expenses (id varchar(255) primary key,' 
        'person varchar(255), description TEXT, picture TEXT, price REAL,' 
        'createdDate varchar(255), updatedDate varchar(255), deleted BOOLEAN)');

  
  }

}
