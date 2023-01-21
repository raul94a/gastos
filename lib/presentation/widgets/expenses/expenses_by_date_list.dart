import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExpensesByDateList extends StatefulWidget {
  const ExpensesByDateList({Key? key, required this.state, required this.index})
      : super(key: key);
  final ExpenseProvider state;
  final int index;

  @override
  State<ExpensesByDateList> createState() => _ExpensesByDateListState();
}

class _ExpensesByDateListState extends State<ExpensesByDateList> {
  bool show = true;
  @override
  void initState() {
    super.initState();
    show = widget.index <= 5 ? true : false;
  }

  void changeShowStatus() => setState(() => show = !show);

  @override
  Widget build(BuildContext context) {
    final orderedKeys = widget.state.orderedDate;
    final keyIndex = widget.index;
    final expenses = widget.state.expenses;
    final isLastDate = keyIndex == expenses.keys.length - 1;
    final List<Expense> expensesOfDate = expenses[orderedKeys[keyIndex]]!;
    String titleDate = orderedKeys[keyIndex];

    if (context.read<ExpenseProvider>().preferences.getDateType() ==
        DateType.day) {
      final date = MyDateFormatter.fromYYYYMMdd(orderedKeys[keyIndex]);
      titleDate = MyDateFormatter.toFormat('dd-MM-yyyy', date);
    }
    return Card(
      margin: EdgeInsets.only(
          top: 10, left: 5, right: 5, bottom: isLastDate ? 80 : 0),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(titleDate, style: GoogleFonts.yujiBoku(fontSize: 24.2)),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: changeShowStatus,
                    icon: Icon(show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined))
              ],
            ),
            if (show)
              ListView.builder(
                  shrinkWrap: true,
                  primary: false, // shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expensesOfDate.length,
                  itemBuilder: ((context, i) {
                    final date = orderedKeys[keyIndex];
                    final List<Expense> expenses = widget.state.expenses[date]!;
                    final expense = expenses[i];

                    return ExpenseTile(
                        key: Key('Date-${expense.id}'),
                        state: widget.state,
                        date: date,
                        expense: expense,
                        position: i);
                  })),
            if (widget.index != 0 && show)
              ElevatedButton(
                  onPressed: () {
                    showDialog(context: context, builder: (ctx)=> ExpenseDialog(date: orderedKeys[keyIndex]));
                  },
                  child: Text(
                      'Añadir gasto a ${widget.state.orderedDate[widget.index]}')),
          ],
        ),
      ),
    );
  }
}
