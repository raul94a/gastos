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
          width: width * 0.995,
          child: ListView.builder(
              physics: const ScrollPhysics(),
              itemCount: state.expenses.keys.toList().length,
              itemBuilder: (ctx, index) =>
                  ExpensesByDateList(state: state, index: index)),
        ),
      ),
    );
  }
}

//LEARN HOW TO IMPLEMENT CUSTOM SCROLL VIEW FOR NESTED SCROLL VIEW WITH THE SLIVERS
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
    final orderedKeys = widget.state.orderedDate;
    final keyIndex = widget.index;
    final expenses = widget.state.expenses;
    final List<Expense> expensesOfDate = expenses[orderedKeys[keyIndex]]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: [
            GestureDetector(
                onTap: changeShowStatus, child: Text(orderedKeys[keyIndex])),
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
                        key: UniqueKey(),
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
        ),
      ),
    );
  }
}
