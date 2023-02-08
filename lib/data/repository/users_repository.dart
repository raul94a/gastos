import 'package:gastos/data/models/user.dart';
import 'package:gastos/data/services/users_service.dart';


class UserRepository {
  final service = UserService();

  Future<List<AppUser>> readAll() async {
    final result = await service.readAll();
    List<AppUser> users = [];
    for (final user in result) {
      users.add(AppUser.fromMap(user));
    }
    return users;
  }

  Future<AppUser> readOne(String id) async {
    final result = await service.readOne(id);
    print(result);
    return AppUser.fromMap(result);
  }

  Future<void> save(AppUser user) async {
    await service.save(user.toMap());
    
  }


  // Future<Category?> remove(Category category) async {
  //   final newCategory = category.copyWith(deleted: 1);
  //   try {
  //     await service.update(newCategory.toMap());
  //     return newCategory;
  //   } catch (err) {
  //     rethrow;
  //   }
  // }

  // Future<void> update(Category category) async {
  //   await service.update(category.toMap());
  // }
  // Future<void> updateLocal(Category category) async {
  //   service.updateLocal(category.toMap());
  // }

  Future<void> fetchLastSync(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync);

  Future<List<AppUser>> fetchLastSyncUsers(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync, true);

  Future<int> countRows() async => await service.countUsers();

  Future<bool> existsId(String id) async =>
      await service.countIdEntries(id) > 0;
}
