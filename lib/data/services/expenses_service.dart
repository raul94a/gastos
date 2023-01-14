import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseService {
  SqliteManager sqliteManager = SqliteManager.instance;
  FirestoreManager firestoreManager = FirestoreManager.instance;

  Future<void> save(Map<String, dynamic> data) async {
    final firestore = firestoreManager.firestore;
    try {
      final doc = await firestore.collection('expenses').add(data);
      String id = doc.id;
      data.update('id', (value) => id);
      await _saveLocal(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _saveLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.expensesTable;
    await sqliteManager.database.insert('expenses', data);
  }
}
