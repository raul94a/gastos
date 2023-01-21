import 'package:flutter/foundation.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/queries/expense_queries.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';

class ExpenseService {
  SqliteManager sqliteManager = SqliteManager.instance;
  FirestoreManager firestoreManager = FirestoreManager.instance;
  Future<String> save(Map<String, dynamic> data) async {
    final firestore = firestoreManager.firestore;
    try {
      final doc = await firestore.collection('expenses').add(data);
      String id = doc.id;
      data.update('id', (value) => id);
      await _saveLocal(data);
      return id;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> update(Map<String, dynamic> data) async {
    final firestore = firestoreManager.firestore;
    try {
      await firestore.collection('expenses').doc(data['id']).set(data);
      await _updateLocal(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Expense>> fetchLastSyncFromFirestore(int lastSync,
      [bool returnInsertedDate = false]) async {
    final firestore = firestoreManager.firestore;
    final List<Map<String, dynamic>> firestoreData = [];

    try {
      final docs = await firestore
          .collection('expenses')
          .where('updatedDate', isGreaterThanOrEqualTo: lastSync)
          .get();

      final d = docs.docs;
      for (final query in d) {
        final data = query.data();
        data.update('id', (value) => query.id);
        firestoreData.add(data);
      }
      if (firestoreData.isNotEmpty) {
        await SharedPreferencesHelper.instance
            .saveLastSync(DateTime.now().millisecondsSinceEpoch);
      }
      _insertSynchronizedData(firestoreData);
    } catch (err) {
      rethrow;
    }

    if (!returnInsertedDate || firestoreData.isEmpty) return [];
    return firestoreData.map(Expense.fromMap).toList();
  }

  //sql services
  Future<void> _saveLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.expensesTable;
    await sqliteManager.database.insert(table, data);
  }

  Future<void> _updateLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.expensesTable;
    await sqliteManager.database
        .update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> _insertSynchronizedData(List<Map<String, dynamic>> data) async {
    final table = sqliteManager.expensesTable;
    final db = sqliteManager.database;
    try {
      for (final object in data) {
        await db.insert(table, object);
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<List<Map<String, dynamic>>> readAll(int offset) async {
    final db = sqliteManager.database;
    List<Map<String, dynamic>> result =
        await db.rawQuery(ExpenseQueries.readExpenses(offset));

    return result;
  }

  Future<int> countExpenses() async {
    final db = sqliteManager.database;
    final res = await db.rawQuery("select count(*) as 'res' from expenses ");
    return res.first['res'] as int;
  }
}
