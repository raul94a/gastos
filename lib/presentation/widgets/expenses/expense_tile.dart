import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_options_dialog.dart';
import 'package:gastos/providers/expense_provider.dart';

//TODO: SELF MANAGEMENT FOR THE UPDATING OF THIS WIDGET => AVOID REBUILD ALL THE LIST WHEN UPDATING
class ExpenseTile extends StatefulWidget {
  const ExpenseTile(
      {Key? key,
      required this.state,
      required this.date,
      required this.expense,
      required this.position})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final Expense expense;
  final int position;

  @override
  State<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  late Expense expense;
  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  void updateExpense(Expense exp) {
    print('CALLING SET STATE!!!!');
    setState(() {
      expense = expense.copyWith(
        updatedDate: exp.updatedDate,
        person: exp.person,
        price: exp.price,

      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return ExpenseOptionsDialog(
                    updateHandler: updateExpense,
                    expense: expense,
                    state: widget.state,
                    index: widget.position,
                    date: widget.date);
              });
        },
        contentPadding: const EdgeInsets.all(8),
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(7)),
        leading: Text('${widget.position + 1}'),
        title: Text(expense.description),
        subtitle: Text(expense.person),
        trailing: CircleAvatar(
          radius: 70,
          child: Text('${expense.price} €'),
        ),
      ),
    );
  }
}
