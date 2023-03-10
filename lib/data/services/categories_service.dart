// ignore_for_file: avoid_print

import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/queries/categories_queries.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';

class CategoriesService {
  SqliteManager sqliteManager = SqliteManager.instance;
  FirestoreManager firestoreManager = FirestoreManager.instance;

  Future<String> save(Map<String, dynamic> data) async {
    final firestore = firestoreManager.firestore;

    try {
      final doc = await firestore.collection('categories').add(data);
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
      await firestore
          .collection('categories')
          .doc(data['id'])
          .update({"name": data['name'], "updatedDate": data['updatedDate']});
      await _updateLocal(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateLocal(Map<String, dynamic> data) async {
    try {
      _updateLocal(data);
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<List<Category>> fetchLastSyncFromFirestore(int lastSync,
      [bool returnInsertedDate = false]) async {
    final firestore = firestoreManager.firestore;
    final List<Map<String, dynamic>> firestoreData = [];

    try {
      final docs = await firestore
          .collection('categories')
          .where('updatedDate', isGreaterThanOrEqualTo: lastSync)
          .get();

      // print('lastSync: $lastSync fetching cats!!!!!!!!! $docs');

      final d = docs.docs;
      // print('cats list $d');
      print('${docs.docChanges}');
      for (final query in d) {
        final data = query.data();
        print(data);
        data.addAll({'id': query.id});
        firestoreData.add(data);
      }
      if (firestoreData.isNotEmpty) {
        await SharedPreferencesHelper.instance
            .saveLastSyncCat(DateTime.now().millisecondsSinceEpoch);
        await _insertSynchronizedData(firestoreData);
      }
    } catch (err) {
      print(err);
      rethrow;
    }

    if (!returnInsertedDate || firestoreData.isEmpty) return [];
    return firestoreData.map(Category.fromMap).toList();
  }

  //sql services
  Future<void> _saveLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.categoriesTable;
    await sqliteManager.database.insert(table, data);
  }

  Future<void> _updateLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.categoriesTable;
    await sqliteManager.database
        .update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<void> _insertSynchronizedData(List<Map<String, dynamic>> data) async {
    final table = sqliteManager.categoriesTable;
    final db = sqliteManager.database;
    try {
      for (final object in data) {
        // print('Cateogry obejct $object');
        final results = await countIdEntries(object['id']);
        if (results > 0) {
          await db.update(table, object, where: 'id = ?', whereArgs: [object['id']]);
        } else {
          await db.insert(table, object);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = sqliteManager.database;
    List<Map<String, dynamic>> result =
        await db.rawQuery(CategoriesQueries.getAllSQL());

    return result;
  }

  Future<Map<String, dynamic>> readOne(String id) async {
    final db = sqliteManager.database;
    final res = await db.rawQuery(
        'SELECT * from ${sqliteManager.categoriesTable} where id = "$id" LIMIT 1');
    return res.first;
  }

  Future<int> countCategories() async {
    final db = sqliteManager.database;
    final res = await db.rawQuery("select count(*) as 'res' from categories");
    return res.first['res'] as int;
  }

  Future<int> countIdEntries(String id) async {
    final db = sqliteManager.database;
    //print(await db.rawQuery('SELECT * FROM categories where id = "$id"'));
    final res = await db
        .rawQuery("select count(*) as 'res' from categories where id = '$id'");
    return res.first['res'] as int;
  }
}
