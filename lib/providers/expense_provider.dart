import 'package:flutter/cupertino.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/repository/expenses_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/utils/date_formatter.dart';

class ExpenseProvider with ChangeNotifier {
  //firebase

  //sqlite

  //variables
  final repository = ExpensesRepository();
  final preferences = SharedPreferencesHelper.instance;

  final Map<String, List<Expense>> _expenses = {};

  bool loading = false;
  bool initialFetchFinished = false;
  bool success = false;
  bool error = false;

  //getters
  Map<String, List<Expense>> get expenses => _expenses;

  List<String> get orderedDate =>
      (_expenses.keys.toList())..sort((a, b) => b.compareTo(a));

  //methods
  bool expensesContainsDate(String date) => _expenses.containsKey(date);
  //state management

  Future<void> add(Expense expense) async {
    loading = true;
    notifyListeners();
    try {
      final newExpense = await repository.save(expense);
      final date = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      if (expensesContainsDate(date)) {
        final list = _expenses[date];
        list!.add(newExpense);
      } else {
        print('La fecha no existe: $date\nCreando Nueva expense');
        _expenses.addAll({
          date: [newExpense]
        });
        print(_expenses);
      }
      success = true;
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Expense expense) async {
    try {
      repository.update(expense);
    } catch (err) {
      rethrow;
    }
  }

  void remove(Expense expense) {
    //loading = true;
    //notifyListeners();
    try {
      print('Starting removal of expense ${expense.id}');
      final exp = repository.remove(expense);

      final date = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      final list = _expenses[date];
      print('Expense was created in dae: $date');
      print('Expenses list for $date is: $list');
      if (list != null) {
        final index = list.indexWhere((element) => element.id == expense.id);
        print('Expense ${expense.id} is at $index');
        final removedExpense = list.removeAt(index);
        print('removedExpense: $removedExpense');
        _expenses[date] = [...list];

        if (list.isEmpty) {
          _expenses.remove(date);
        }
      }
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      //loading = false;
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

  void clear() {
    success = false;
    loading = false;
    error = false;
  }

  Future<void> get([DateType type = DateType.day]) async {
    loading = true;

    notifyListeners();
    try {
      _expenses.clear();
      _expenses.addAll(await repository.readAll(type));
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      initialFetchFinished = true;
      notifyListeners();
    }
  }
  Future<void> getByDateType(DateType type) async {
    await get(type);
  }
}
