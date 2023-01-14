import 'package:flutter/cupertino.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/repository/expenses_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';

class ExpenseProvider with ChangeNotifier {
  //firebase

  //sqlite

  //variables
  final repository = ExpensesRepository();
  final preferences = SharedPreferencesHelper.instance;

  final List<Expense> _expenses = [];

  bool loading = false;
  bool initialFetchFinished = false;

  //getters
  List<Expense> get expenses => _expenses;

  //state management

  Future<void> add(Expense expense) async {
    loading = true;
    notifyListeners();
    try {
      final newExpense = await repository.save(expense);
      _expenses.add(newExpense);
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Expense expense) async {
    loading = true;
    notifyListeners();
    try {
      await repository.update(expense);
      final index = expenses.indexWhere((element) => element.id == expense.id);
      _expenses[index] = expense;
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(Expense expense) async {
    loading = true;
    notifyListeners();
    try {
      final exp = await repository.remove(expense);
      if (exp != null) {
        _expenses.removeWhere((element) => element.id == expense.id);
      }
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpenses() async {
    loading = true;

    notifyListeners();

    try {
      await repository.fetchLastSync(preferences.getLastSync());
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
     
      notifyListeners();
    }
  }

  void clear() {}

  Future<void> get() async {
    loading = true;

    notifyListeners();
    try {
    
      _expenses.addAll(await repository.readAll());
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
       initialFetchFinished = true;
      notifyListeners();
    }
  }
}
