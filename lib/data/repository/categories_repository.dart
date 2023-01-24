import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/services/categories_service.dart';
import 'package:gastos/utils/date_formatter.dart';

class CategoriesRepository {
  final service = CategoriesService();

  Future<List<Category>> readAll() async {
    final result = await service.readAll();
    List<Category> categories = [];
    for (final category in result) {
      categories.add(Category.fromMap(category));
    }
    return categories;
  }

  Future<Category> readOne(String id) async {
    final result = await service.readOne(id);
    return Category.fromMap(result);
  }

  Future<Category> save(Category category) async {
    String id = await service.save(category.toMap());
    return category.copyWith(id: id);
  }

  Future<Category?> remove(Category category) async {
    final newCategory = category.copyWith(deleted: 1);
    try {
      await service.update(newCategory.toMap());
      return newCategory;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> update(Category category) async {
    await service.update(category.toMap());
  }
  Future<void> updateLocal(Category category) async {
    service.updateLocal(category.toMap());
  }

  Future<void> fetchLastSync(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync);

  Future<List<Category>> fetchLastSyncCategories(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync, true);

  Future<int> countRows() async => await service.countCategories();

  Future<bool> existsId(String id) async =>
      await service.countIdEntries(id) > 0;
}
