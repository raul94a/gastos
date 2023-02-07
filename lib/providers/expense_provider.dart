import 'package:flutter/cupertino.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/repository/expenses_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/logic/sorter.dart';
import 'package:gastos/utils/date_formatter.dart';

class ExpenseProvider with ChangeNotifier {
  //firebase
  ExpenseProvider();

  Future<void> initialLoad({required String firebaseUID}) async {
    await fetchExpenses();
    _dateType = dateType;
    String date = MyDateFormatter.toYYYYMMdd(DateTime.now());
    await getByDate(date, 0, firebaseUID);
  }
  //sqlite

  //variables
  final repository = ExpensesRepository();
  final preferences = SharedPreferencesHelper.instance;

  final Map<String, List<Expense>> _expenses = {};
  final Map<String, List<Expense>> _individualExpenses = {};

  bool loading = false;
  bool initialFetchFinished = false;
  bool success = false;
  bool error = false;
  bool blockInfiniteScroll = false;
  bool blockFunction = false;
  int offset = 0;

  DateType? _dateType;

  //setters
  set dateType(DateType type) => _dateType = type;
  //getters
  Map<String, List<Expense>> get expenses => _expenses;
  Map<String, List<Expense>> get individualExpenses => _individualExpenses;

  DateType get dateType => _dateType ??= preferences.getDateType();

  //sort maps
  List<String> get orderedDate {
    final type = preferences.getDateType();
    final sorter = MySortter();
    if (type == DateType.week) {
      return (_expenses.keys.toList())..sort(sorter.sortByWeek);
    } else if (type == DateType.month) {
      return (_expenses.keys.toList())..sort(sorter.sortByMonth);
    }
    return (_expenses.keys.toList())..sort((a, b) => b.compareTo(a));
  }

  List<String> get orderedDateIndividualExpenses {
    final type = preferences.getDateType();
    final sorter = MySortter();
    if (type == DateType.week) {
      return (_individualExpenses.keys.toList())..sort(sorter.sortByWeek);
    } else if (type == DateType.month) {
      return (_individualExpenses.keys.toList())..sort(sorter.sortByMonth);
    }
    return (_individualExpenses.keys.toList())..sort((a, b) => b.compareTo(a));
  }

  //methods
  bool expensesContainsDate(String date) => _expenses.containsKey(date);
  bool individualExpensesContainsDate(String date) =>
      _individualExpenses.containsKey(date);

  void _addToExpenses(Expense exp, String date) {
    if (!expensesContainsDate(date)) {
      _expenses.addAll({
        date: [exp]
      });
    } else {
      final List<Expense> list = _expenses[date]!;
      list.add(exp);
    }
  }

  void _addToIndividualExpenses(Expense exp, String date) {
    if (!individualExpensesContainsDate(date)) {
      _individualExpenses.addAll({
        date: [exp]
      });
    } else {
      final List<Expense> list = individualExpenses[date]!;
      list.add(exp);
    }
  }

  //directly add the expense to the correct place
  void _addExpense(bool individual, Expense expense, String date) {
    if (!individual) {
      _addToExpenses(expense, date);
    } else {
      _addToIndividualExpenses(expense, date);
    }
  }

  //state management
  Future<void> add({required Expense expense, bool individual = false}) async {
    loading = true;
    notifyListeners();
    try {
      final newExpense = await repository.save(expense);
      final dateString = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      final date = MyDateFormatter.dateByType(dateType, dateString);

      _addExpense(individual, newExpense, date);
      success = true;
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> update(
      {required Expense expense, bool individual = false}) async {
    try {
      final dateTime = expense.createdDate;
      final dateString = MyDateFormatter.toYYYYMMdd(dateTime);
      final date = MyDateFormatter.dateByType(dateType, dateString);
      if (!individual) {
        List<Expense> expenses = _expenses[date]!;
        final id = expense.id;
        final indexOf = expenses.indexWhere((e) => e.id == id);
        expenses[indexOf] = expense;
      } else {
        List<Expense> expenses = _individualExpenses[date]!;
        final id = expense.id;
        final indexOf = expenses.indexWhere((e) => e.id == id);
        expenses[indexOf] = expense;
      }
      repository.update(expense);
    } catch (err) {
      rethrow;
    }
  }

  void remove({required Expense expense, bool individual = false}) async {
    //loading = true;
    //notifyListeners();
    try {
      print('Starting removal of expense ${expense.id}');
      String date = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      date = MyDateFormatter.dateByType(dateType, date);
      //common expenses
      if (!individual) {
        final list = _expenses[date];
        print('Expense was created in dae: $date');
        print('Expenses list for $date is: $list');
        if (list != null) {
          final index = list.indexWhere((element) => element.id == expense.id);
          print('Expense ${expense.id} is at $index');
          final removedExpense = list.removeAt(index);
          await repository.remove(expense);
          print('removedExpense: $removedExpense');
          _expenses[date] = [...list];

          if (list.isEmpty) {
            _expenses.remove(date);
          }
        }
      }
      //individual expenses
      else {
        final list = _individualExpenses[date];
        print('Expense was created in dae: $date');
        print('Expenses list for $date is: $list');
        if (list != null) {
          final index = list.indexWhere((element) => element.id == expense.id);
          print('Expense ${expense.id} is at $index');
          final removedExpense = list.removeAt(index);
          await repository.remove(removedExpense);
          print('removedExpense: $removedExpense');
          _individualExpenses[date] = [...list];

          if (list.isEmpty) {
            _individualExpenses.remove(date);
          }
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
      loading = false;
      notifyListeners();
      rethrow;
    } finally {
      //Not really needed to notify loading false because it is gonna be called in get method
    }
  }

  void clear() {
    success = false;
    loading = false;
    error = false;
  }

  Future<void> get(String firebaseUID, [int offset = 0]) async {
    print('CALLING GET ${expenses.length}');
    if (!loading) {
      loading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 150));
    }
    try {
      final totalExpenses =
          await repository.readAll(dateType, offset, firebaseUID);
      _expenses.addAll(totalExpenses.commonExpenses);
      _individualExpenses.addAll(totalExpenses.individualExpenses);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      loading = false;
      initialFetchFinished = true;
      notifyListeners();
    }
  }
  //get the expenses of a day
  Future<void> getByDate(String date, int offset, String firebaseUID) async {
    print('CALLING GET BY DATE');
    if (!loading) {
      loading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 150));
    }
    try {
      final totalExpenses =
          await repository.readByDate(date, offset, firebaseUID);
      final commonExpenses = totalExpenses.commonExpenses;
      final individualExpenses = totalExpenses.individualExpenses;
      _expenses.addAll(commonExpenses);

      _individualExpenses.addAll(individualExpenses);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      loading = false;
      initialFetchFinished = true;
      notifyListeners();
    }
  }

  ///get the expenses from a month of a year
   Future<void>   getByMonth(String month, int year, String firebaseUID) async {
    print('CALLING GET BY DATE');
    if (!loading) {
      loading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 150));
    }
    try {
      final totalExpenses =
          await repository.readByMonth(month, year, firebaseUID);
      final commonExpenses = totalExpenses.commonExpenses;
      final individualExpenses = totalExpenses.individualExpenses;
      _expenses.addAll(commonExpenses);
      _individualExpenses.addAll(individualExpenses);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      loading = false;
      initialFetchFinished = true;
      notifyListeners();
    }
  }

  Future<void> getByDateType(
      {required DateType type, required String firebaseUID}) async {
    offset = 0;
    dateType = type;
    blockInfiniteScroll = false;
    blockFunction = false;
    _expenses.clear();
    await get(firebaseUID);
  }

  Future<void> getByScroll() async {
    if (blockFunction | blockInfiniteScroll) return;
    blockFunction = true;
    offset += 100;
    int count = await repository.countRows();
    if (offset - 100 >= count) {
      print('Infinite Scrolling has been blocked');
      blockInfiniteScroll = true;
      return;
    }
    final type = preferences.getDateType();
    final newList = await repository.getByScroll(offset);
    for (final o in newList) {
      String date = MyDateFormatter.dateByType(
          type, MyDateFormatter.toYYYYMMdd(o.createdDate));
      _addToExpenses(o, date);
    }
    blockFunction = false;

    notifyListeners();
  }

  Future<void> refreshData() async {
    print('refreshing expenses');
    final newEntries =
        await repository.fetchLastSyncExpenses(preferences.getLastSync());

    if (newEntries.isNotEmpty) {
      for (final entry in newEntries) {
        print(entry);
        String date = MyDateFormatter.dateByType(
            dateType, MyDateFormatter.toYYYYMMdd(entry.createdDate));
        List<Expense> expensesOfDate = expenses[date]!;
        bool existsDate =
            expensesOfDate.any((element) => element.id == entry.id);
        if (!existsDate) {
          //if isCommonExpense is 0, the expense is individual
          bool isIndividual = entry.isCommonExpense == 0;
          _addExpense(isIndividual, entry, date);
          notifyListeners();
        } else {
          //two situations:
          //  1. Update the expense
          //  2. Delete the expense
          Expense expense = await repository.readOne(entry.id);
          if (entry.deleted == 1) {
            remove(expense: expense, individual: expense.isCommonExpense == 0);
          } else {
            update(expense: entry, individual: expense.isCommonExpense == 0);
          }
          notifyListeners();
        }
      }
      await preferences.saveLastSync(DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<num?> sumExpensesOfUser({required String name}) async {
    loading = true;
    notifyListeners();
    try {} catch (err) {
      final result = await repository.sumUserExpenses(name);
      print(result);
      return result;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
