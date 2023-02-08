import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

class SortDateButtons extends StatelessWidget with MaterialStatePropertyMixin {
  const SortDateButtons({Key? key, required this.expenseState})
      : super(key: key);

  final ExpenseProvider expenseState;
  Future<void> _sortBy(DateType type, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    expenseState.preferences.saveDateType(type);
    print(type);
    await expenseState.getByDateType(firebaseUID: uid, type: type);
    setSelectedDates(context);
  }

  void setSelectedDates(BuildContext context) {
    context
        .read<SelectedDateProvider>()
        .setSelectedDates(expenseState.dateType);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final state = context.watch<ExpenseProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                fixedSize: getProperty(Size(width * 0.21, 40)),
                backgroundColor: DateType.day == state.dateType
                    ? getProperty(Colors.blue.shade100)
                    : null),
            onPressed: () {
              const type = DateType.day;
              _sortBy(type, context);
            },
            child: const Text('Dia')),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: DateType.week == state.dateType
                    ? getProperty(Colors.blue.shade100)
                    : null,
                fixedSize: getProperty(Size(width * 0.25, 40))),
            onPressed: () {
              const type = DateType.week;
              _sortBy(type, context);
            },
            child: const Text('Semana')),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: DateType.month == state.dateType
                    ? getProperty(Colors.blue.shade100)
                    : null,
                fixedSize: getProperty(Size(width * 0.21, 40))),
            onPressed: () {
              const type = DateType.month;
              _sortBy(type, context);
            },
            child: const Text('Mes')),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: DateType.year == state.dateType
                    ? getProperty(Colors.blue.shade100)
                    : null,
                fixedSize: getProperty(Size(width * 0.21, 40))),
            onPressed: () {
              const type = DateType.year;
              _sortBy(type, context);
            },
            child: const Text('Año'))
      ],
    );
  }
}
