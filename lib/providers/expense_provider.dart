// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/repository/expenses_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/utils/date_formatter.dart';

class ExpenseProvider with ChangeNotifier {
  //firebase
  ExpenseProvider() {
    _initialLoad();
  }
  Future<void> _initialLoad() async {
    await fetchExpenses();
    _dateType = dateType;
    await get();
  }
  //sqlite

  //variables
  final repository = ExpensesRepository();
  final preferences = SharedPreferencesHelper.instance;

  final Map<String, List<Expense>> _expenses = {};

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
  DateType get dateType => _dateType ??= preferences.getDateType();

  List<String> get orderedDate {
    final type = preferences.getDateType();
    if (type == DateType.week) {
      return (_expenses.keys.toList())
        ..sort((a, b) {
          final splitBySpaceA = a.split(' ');
          final splitBySpaceB = b.split(' ');
          final int numA = int.parse(splitBySpaceA[1]);
          final int numB = int.parse(splitBySpaceB[1]);
          return numB.compareTo(numA);
        });
    } else if (type == DateType.month) {
      return (_expenses.keys.toList())
        ..sort((a, b) {
          //Multiplication of the year by 12 is necessary for the correct sorting, as
          //a number should be generated with the year + month number, we must ensure that any
          //month of the highest year is on the top of the list
          // let's say: Enero 2022 (1 + 2022 = 2023) and Diciembre 2021 (12 + 2021 = 2032)
          // if we don't multiply the year by 12, the last one would be previous to the first one (2032 > 2022)
          // However after the multiplication...
          // 2022 * 12 + 1 = 24265
          // 2021 * 12 + 12 = 24264
          //Ej.
          // a => Septiembre de 2023
          // b => Diciembre de 2023
          // splitBySpaceA = ['Septiembre','de','2023']
          // splitBySpaceB = ['Diciembre, 'de', '2022']
          // numA = 9 + 2023 * 12
          // numB = 12 + 2022 * 12
          // numA > numB

          final splitBySpaceA = a.split(' ');
          final splitBySpaceB = b.split(' ');
          final int numA = MyDateFormatter.monthNumber(splitBySpaceA[0]) +
              int.parse(splitBySpaceA.last) * 12;
          final int numB = MyDateFormatter.monthNumber(splitBySpaceB[0]) +
              int.parse(splitBySpaceB.last) * 12;
          return numB.compareTo(numA);
        });
    }
    return (_expenses.keys.toList())..sort((a, b) => b.compareTo(a));
  }

  //methods
  bool expensesContainsDate(String date) => _expenses.containsKey(date);
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
  //state management

  Future<void> add(Expense expense) async {
    loading = true;
    notifyListeners();
    try {
      final newExpense = await repository.save(expense);
      final dateString = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      final date = MyDateFormatter.dateByType(dateType, dateString);

      _addToExpenses(newExpense, date);
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
      final dateTime = expense.createdDate;
      final dateString = MyDateFormatter.toYYYYMMdd(dateTime);
      final date = MyDateFormatter.dateByType(dateType, dateString);
      List<Expense> expenses = _expenses[date]!;
      final id = expense.id;
      final indexOf = expenses.indexWhere((e) => e.id == id);
      expenses[indexOf] = expense;
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
      String date = MyDateFormatter.toYYYYMMdd(expense.createdDate);
      date = MyDateFormatter.dateByType(dateType, date);
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

  Future<void> get([int offset = 0]) async {
    if (!loading) {
      loading = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 650));
    }
    try {
      // _expenses.clear();
      _expenses.addAll(await repository.readAll(dateType, offset));
    } catch (err) {
      rethrow;
    } finally {
      loading = false;
      initialFetchFinished = true;
      notifyListeners();
    }
  }

  Future<void> getByDateType(DateType type) async {
    offset = 0;
    dateType = type;
    blockInfiniteScroll = false;
    blockFunction = false;
    _expenses.clear();
    await get();
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
        String date = MyDateFormatter.dateByType(
            dateType, MyDateFormatter.toYYYYMMdd(entry.createdDate));
        if (!await repository.existsId(entry.id)) {
          _addToExpenses(entry, date);
          notifyListeners();
        } else {
          //two situations:
          //  1. Update the expense
          //  2. Delete the expense
          Expense expense = await repository.readOne(entry.id);
          if (entry.deleted == 1) {
            remove(expense);
          } else {
            update(entry);
          }
        }
      }
      await preferences.saveLastSync(DateTime.now().millisecondsSinceEpoch);
    }
  }
}
