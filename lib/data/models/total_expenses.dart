import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/utils/date_formatter.dart';

class TotalExpenses {
  Map<String, List<Expense>> individualExpenses = {};
  Map<String, List<Expense>> commonExpenses = {};

  int get individualExpensesKeys => individualExpenses.keys.length;
  int get commonExpensesKeys => commonExpenses.keys.length;

  //
  void addIndividualExpense(DateType type, Map<String, dynamic> expense) {
    String date = MyDateFormatter.dateByType(type, expense['date']);
    if (!individualExpenses.containsKey(date)) {
      individualExpenses.addAll({
        date.toString(): [Expense.fromMap(expense)]
      });
    } else {
      final list = individualExpenses[date];
      list?.add(Expense.fromMap(expense));
    }
  }

  void addCommonExpense(DateType type, Map<String, dynamic> expense) {
    String date = MyDateFormatter.dateByType(type, expense['date']);
    if (!commonExpenses.containsKey(date)) {
      commonExpenses.addAll({
        date.toString(): [Expense.fromMap(expense)]
      });
    } else {
      final list = commonExpenses[date];
      list?.add(Expense.fromMap(expense));
    }
  }
}
