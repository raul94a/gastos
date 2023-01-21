import 'dart:async';
import 'dart:math';

import 'package:gastos/data/models/expense.dart';
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
    _database = await openDatabase(
      dbName,
      version: 2,
      onCreate: _onCreate,
      onOpen: (db) async {

        // final res = await db.rawQuery('select count(*) as "res" from expenses');
        // print(res);
        // final exps = ExpenseCreator.create();

        // for(final o in exps){
        //   await db.insert('expenses', o.toMap());
        // }
        // final res  =await db.rawQuery('delete from expenses');
        // print(res);
        //  final res = await db.rawQuery('SELECT e.*, date(e.createdDate / 1000 , "unixepoch") as "date" from expenses e order by date desc');
      },
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  FutureOr<void> _onCreate(Database db, int descriptor) async {
    await db.execute('CREATE TABLE expenses (id varchar(255) primary key,'
        'person varchar(255), description TEXT, picture TEXT, price REAL,'
        'createdDate int, updatedDate int, deleted BOOLEAN)');
  }
}

class ExpenseCreator {
  static String randomId(int length) {
    const dic =
        'abcdefghijklmñopqrstuvwxyzABCDEFGHYJKLMÑOPQRSTUVWXYZ12345678490-.,¿?_';
    String str = '';
    for (int i = 0; i < length; i++) {
      final randStr = Random().nextInt(dic.length - 1);
      str += dic[randStr];
    }
    return str;
  }

  static List<Expense> create() {
    List<Expense> exp = [];
    const reps = 1000;
    const year = 2023;
    final months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    final days = [];
    for (int i = 1; i <= 28; i++) {
      days.add(i);
    }
    for (int i = 0; i < reps; i++) {
      final randomMonth = Random().nextInt(months.length) + 1;
      final randomDay = Random().nextInt(days.length) + 1;
      final createdDate = DateTime(year, randomMonth, randomDay);
      final id = randomId(50);
      exp.add(Expense(
        id: id,
          person: 'Raul',
          description: 'Random${Random.secure().nextInt(555555555)}',
          price: Random.secure().nextDouble() * 88888888888,
          createdDate: createdDate,
          updatedDate: createdDate));
    }

    return exp;
  }
}
