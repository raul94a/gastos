import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/models/user.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';

class UserService {
  SqliteManager sqliteManager = SqliteManager.instance;
  FirestoreManager firestoreManager = FirestoreManager.instance;
  Future<void> save(Map<String, dynamic> data) async {
    final firestore = firestoreManager.firestore;

    try {
      final checkDoc = await firestore
          .collection('users')
          .where('email', isEqualTo: data['email'])
          .get();
      if (checkDoc.docs.isNotEmpty) {
        print('El email ya está en uso');
        throw Exception('El email ya está en uso');
      }
      final doc = await firestore
          .collection('users')
          .doc(data['firebaseUID'])
          .set(data);

      await _saveLocal(data);
    } catch (error) {
      rethrow;
    }
  }


  Future<List<AppUser>> fetchLastSyncFromFirestore(int lastSync,
      [bool returnInsertedDate = false]) async {
    final firestore = firestoreManager.firestore;
    final List<Map<String, dynamic>> firestoreData = [];

    try {
      final docs = await firestore
          .collection('users')
          .where('updatedDate', isGreaterThanOrEqualTo: lastSync)
          .get();

      final d = docs.docs;
      print('Users from firestore: ${d}');
      for (final query in d) {
        print('User object: ${query.data()}');
        final data = query.data();
        //data.update('id', (value) => query.id);
        firestoreData.add(data);
      }
      if(d.isNotEmpty){
        await SharedPreferencesHelper.instance.saveLastSyncUsers(DateTime.now().millisecondsSinceEpoch);
      }
      await _insertSynchronizedData(firestoreData);

    } catch (err) {
      rethrow;
    }

    if (!returnInsertedDate || firestoreData.isEmpty) return [];
    return firestoreData.map(AppUser.fromMap).toList();
  }

  //sql services
  Future<void> _saveLocal(Map<String, dynamic> data) async {
    String table = sqliteManager.usersTable;
    await sqliteManager.database.insert(table, data);
  }

  Future<void> _insertSynchronizedData(List<Map<String, dynamic>> data) async {
    final table = sqliteManager.usersTable;
    final db = sqliteManager.database;
    try {
      for (final object in data) {
        final results = await countIdEntries(object['firebaseUID']);
        if (results > 0) {
          print('UPDATING USER');
          await db.update(table, object, where: 'firebaseUID = ?', whereArgs: [object['firebaseUID']]);
        } else {
          print('INSERTING USER');
          final res = await db.insert(table, object);
         
        }
      }
    } catch (err) {
      
        print('Error in _synchroUserData: $err');
      
    }
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = sqliteManager.database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM users');
        print('select * from users: $result');

    return result;
  }

  Future<Map<String, dynamic>> readOne(String id) async {
    print('FIREBASE UID: $id');
    final db = sqliteManager.database;
    final res = await db.rawQuery(
        "SELECT * from users where firebaseUID = '$id' LIMIT 1");
      if(res.isEmpty) return {};
    return res.first;
  }

  Future<int> countUsers() async {
    final db = sqliteManager.database;
    final res = await db.rawQuery("select count(*) as 'res' from users");
    return res.first['res'] as int;
  }

  Future<int> countIdEntries(String id) async {
    final db = sqliteManager.database;
    final res = await db.rawQuery(
        "select count(*) as 'res' from users where firebaseUID = '$id'");
    return res.first['res'] as int;
  }
}
