import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/providers/expense_provider.dart';

class ExpenseOptionsDialog extends StatelessWidget {
  const ExpenseOptionsDialog(
      {Key? key,
      required this.state,
      required this.index,
      required this.date,
      required this.updateHandler,
      required this.expense})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final int index;
  final Function(Expense) updateHandler;
  final Expense expense;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      alignment: Alignment.center,
      title: const Text('Selecciona la acción que desees'),
      children: [
        TextButton.icon(
            onPressed: () {
              if (state.loading) return;
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (ctx) => ExpenseDialog(
                      expense: expense, updateHandler: updateHandler));
            },
            icon: const Icon(
              Icons.update,
              color: Colors.blue,
            ),
            label: const Text('Actualizar gasto',
                style: TextStyle(color: Colors.blue))),
        TextButton.icon(
            onPressed: () => {
                  state.remove(state.expenses[date]![index]),
                  Navigator.of(context).pop()
                },
            icon: const Icon(Icons.update, color: Colors.blue),
            label: const Text('Eliminar gasto',
                style: TextStyle(color: Colors.blue))),
        TextButton.icon(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: Navigator.of(context).pop,
            label: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.red),
            )),
      ],
    );
  }
}
