import 'package:flutter/cupertino.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/repository/categories_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/utils/date_formatter.dart';

class CategoriesProvider with ChangeNotifier {
  CategoriesProvider() {
    _initialLoad();
  }
  final List<Category> _categories = [];
  final repository = CategoriesRepository();
  final preferences = SharedPreferencesHelper.instance;

  //control vars

  bool error = false;
  bool loading = false;

  //getter
  List<Category> get categories => _categories;

  //methods

  Future<void> _initialLoad() async {
    await fetchCategories();
    await read();
  }

  Future<void> fetchCategories() async {
    loading = true;
    notifyListeners();

    try {
      await repository.fetchLastSync(preferences.getLastSyncCat());
    } catch (err) {
      loading = false;
      notifyListeners();
      rethrow;
    } finally {
      //Not really needed to notify loading false because it is gonna be called in get method
    }
  }

  void addEmpty() {
    _categories.add(Category(
        name: 'Escribe el nombre...',
        r: 0,
        g: 0,
        b: 0,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        deleted: 1));
    notifyListeners();
  }

  void removeEmpty() {
    _categories.removeWhere((element) => element.deleted == 1);
    //notifyListeners();
  }

  Future<void> add(Category category) async {
    loading = true;
    notifyListeners();
    try {
      await repository.save(category);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    try {
      repository.remove(_categories.firstWhere((element) => element.id == id));
      _categories.removeWhere((element) => element.id == id);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void updateLocal(Category category) {
    try {
      final id = category.id;
      final indexOf = categories.indexWhere((e) => e.id == id);
      _categories[indexOf] = category;
      repository.updateLocal(category);
    } catch (err) {
      print(err);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> update(Category category) async {
    try {
      final id = category.id;
      final indexOf = categories.indexWhere((e) => e.id == id);
      _categories[indexOf] = category;
      repository.update(category);
    } catch (err) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> read() async {
    final res = await repository.readAll();

    print('REsult: $res');
    _categories.addAll(res);
    notifyListeners();
  }

  void clear() {
    _categories.clear();
  }

  Future<void> refreshData() async {
    print('Refreshing categories');
    final lastSync = preferences.getLastSyncCat();
    final newEntries = await repository.fetchLastSyncCategories(lastSync);
    if (newEntries.isNotEmpty) {
      for (final entry in newEntries) {
        if (!await repository.existsId(entry.id)) {
          _categories.add(entry);
          notifyListeners();
        } else {
          //two situations:
          //  1. Update the expense
          //  2. Delete the expense
          Category category = await repository.readOne(entry.id);
          if (entry.deleted == 1) {
            remove(category.id);
          } else {
            update(entry);
          }
        }
      }
    }
  }
}
