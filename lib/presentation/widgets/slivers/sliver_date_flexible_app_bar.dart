import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:provider/provider.dart';

class SliverDateFlexibleAppBar extends StatefulWidget {
  const SliverDateFlexibleAppBar(
      {Key? key, required this.child, required this.controller})
      : super(key: key);
  final Widget child;
  final ScrollController controller;

  @override
  State<SliverDateFlexibleAppBar> createState() =>
      _SliverDateFlexibleAppBarState();
}

class _SliverDateFlexibleAppBarState extends State<SliverDateFlexibleAppBar> {
  late SelectedDateProvider selectedDateProvider;
  late ExpenseProvider expenseProvider;
  late CategoriesProvider categoriesProvider;

  @override
  void initState() {
    super.initState();
    selectedDateProvider = context.read<SelectedDateProvider>();
    expenseProvider = context.read<ExpenseProvider>();
    categoriesProvider = context.read<CategoriesProvider>();
  }

  @override
  Widget build(BuildContext context) {
    print('Adapting SliveDateFlexible');
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final controller = SliverDateAppBarController(
        selectedDateProvider: selectedDateProvider,
        expenseProvider: expenseProvider,
        categoriesProvider: categoriesProvider);
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: CustomScrollView(
          controller: widget.controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5))),
              automaticallyImplyLeading: false,
              expandedHeight: size.height * 0.25,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground],
                background: Column(
                  children: [
                    Text('Mis gastos'),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(8.0),
                        width: width,

                        //color: Colors.greenAccent,
                        child: Consumer<SelectedDateProvider>(
                          builder: (ctx, _, __) => Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gastos'),
                                  Text(
                                      '${controller.totalExpenseOfDatePrice()} €')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Número de gastos'),
                                  Text(
                                      '${controller.totalExpensesOfDateLength()}')
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Mayor gasto en'),
                                  Text(controller.categoryWithMoreExpenses())
                                ],
                              ),
                              Visibility(
                                  visible: false,
                                  child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text(
                                          'Añadir gasto a ${selectedDateProvider.selectedDate}')))
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
              bottom: TabBar(
                  onTap: (a) => controller.changeDateType(a, context),
                  tabs: const [
                    Tab(
                      text: 'Día',
                    ),
                    Tab(
                      text: 'Semana',
                    ),
                    Tab(
                      text: 'Mes',
                    ),
                    Tab(
                      text: 'Año',
                    )
                  ]),
            ),
            SliverList(delegate: SliverChildListDelegate.fixed([widget.child]))
            //This results in rebuilding the entire page, so for this case is not good
            //  SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => child))
          ],
        ),
      ),
    );
  }
}

class SliverDateAppBarController {
  const SliverDateAppBarController(
      {required this.selectedDateProvider,
      required this.expenseProvider,
      required this.categoriesProvider});

  final SelectedDateProvider selectedDateProvider;
  final ExpenseProvider expenseProvider;
  final CategoriesProvider categoriesProvider;

  void changeDateType(int value, BuildContext context) {
    print(value);
    switch (value) {
      case 1:
        const type = DateType.week;
        _sortBy(type, context);
        break;
      case 2:
        const type = DateType.month;
        _sortBy(type, context);
        break;
      case 3:
        const type = DateType.year;
        _sortBy(type, context);
        break;
      default:
        const type = DateType.day;
        _sortBy(type, context);
        break;
    }
  }

  Future<void> _sortBy(DateType type, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    expenseProvider.preferences.saveDateType(type);
    print(type);
    await expenseProvider.getByDateType(firebaseUID: uid, type: type);
    selectedDateProvider.setSelectedDates(type);
  }

  num totalExpenseOfDatePrice() {
    String selectedDateForExpenses =
        selectedDateProvider.selectedDateForExpenses;

    final expenses = expenseProvider.expenses[selectedDateForExpenses];
    if (expenses == null) return 0.0;
    return expenses.fold<num>(
        0.0, (previousValue, element) => previousValue + element.price);
  }

  int totalExpensesOfDateLength() {
    String selectedDateForExpenses =
        selectedDateProvider.selectedDateForExpenses;

    if (expenseProvider.expenses[selectedDateForExpenses] == null) return 0;
    return expenseProvider.expenses[selectedDateForExpenses]!.length;
  }

  String categoryWithMoreExpenses() {
    String selectedDateForExpenses =
        selectedDateProvider.selectedDateForExpenses;

    Map<String, num> categoriesWithNumberOfExpenses = {};
    final expenses = expenseProvider.expenses[selectedDateForExpenses];
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
        categoriesWithNumberOfExpenses.addAll({expense.category: expense.price});
      }
    }
    String categoryWithMoreExpenses = '';
    num max = 0;
    categoriesWithNumberOfExpenses.forEach((key, value) {
      if (value > max) {
        categoryWithMoreExpenses = key;
        max = value;
      }
    });

    try {
      return categoriesProvider.categories
          .firstWhere(
            (element) => element.id == categoryWithMoreExpenses,
          )
          .name;
    } catch (err) {
      return '';
    }
  }
}
