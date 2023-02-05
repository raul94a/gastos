import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/models/total_expenses.dart';
import 'package:gastos/data/services/expenses_service.dart';

class ExpensesRepository {
  final service = ExpenseService();

  Future<List<Expense>> getByScroll(int offset) async {
    final List<Map<String, dynamic>> result = await service.readAll(offset);
    return result.map(Expense.fromMap).toList();
  }

  ///reads the expenses of a DAY
  Future<TotalExpenses> readByDate(
      String date, int offset, String firebaseUID) async {
    final result = await service.readByDate(date, offset);
    int length = result.length;
    final totalExpenses = TotalExpenses();
    for (int i = 0; i < length; i++) {
      final expense = result[i];
      final bool isCommonExpense = (expense['isCommonExpense'] ?? 0) == 1;
      final String personFirebaseUID = expense['personFirebaseUID'] ?? '';
      //two requirements to be an individual expense: it must be marked has isCommonExpense = 1 AND it must bear the user firebaseUID
      if (isCommonExpense) {
        totalExpenses.addCommonExpense(DateType.day, expense);
      }
      if (!isCommonExpense && firebaseUID == personFirebaseUID) {
        totalExpenses.addIndividualExpense(DateType.day, expense);
      }
    }
    return totalExpenses;
  }

  Future<TotalExpenses> readAll(
      DateType type, int offset, String firebaseUID) async {
    final result = await service.readAll(offset);
    int length = result.length;
    final totalExpenses = TotalExpenses();
    for (int i = 0; i < length; i++) {
      final expense = result[i];
      final bool isCommonExpense = (expense['isCommonExpense'] ?? 0) == 1;
      final String personFirebaseUID = expense['personFirebaseUID'] ?? '';
      //two requirements to be an individual expense: it must be marked has isCommonExpense = 1 AND it must bear the user firebaseUID
      if (isCommonExpense) {
        totalExpenses.addCommonExpense(type, expense);
      }
      if (!isCommonExpense && firebaseUID == personFirebaseUID) {
        totalExpenses.addIndividualExpense(type, expense);
      }
    }
    return totalExpenses;
  }

  Future<Expense> readOne(String id) async {
    final result = await service.readOne(id);
    return Expense.fromMap(result);
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

  Future<List<Expense>> fetchLastSyncExpenses(int lastSync) async =>
      await service.fetchLastSyncFromFirestore(lastSync, true);

  Future<int> countRows() async => await service.countExpenses();

  Future<bool> existsId(String id) async =>
      await service.countIdEntries(id) > 0;

  Future<num> sumUserExpenses(String name) async =>
      await service.sumExpensesOfUser(name);
}
