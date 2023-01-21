import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_options_dialog.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
    setState(() {
      expense = expense.copyWith(
          updatedDate: exp.updatedDate,
          person: exp.person,
          price: exp.price,
          description: exp.description);
    });
  }

  void showOptionDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
//    print('Rebuild Expense with ID: ${widget.expense.id}');
    final size = MediaQuery.of(context).size;
    final width = size.width;
    bool isEven = widget.position % 2 == 0;
    return Container(
      key: Key(widget.expense.id),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onLongPress: showOptionDialog,
        contentPadding: const EdgeInsets.all(8),
        tileColor: isEven ? Colors.blue.shade100 : Colors.orange.shade100,
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 2.8,
                color: isEven ? Colors.blue.shade500 : Colors.orange.shade500,
                strokeAlign: StrokeAlign.center),
            borderRadius: BorderRadius.circular(7)),
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
                child: Column(
              children: [
                Text(
                  '${expense.price} €',
                  style: GoogleFonts.raleway(fontSize: 16),
                ),
              ],
            )),
          ),
        ),
        title: Text(
          expense.description,
          style: GoogleFonts.raleway(fontSize: 16),
        ),
        subtitle: Text(
          expense.person,
          style: GoogleFonts.raleway(fontSize: 16),
        ),
        trailing: SizedBox(
          width: width * 0.2,
          child: IconButton(
              onPressed: showOptionDialog, icon: Icon(Icons.more_vert)),
        ),
      ),
    );
  }
}
