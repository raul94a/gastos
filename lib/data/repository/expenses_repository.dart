import 'dart:math';

import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/services/expenses_service.dart';

class ExpensesRepository {
  final service = ExpenseService();

  Future<Map<String, List<Expense>>> readAll() async {
    final result = await service.readAll();
    Map<String, List<Expense>> expensesByDateType = {};
    int length = result.length;
    for (int i = 0; i < length; i++) {
      final expense = result[i];
      if (!expensesByDateType.containsKey(expense['date'])) {
        expensesByDateType.addAll({
          expense['date'].toString(): [Expense.fromMap(expense)]
        });
      } else {
        final list = expensesByDateType[expense['date']];
        list?.add(Expense.fromMap(expense));
      }
    }

    print(expensesByDateType);

    return expensesByDateType;
  }

  Future<Expense> save(Expense expense) async {
    String id = await service.save(expense.toMap());
    return expense.copyWith(id: id);
  }

  Future<Expense?> remove(Expense expense) async {
    final newExpense = expense.copyWith(deleted: 1);
    try {
      await service.update(newExpense.toMap());
      return newExpense;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> update(Expense expense) async {
    await service.update(expense.toMap());
  }

  Future<void> fetchLastSync(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync);
}
