import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/presentation/widgets/expenses/main_scroll_notification.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/presentation/widgets/slivers/sliver_date_flexible_app_bar.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/show_expenses_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/months_parser.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class NewExpenseList extends StatefulWidget {
  const NewExpenseList({super.key});

  @override
  State<NewExpenseList> createState() => _NewExpenseListState();
}

class _NewExpenseListState extends State<NewExpenseList> {
  final scrollController = AutoScrollController();
  final dateController = TextEditingController();
  late ExpenseProvider expState;
  late CategoriesProvider categoriesState;
  late UserProvider userProvider;
  String? selectedDate;
  String? selectedDateForExpenses;

  void _scrollControllerHandler(
      ExpenseProvider state, AutoScrollController controller) async {
    if (state.blockInfiniteScroll | state.blockFunction) return;
    final maxScrollExtent = controller.position.maxScrollExtent;
    final pixels = controller.position.pixels;
    final viewPort = controller.position.viewportDimension;

    if (pixels >= maxScrollExtent * 0.8) {
      if (kDebugMode) {
        print(
            '\nMaxScrollExtent: $maxScrollExtent\nPixels: $pixels\nViewPort: $viewPort');
      }
      await state.getByScroll();
    }
  }

  @override
  void initState() {
    super.initState();
    expState = context.read<ExpenseProvider>();
    categoriesState = context.read<CategoriesProvider>();
    userProvider = context.read<UserProvider>();
    final now = DateTime.now();
    switch (expState.dateType) {
      case DateType.day:
        selectedDate = toDDMMYYYY(now);
        selectedDateForExpenses = MyDateFormatter.toYYYYMMdd(now);
        expState.getByDate(
            selectedDateForExpenses!, 0, userProvider.loggedUser!.firebaseUID);
        break;
      case DateType.month:
        selectedDate = MyDateFormatter.dateByType(
            DateType.month, MyDateFormatter.toYYYYMMdd(now));
        selectedDateForExpenses = selectedDate;
        expState.getByMonth(months[now.month - 1].number, now.year,
            userProvider.loggedUser!.firebaseUID);
        break;
      case DateType.year:
        selectedDate = MyDateFormatter.dateByType(
            DateType.year, MyDateFormatter.toYYYYMMdd(now));
        selectedDateForExpenses = selectedDate;

        break;
      case DateType.week:
        selectedDate = MyDateFormatter.toFormat('dd/MM/yyyy',now);
        selectedDateForExpenses = selectedDate;
        break;
    }
    print('Init state on main page');
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    scrollController.addListener(
        () => _scrollControllerHandler(expState, scrollController));
    dateController.text = selectedDate ?? toDDMMYYYY(DateTime.now());
    print('Build Main Page');
    return MainScrollNotification(
        controller: scrollController,
        child: SliverDateFlexibleAppBar(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                //DATE SELECTOR
                
                buildWeekDatePicker(
                    selectedDate != null
                        ? MyDateFormatter.fromFormat(
                            'dd/MM/yyyy', selectedDate!)
                        : DateTime.now(),
                    DateTime.parse('1900-01-01'),
                    DateTime.now(), (value) {
                  print('Start: ${value.start} \nEnd:${value.end}');
                ;
                  setState(() {
                    selectedDate = toDDMMYYYY(value.start);
                  });
                }),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      readOnly: true,
                      controller: dateController,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black))),
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    IconButton(
                        onPressed: () async {
                          final firebaseUID = context
                              .read<UserProvider>()
                              .loggedUser!
                              .firebaseUID;
                          if (expState.dateType == DateType.week) {
                            final date = buildWeekDatePicker(
                                DateTime.now(),
                                DateTime.parse('1900-01-01'),
                                DateTime.now(), (value) {
                              print(
                                  'dateperiod: ${value.start} \n${value.end}');
                            });
                            showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                      child: date,
                                    ));
                            return;
                          }
                          if (expState.dateType == DateType.month) {
                            final date = await showMonthYearPicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.parse('1900-01-01'),
                                lastDate: DateTime.now());

                            if (date != null) {
                              int monthNumber = date.month - 1;
                              Month month = months[monthNumber];
                              print(month);
                              selectedDate = MyDateFormatter.dateByType(
                                  DateType.month,
                                  MyDateFormatter.toYYYYMMdd(date));
                              selectedDateForExpenses =
                                  MyDateFormatter.dateByType(DateType.month,
                                      MyDateFormatter.toYYYYMMdd(date));

                              print('Selected Date: $selectedDate');

                              if (expState.expenses[selectedDateForExpenses] ==
                                      null &&
                                  selectedDateForExpenses != null) {
                                await expState.getByMonth(
                                    month.number, date.year, firebaseUID);
                              }
                              setState(() {});
                            }

                            return;
                          }
                          final date = await showDatePicker(
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: selectedDate != null
                                  ? MyDateFormatter.fromFormat(
                                      'dd/MM/yyyy', selectedDate!)
                                  : DateTime.now(),
                              firstDate: DateTime.parse('1900-01-01'),
                              lastDate: DateTime.now());
                          print(date);
                          print(context.read<ExpenseProvider>().expenses);
                          if (date != null) {
                            selectedDate = toDDMMYYYY(date);
                            selectedDateForExpenses =
                                MyDateFormatter.toYYYYMMdd(date);
                            print(selectedDate);
                            print(selectedDateForExpenses);
                          }
                          if (expState.expenses[selectedDateForExpenses] ==
                                  null &&
                              selectedDateForExpenses != null) {
                            await expState.getByDate(
                                selectedDateForExpenses!, 0, firebaseUID);
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.calendar_month_outlined, size: 40))
                  ],
                ),

                //Box
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(8.0),
                  width: width,
                  height: 200,
                  color: Colors.greenAccent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gastos'),
                          Text('${totalExpenseOfDatePrice()} €')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Número de gastos'),
                          Text('${totalExpensesOfDateLength()}')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mayor gasto en'),
                          Text('${categoryWithMoreExpenses()}')
                        ],
                      ),
                      Visibility(
                          visible: showAddExpenseToDate(),
                          child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Añadir gasto a $selectedDate')))
                    ],
                  ),
                ),

                Consumer<ExpenseProvider>(
                  builder: (ctx, state, _) => Text(
                    state.dateType == DateType.month
                        ? selectedDate!
                        : toNamedMonth(
                            selectedDate ?? toDDMMYYYY(DateTime.now()),
                          ),
                    textAlign: TextAlign.center,
                  ),
                ),

                //Lista
                Consumer<ExpenseProvider>(
                  builder: (ctx, state, _) => state.loading
                      ? const Loading()
                      : ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: state.expenses[selectedDateForExpenses] ==
                                  null
                              ? 0
                              : state.expenses[selectedDateForExpenses]!.length,
                          itemBuilder: (context, index) => ExpenseTile(
                              state: state,
                              date: selectedDateForExpenses!,
                              expense: state
                                  .expenses[selectedDateForExpenses]![index],
                              position: index),
                        ),
                )
              ],
            ),
          ),
        ));
  }

  String toDDMMYYYY(DateTime date) =>
      MyDateFormatter.toFormat('dd/MM/yyyy', date);
  String toNamedMonth(String ddmmyyyy) {
    DateTime date = MyDateFormatter.fromFormat('dd/MM/yyyy', ddmmyyyy);
    return DateFormat.yMMMEd('es').format(date);
  }

  num totalExpenseOfDatePrice() {
    if (selectedDateForExpenses == null) return 0.0;

    final expenses = expState.expenses[selectedDateForExpenses];
    if (expenses == null) return 0.0;
    return expenses.fold<num>(
        0.0, (previousValue, element) => previousValue + element.price);
  }

  int totalExpensesOfDateLength() {
    if (selectedDateForExpenses == null) return 0;
    if (expState.expenses[selectedDateForExpenses] == null) return 0;
    return expState.expenses[selectedDateForExpenses]!.length;
  }

  String categoryWithMoreExpenses() {
    if (selectedDateForExpenses == null) return '';
    Map<String, num> categoriesWithNumberOfExpenses = {};
    final expenses = expState.expenses[selectedDateForExpenses];
    if (expenses == null) return '';
    int length = expenses.length;
    for (int i = 0; i < length; i++) {
      final expense = expenses[i];
      if (categoriesWithNumberOfExpenses.containsKey(expense.category)) {
        num reps =
            categoriesWithNumberOfExpenses[expense.category]! + expense.price;
        categoriesWithNumberOfExpenses.update(
            expense.category, (value) => reps);
      } else {
        categoriesWithNumberOfExpenses.addAll({expense.category: 1});
      }
    }
    String categoryWithMoreExpenses = '';
    int max = 0;
    categoriesWithNumberOfExpenses.forEach((key, value) {
      if (value > max) {
        categoryWithMoreExpenses = key;
      }
    });
    print(categoriesState.categories);

    try {
      return categoriesState.categories
          .firstWhere(
            (element) => element.id == categoryWithMoreExpenses,
          )
          .name;
    } catch (err) {
      return '';
    }
  }

  bool showAddExpenseToDate() {
    if (selectedDate == null) return false;
    return selectedDate != toDDMMYYYY(DateTime.now());
  }

  // Create week date picker with passed parameters
  Widget buildWeekDatePicker(DateTime selectedDate, DateTime firstAllowedDate,
      DateTime lastAllowedDate, ValueChanged<DatePeriod> onNewSelected) {
    // add some colors to default settings
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(10.0), bottomEnd: Radius.circular(10.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(10.0),
            bottomStart: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration:
          BoxDecoration(color: Colors.yellow, shape: BoxShape.rectangle),
    );

    return WeekPicker(
        selectedDate: selectedDate,
        onChanged: onNewSelected,
        firstDate: firstAllowedDate,
        lastDate: lastAllowedDate,
        datePickerStyles: styles);
  }
}
