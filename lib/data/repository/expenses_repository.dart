import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/services/expenses_service.dart';

class ExpensesRepository {
  final service = ExpenseService();

  Future<List<Expense>> readAll() async {
    return (await service.readAll()).map(Expense.fromMap).toList();
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
