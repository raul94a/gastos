// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastos/logic/expenses_bloc.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/presentation/widgets/expenses/main_scroll_notification.dart';
import 'package:gastos/presentation/widgets/slivers/sliver_date_flexible_app_bar.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  late SelectedDateProvider selectedDateState;
  String? selectedDate;
  String? selectedDateForExpenses;
  bool loading = false;

  void changeLoadingStatus() => setState(() => loading = !loading);

  void _scrollControllerHandler(
      ExpenseProvider state, AutoScrollController controller) async {
    return;
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
    selectedDateState = context.read<SelectedDateProvider>();
    //changeLoadingStatus();
    ExpensesBloc(context: context)
        .fetchExpensesOnInit(userUID: userProvider.loggedUser!.firebaseUID);
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
        child: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          color: Colors.red,
          backgroundColor: Colors.black,
          onRefresh: () async => await expState.refreshData().then((value) =>
              categoriesState.refreshData().then((value) => userProvider
                  .refreshData()
                  .then((value) => selectedDateState.notify()))),
          child: SliverDateFlexibleAppBar(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _DateSelector(
                      dateController: dateController,
                      selectedDateState: selectedDateState),

                  //Lista
                  _ExpensesList(expState: expState)
                ],
              ),
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
}

class _ExpensesList extends StatelessWidget {
  const _ExpensesList({
    super.key,
    required this.expState,
  });

  final ExpenseProvider expState;
  static const fontSize = 18.0;
  static const logo = 'assets/sleep.svg';
  static const notFoundExpensesText =
      'Parece que no hay gastos para la fecha seleccionada';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final logoWidth = width * 0.4;
    return Consumer<SelectedDateProvider>(builder: (ctx, state, _) {
      final expensesOfDate = expState.expenses[state.selectedDateForExpenses];
      bool isExpensesOfDateNull = expensesOfDate == null;
      if (isExpensesOfDateNull) {
        return _NoExpensesFound(
            logo: logo,
            logoWidth: logoWidth,
            width: width,
            notFoundExpensesText: notFoundExpensesText);
      }
      return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: expensesOfDate.length,
        itemBuilder: (context, index) => ExpenseTile(
            key: UniqueKey(),
            state: expState,
            date: state.selectedDateForExpenses,
            expense: expState.expenses[state.selectedDateForExpenses]![index],
            position: index),
      );
    });
  }
}

class _NoExpensesFound extends StatelessWidget {
  const _NoExpensesFound({
    super.key,
    required this.logo,
    required this.logoWidth,
    required this.width,
    required this.notFoundExpensesText,
  });

  final String logo;
  final double logoWidth;
  final double width;
  final String notFoundExpensesText;
  static const spaceHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: spaceHeight,
        ),
        Center(
          child: SvgPicture.asset(
            logo,
            width: logoWidth,
            height: logoWidth,
          ),
        ),
        const SizedBox(
          height: spaceHeight,
        ),
        SizedBox(
            width: width * 0.8,
            child: Center(
              child: Text(
                notFoundExpensesText,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ))
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    super.key,
    required this.dateController,
    required this.selectedDateState,
  });

  final TextEditingController dateController;
  final SelectedDateProvider selectedDateState;
  static const fontSize = 18.5;
  @override
  Widget build(BuildContext context) {
    const underlineInputBorder = UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black));
    return Row(
      children: [
        Consumer<SelectedDateProvider>(builder: (ctx, state, _) {
          dateController.text = state.selectedDateForExpenses;
          return Expanded(
              child: TextField(
            readOnly: true,
            style: GoogleFonts.raleway(fontSize: fontSize),
            controller: dateController,
            decoration: InputDecoration(
                enabledBorder: underlineInputBorder,
                disabledBorder: underlineInputBorder,
                border: underlineInputBorder),
          ));
        }),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: () async {
              final firebaseUID =
                  context.read<UserProvider>().loggedUser!.firebaseUID;
              final expenseBloc = ExpensesBloc(context: context);
              expenseBloc.fetchExpenses(userUID: firebaseUID);
              dateController.text = selectedDateState.selectedDateForExpenses;
            },
            icon: Icon(Icons.calendar_month_outlined, size: 40))
      ],
    );
  }
}
