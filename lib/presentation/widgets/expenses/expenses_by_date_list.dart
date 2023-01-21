import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_info_dialog.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/show_expenses_provider.dart';
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

///Handling the visibility of the first five items has required to use a provider (ShowExpensesProvider)
///As the show variable controls the expenses list of a date, when scrolling back to the top, the first 5 records
///where always shown, even though when they were made invisible.
///This was managed in the init state in that way:
///```dart
/// bool show = false;
/// @override
/// void initState(){
///   super.initState();
///   show = widget.index <= 5 ? true : false
/// }
///
///```
///For the correct managing of invisibility from the five first results, it was required to split the ExpenseTileListView in
///Two ListViews, one of them rendering only when the widget.index value was 5 or less, and the other with the rest of the Items.
///The first one is managed through the provider. The last one is controlled by the show state variable
///
class _ExpensesByDateListState extends State<ExpensesByDateList> {
  bool show = false;
  bool lastShowStatus = true;
  bool showFirsts = true;
  @override
  void initState() {
    super.initState();

    if (widget.index <= 5) {
      context.read<ShowExpensesProvider>().initStates(widget.index);
      showFirsts = context.read<ShowExpensesProvider>().getState(widget.index);
    }
  }

  void changeShowStatus(int index, ShowExpensesProvider showState) {
    setState(() {
      if (index <= 5) {
        showState.updateState(index, !showFirsts);
        showFirsts = !showFirsts;
      } else {
        show = !show;
      }
    });
  }

  bool showExpenses(ShowExpensesProvider showProvider) {
    final index = widget.index;

    if (index > 5) {
      return show;
    }
    bool showFirstPositions = showProvider.getState(index);
    // print('INDEX: $index state: $showFirstPositions');
    return showFirstPositions;
  }

  @override
  Widget build(BuildContext context) {
    final showProvider = context.read<ShowExpensesProvider>();
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
    // print('Rebuilding for index ${widget.index}!');
    return Card(
      color: isCurrentDate() ? const Color.fromARGB(255, 210, 255, 236) : null,
      margin: EdgeInsets.only(
          top: 10, left: 5, right: 5, bottom: isLastDate ? 80 : 0),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            //Card Header (Date + Visibility handler button)
            GestureDetector(
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (ctx) => ExpenseInfoDialog(
                        dateTitle: titleDate,
                        numberOfExpenses: expenses.length,
                        total: getTotalOfDate()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(titleDate, style: GoogleFonts.yujiBoku(fontSize: 24.2)),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: () =>
                          changeShowStatus(widget.index, showProvider),
                      icon: Icon(showExpenses(showProvider)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined))
                ],
              ),
            ),
            //First five date items -> controlled by the ShowExpensesProvider
            if (widget.index <= 5)
              Consumer<ShowExpensesProvider>(
                builder: (ctx, state, _) => state.getState(widget.index)
                    ? _ExpenseTileListView(
                        expensesOfDate: expensesOfDate,
                        orderedKeys: orderedKeys,
                        keyIndex: keyIndex,
                        state: widget.state,
                      )
                    : const SizedBox.shrink(),
              )
            //Rest of Date Items
            else
              Visibility(
                visible: showExpenses(showProvider),
                child: _ExpenseTileListView(
                  expensesOfDate: expensesOfDate,
                  orderedKeys: orderedKeys,
                  keyIndex: keyIndex,
                  state: widget.state,
                ),
              ),

            //stats
            if (showExpenses(showProvider))
              Column(
                children: [
                  Text(
                      'Gastos de ${getDate()}: ${getTotalOfDate().toStringAsFixed(2)} €')
                ],
              ),
            //Add expense to Past Date
            if (!isCurrentDate() && showExpenses(showProvider))
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) =>
                            ExpenseDialog(date: orderedKeys[keyIndex]));
                  },
                  child: Text('Añadir gasto a ${getDate()}')),
          ],
        ),
      ),
    );
  }

  String getDate() {
    String date = widget.state.orderedDate[widget.index];
    if (widget.state.dateType == DateType.day) {
      final parsedDate = MyDateFormatter.fromYYYYMMdd(date);
      date = MyDateFormatter.toFormat('dd-MM-yyyy', parsedDate);
    }
    return date;
  }

  double getTotalOfDate() {
    String date = widget.state.orderedDate[widget.index];
    List<Expense> exps = widget.state.expenses[date]!;
    double totalOfDate = 0.0;
    for (final e in exps) {
      totalOfDate += e.price;
    }
    return totalOfDate;
  }

  bool isCurrentDate() {
    final selectedDate = widget.state.orderedDate[widget.index];
    final createdDate = widget.state.expenses[selectedDate]!.first.createdDate;
    final date = MyDateFormatter.toYYYYMMdd(createdDate);
    final today = MyDateFormatter.toYYYYMMdd(DateTime.now());
    final todayByType =
        MyDateFormatter.dateByType(widget.state.dateType, today);
    final dateByType = MyDateFormatter.dateByType(widget.state.dateType, date);
    return dateByType == todayByType;
  }
}

class _ExpenseTileListView extends StatelessWidget {
  const _ExpenseTileListView(
      {Key? key,
      required this.expensesOfDate,
      required this.orderedKeys,
      required this.keyIndex,
      required this.state})
      : super(key: key);

  final List<Expense> expensesOfDate;
  final List<String> orderedKeys;
  final int keyIndex;
  final ExpenseProvider state;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false, // shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expensesOfDate.length,
        itemBuilder: ((context, i) {
          final date = orderedKeys[keyIndex];
          final List<Expense> expenses = state.expenses[date]!;
          final expense = expenses[i];

          return ExpenseTile(
              key: Key('Date-${expense.id}'),
              state: state,
              date: date,
              expense: expense,
              position: i);
        }));
  }
}
