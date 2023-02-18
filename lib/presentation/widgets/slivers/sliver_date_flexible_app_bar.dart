import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/scroll_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SliverDateFlexibleAppBar extends StatefulWidget {
  const SliverDateFlexibleAppBar(
      {Key? key,
      required this.child,
      required this.controller,
      this.personalExpenses = false})
      : super(key: key);
  final Widget child;
  final ScrollController controller;
  final bool personalExpenses;

  @override
  State<SliverDateFlexibleAppBar> createState() =>
      _SliverDateFlexibleAppBarState();
}

class _SliverDateFlexibleAppBarState extends State<SliverDateFlexibleAppBar> {
  //constants

  static const _logoSize = 100.0;

  static const _titleSize = 30.0;
  static const _textColor = Colors.black;
  static const _titleColor = Colors.white;

  static const _fontSize = 18.2;

  static const _sliverShapeBorderRadius = 3.0;
  static const _sliverShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_sliverShapeBorderRadius),
          bottomRight: Radius.circular(_sliverShapeBorderRadius)));

  final _infoBorderRadius = BorderRadius.circular(9.0);

  static const _logo = 'assets/treasure.svg';

  late SelectedDateProvider selectedDateProvider;
  late ExpenseProvider expenseProvider;
  late CategoriesProvider categoriesProvider;

  int initialIndexByDateType(DateType dateType) {
    switch (dateType) {
      case DateType.day:
        return 0;
      case DateType.month:
        return 2;
      case DateType.year:
        return 3;
      case DateType.week:
        return 1;
    }
  }

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

    final containerTextColor = Theme.of(context).textTheme.displayLarge!.color;
    final dateType = expenseProvider.dateType;
    return DefaultTabController(
      initialIndex: initialIndexByDateType(dateType),
      length: 4,
      child: CustomScrollView(
        controller: widget.controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.indigo,
            shape: _sliverShape,
            automaticallyImplyLeading: false,
            expandedHeight: size.height * 0.38,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              background: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0)
                        .copyWith(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget.personalExpenses
                                      ? 'Gastos Personales'
                                      : 'Gastos Comunes',
                                  style: GoogleFonts.robotoSerif(
                                      fontSize: _titleSize,
                                      color: _titleColor)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  widget.personalExpenses
                                      ? 'Controla donde gastas tu dinero. Ahorra.'
                                      : 'Optimiza los gastos de tu grupo',
                                  maxLines: 2,
                                  style: GoogleFonts.robotoSerif(
                                      fontSize: _titleSize / 2.5,
                                      color: _titleColor)),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          _logo,
                          height: _logoSize,
                          width: _logoSize,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                      padding: const EdgeInsets.all(8.0),
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: _infoBorderRadius),

                      //color: Colors.greenAccent,
                      child: Consumer<SelectedDateProvider>(
                        builder: (ctx, _, __) => Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Fecha',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor)),
                                Text(selectedDateProvider.selectedDate,
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Gastos',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor)),
                                Text(
                                    '${controller.totalExpenseOfDatePrice().toStringAsFixed(2)} €',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Número de gastos',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor)),
                                Text(
                                    '${controller.totalExpensesOfDateLength()}',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Mayor gasto en',
                                    style: GoogleFonts.raleway(
                                        fontSize: _fontSize,
                                        color: containerTextColor)),
                                Text(
                                  controller.categoryWithMoreExpenses(),
                                  style: GoogleFonts.raleway(
                                      fontSize: _fontSize,
                                      color: containerTextColor),
                                )
                              ],
                            ),
                            Visibility(
                                visible: false,
                                child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                        'Añadir gasto a ${selectedDateProvider.selectedDate}',
                                        style: GoogleFonts.raleway(
                                            fontSize: _fontSize,
                                            color: containerTextColor))))
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
                tabs: [
                  Consumer<ScrollProvider>(
                    builder: (ctx, state, _) => Visibility(
                      visible: !state.isScrolling,
                      child: Tab(
                        text: 'Día',
                      ),
                    ),
                  ),
                  Consumer<ScrollProvider>(
                    builder: (ctx, state, _) => Visibility(
                      visible: !state.isScrolling,
                      child: Tab(
                        text: 'Semana',
                      ),
                    ),
                  ),
                  Consumer<ScrollProvider>(
                    builder: (ctx, state, _) => Visibility(
                      visible: !state.isScrolling,
                      child: Tab(
                        text: 'Mes',
                      ),
                    ),
                  ),
                  Consumer<ScrollProvider>(
                    builder: (ctx, state, _) => Visibility(
                      visible: !state.isScrolling,
                      child: Tab(
                        text: 'Año',
                      ),
                    ),
                  ),
                ]),
          ),
          SliverList(delegate: SliverChildListDelegate.fixed([widget.child]))
          //This results in rebuilding the entire page, so for this case is not good
          //  SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => child))
        ],
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
        categoriesWithNumberOfExpenses
            .addAll({expense.category: expense.price});
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
