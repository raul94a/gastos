import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/queries/chart_info_queries.dart';
import 'package:path_provider/path_provider.dart';
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
  final String _expensesTable = "expenses";
  final String _categoriesTable = "categories";
  final String _usersTable = "users";
  String get expensesTable => _expensesTable;
  String get categoriesTable => _categoriesTable;
  String get usersTable => _usersTable;

  Future<void> open() async {
    _database = await openDatabase(
      dbName,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {

      //   final res = await db.rawQuery('select e.*, strftime("%m", e.createdDate / 1000, "unixepoch") as "strData" from expenses e order by createdDate asc');
      //   print(res);
      //   final s = await getExternalStorageDirectory();
      //   String path = s!.path;

      //  final f = File('$path/database.txt');
       
      //   f.createSync();
      //   f.writeAsStringSync(jsonEncode(res));
      final res =  await db.rawQuery(ChartInfoQueries.currentYearExpensesGroupedByMonth(2023));
      print('RESULT ON OPEN $res');
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
        'person varchar(255), description TEXT, picture TEXT, price REAL, personFirebaseUID varchar(255) DEFAULT "", isCommonExpense int DEFAULT 1, '
        'createdDate int, updatedDate int, deleted BOOLEAN, category varchar(255))');
    await db.execute('CREATE TABLE users (firebaseUID varchar(255) primary key,'
        'name varchar(255), email varchar(255),'
        'createdDate int, updatedDate int)');
    final batch = db.batch();
    batch.execute('CREATE TABLE categories (id varchar(255) primary key,'
        'name varchar(255), r int, g int, b int,'
        ' createdDate int, updatedDate int, deleted BOOLEAN)');
    final now = DateTime.now();
    int millis = now.millisecondsSinceEpoch;

    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("rojo", "Combustible", 255,0,0, $millis, $millis, 0)');
    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("verde", "Doméstico", 0,255,0, $millis, $millis, 0)');

    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("azul", "Médico", 0,0,255, $millis, $millis, 0)');
    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("amarillo", "Ocio", 255,255,0, $millis, $millis, 0)');
    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("azulclaro", "Veterinario", 0, 102, 255, $millis, $millis, 0)');

    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("rosa", "Ropa", 255, 51, 204, $millis, $millis, 0)');
    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("marron", "Comida", 128, 0, 0, $millis, $millis, 0)');

    batch.execute(
        'INSERT INTO categories (id, name, r, g, b, createdDate, updatedDate, deleted) VALUES ("grisaceo", "Otros",153, 153, 102, $millis, $millis, 0)');

    await batch.commit();
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
          price: Random().nextDouble() * 15,
          createdDate: createdDate,
          updatedDate: createdDate));
    }

    return exp;
  }
}
