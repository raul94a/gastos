import 'package:flutter/material.dart';

class ExpenseInfoDialog extends StatelessWidget {
  const ExpenseInfoDialog({super.key, required this.dateTitle, required this.numberOfExpenses, required this.total});
  final String dateTitle;
  final double total;
  final int numberOfExpenses;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Gastos de $dateTitle'),
      contentPadding: const EdgeInsets.all(25),
      // insetPadding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dinero gastado:'),
            Text('${total.toStringAsFixed(2)} €')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Número de gastos:'),
            Text('$numberOfExpenses')
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
