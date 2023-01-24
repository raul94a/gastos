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
      await repository.fetchLastSync(preferences.getLastSync());
    } catch (err) {
      loading = false;
      notifyListeners();
      rethrow;
    } finally {
      //Not really needed to notify loading false because it is gonna be called in get method
    }
  }

  Future<void> add(Category category) async {
    loading = true;
    notifyListeners();
    try {
      await repository.save(category);
      _categories.add(category);
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

  Future<void> update(Category category) async {
    try {
      final id = category.id;
      final indexOf = categories.indexWhere((e) => e.id == id);
      _categories[indexOf] = category;
      repository.update(category);
    } catch (err) {
      rethrow;
    }
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
    final lastSync = preferences.getLastSync();
    final newEntries = await repository.fetchLastSyncCategories(lastSync);
    if (newEntries.isNotEmpty) {
      _categories.addAll(newEntries);
      notifyListeners();
    }
  }
}
