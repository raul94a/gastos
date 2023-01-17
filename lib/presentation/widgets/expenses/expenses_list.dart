import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:provider/provider.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Consumer<ExpenseProvider>(
      builder: (ctx, state, _) => Center(
        child: SizedBox(
          width: width * 0.96,
          child: ListView.builder(
              itemCount: state.expenses.keys.toList().length,
              itemBuilder: (ctx, index) =>
                  ExpensesByDateList(state: state, index: index)),
        ),
      ),
    );
  }
}

class ExpensesByDateList extends StatefulWidget {
  const ExpensesByDateList({Key? key, required this.state, required this.index})
      : super(key: key);
  final ExpenseProvider state;
  final int index;

  @override
  State<ExpensesByDateList> createState() => _ExpensesByDateListState();
}

class _ExpensesByDateListState extends State<ExpensesByDateList> {
  bool show = false;
  @override
  void initState() {
    super.initState();
    show = widget.index == 0 ? true : false;
  }

  void changeShowStatus() => setState(() => show = !show);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Wrap(
      children: [
        GestureDetector(
            onTap: changeShowStatus,
            child: Text(widget.state.orderedDate[widget.index])),
        if (show)
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.state
                  .expenses[widget.state.orderedDate[widget.index]]!.length,
              itemBuilder: ((context, i) {
                final date = widget.state.orderedDate[widget.index];
                final List<Expense> expenses = widget.state.expenses[date]!;
                final expense = expenses[i];

                return ExpenseTile(
                    state: widget.state,
                    date: date,
                    expense: expense,
                    position: i);
              })),
        if (widget.index != 0 && show)
          ElevatedButton(
              onPressed: () {},
              child: Text(
                  'Añadir gasto a ${widget.state.orderedDate[widget.index]}'))
      ],
    );
  }
}
