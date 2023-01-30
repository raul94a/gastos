import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/services/individual_expenses_service.dart';
import 'package:gastos/utils/date_formatter.dart';

class IndividualExpensesRepository {
  final service = IndividualExpenseService();

  Future<List<Expense>> getByScroll(String id, int offset) async {
    final List<Map<String, dynamic>> result = await service.readAll(id,offset);
    return result.map(Expense.fromMap).toList();
  }

  Future<Map<String, List<Expense>>> readAll(DateType type, String personFirebaseUID, int offset) async {
    final result = await service.readAll(personFirebaseUID, offset);
    Map<String, List<Expense>> expensesByDateType = {};
    int length = result.length;
    for (int i = 0; i < length; i++) {
      final expense = result[i];
      String date = MyDateFormatter.dateByType(type, expense['date']);
      if (!expensesByDateType.containsKey(date)) {
        expensesByDateType.addAll({
          date.toString(): [Expense.fromMap(expense)]
        });
      } else {
        final list = expensesByDateType[date];
        list?.add(Expense.fromMap(expense));
      }
    }

    //print(expensesByDateType);

    return expensesByDateType;
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

  Future<int> countRows(String id) async => await service.countExpenses(id);

  Future<bool> existsId(String id) async =>
      await service.countIdEntries(id) > 0;

  Future<num> sumUserExpenses(String id) async => await service.sumExpensesOfUser(id);
}
