import 'package:flutter/foundation.dart' as f;
import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/common_expense_dialogs.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_info_dialog.dart';
import 'package:gastos/presentation/widgets/expenses/main_scroll_notification.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/presentation/widgets/slivers/sliver_date_flexible_app_bar.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/providers/show_expenses_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class IndividualExpensesPage extends StatefulWidget {
  const IndividualExpensesPage({super.key});
  @override
  State<IndividualExpensesPage> createState() => _IndividualExpensesPageState();
}

class _IndividualExpensesPageState extends State<IndividualExpensesPage> {
  final scrollController = AutoScrollController();
  void _scrollControllerHandler(
      ExpenseProvider state, AutoScrollController controller) async {
    if (state.blockInfiniteScroll | state.blockFunction) return;
    final maxScrollExtent = controller.position.maxScrollExtent;
    final pixels = controller.position.pixels;
    final viewPort = controller.position.viewportDimension;

    if (pixels >= maxScrollExtent * 0.8) {
      if (f.kDebugMode) {
        print(
            '\nMaxScrollExtent: $maxScrollExtent\nPixels: $pixels\nViewPort: $viewPort');
      }
      await state.getByScroll();
    }
  }

  @override
  void initState() {
    super.initState();
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
    final expState = context.read<ExpenseProvider>();
    final categoriesState = context.read<CategoriesProvider>();
    final userProvider = context.read<UserProvider>();
    scrollController.addListener(
        () => _scrollControllerHandler(expState, scrollController));
    print('Build Individual Expenses Page');
    
    return MainScrollNotification(
      controller: scrollController,
      child: Stack(
        children: [
          Consumer<ExpenseProvider>(builder: (ctx, state, _) {
            return state.loading
                ? const Loading()
                : Center(
                    child: SizedBox(
                      width: width * 0.995,
                      child: RefreshIndicator(
                        triggerMode: RefreshIndicatorTriggerMode.anywhere,
                        color: Colors.red,
                        backgroundColor: Colors.black,
                        onRefresh: () => state
                            .refreshData()
                            .then((value) => categoriesState.refreshData()),
                        child: ChangeNotifierProvider(
                          create: (ctx) => ShowExpensesProvider(),
                          child: SliverDateFlexibleAppBar(
                            controller: scrollController,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                //controller: scrollController,
                                itemCount: state.individualExpenses.keys.toList().length,
                                itemBuilder: (ctx, index) =>
                                    IndividualExpensesByDateList(
                                        state: state, index: index)),
                          ),
                        ),
                      ),
                    ),
                  );
          }),
          _FloatingButtonJumpUp(scrollController: scrollController),
          _FloatingButtonJumpDown(scrollController: scrollController)
        ],
      ),
    );
  }
}

class _FloatingButtonJumpDown extends StatelessWidget {
  const _FloatingButtonJumpDown({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final AutoScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 2,
      child: Consumer<JumpButtonsProvider>(
        builder: (c, state, _) => Visibility(
          visible: state.show,
          child: IconButton(
              onPressed: () {
                scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeIn);
              },
              icon: const Icon(Icons.keyboard_double_arrow_down)),
        ),
      ),
    );
  }
}

class _FloatingButtonJumpUp extends StatelessWidget {
  const _FloatingButtonJumpUp({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final AutoScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<JumpButtonsProvider>(
      builder: (c, state, _) => Visibility(
        visible: state.show,
        child: IconButton(
            onPressed: () {
              //jumper(scrollController, 0.0);
              scrollController.animateTo(0,
                  duration: const Duration(seconds: 8),
                  curve: Curves.easeInCubic);
            },
            icon: const Icon(Icons.keyboard_double_arrow_up)),
      ),
    );
  }
}

class IndividualExpensesByDateList extends StatefulWidget {
  const IndividualExpensesByDateList(
      {Key? key, required this.state, required this.index})
      : super(key: key);
  final ExpenseProvider state;
  final int index;

  @override
  State<IndividualExpensesByDateList> createState() =>
      _IndividualExpensesByDateListState();
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
class _IndividualExpensesByDateListState
    extends State<IndividualExpensesByDateList> {
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
    final orderedKeys = widget.state.orderedDateIndividualExpenses;
    final keyIndex = widget.index;
    final expenses = widget.state.individualExpenses;
    final isLastDate = keyIndex == expenses.keys.length - 1;
    //from the orderedKeys (dates) we fetch a date using the keyIndex we are passing to this class 
    //Then, using this date we can access the list of expenses for that date. 
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
                        numberOfExpenses: expensesOfDate.length,
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
                            CommonExpenseDialog(date: orderedKeys[keyIndex]));
                  },
                  child: Text('Añadir gasto a ${getDate()}')),
          ],
        ),
      ),
    );
  }

  String getDate() {
    String date = widget.state.orderedDateIndividualExpenses[widget.index];
    if (widget.state.dateType == DateType.day) {
      final parsedDate = MyDateFormatter.fromYYYYMMdd(date);
      date = MyDateFormatter.toFormat('dd-MM-yyyy', parsedDate);
    }
    return date;
  }

  double getTotalOfDate() {
    String date = widget.state.orderedDateIndividualExpenses[widget.index];
    List<Expense> exps = widget.state.individualExpenses[date]!;
    double totalOfDate = 0.0;
    for (final e in exps) {
      totalOfDate += e.price;
    }
    return totalOfDate;
  }

  bool isCurrentDate() {
    final selectedDate = widget.state.orderedDateIndividualExpenses[widget.index];
    final createdDate = widget.state.individualExpenses[selectedDate]!.first.createdDate;
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
          
          final expense = expensesOfDate[i];

          return IndividualExpenseTile(
              key: Key('Date-${expense.id}'),
              state: state,
              date: date,
              expense: expense,
              position: i);
        }));
  }
}

class IndividualExpenseTile extends StatefulWidget {
  const IndividualExpenseTile(
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
  State<IndividualExpenseTile> createState() => _IndividualExpenseTileState();
}

class _IndividualExpenseTileState extends State<IndividualExpenseTile> {
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
          category: exp.category,
          price: exp.price,
          description: exp.description);
    });
  }

  void showOptionDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return IndividualExpenseOptionsDialog(
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
    final categories = context.read<CategoriesProvider>().categories;
    Category? cat;
    Color? color;
    Color textColor = Colors.black;
    try {
      cat = categories.firstWhere((element) => element.id == expense.category);
      color = Color.fromARGB(190, cat.r, cat.g, cat.b);
      if (!ColorComputation.colorsMatch(color)) {
        textColor = Colors.white;
      }
    } catch (err) {}

    return Container(
      key: Key(widget.expense.id),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        isThreeLine: true,
        onLongPress: showOptionDialog,
        contentPadding: const EdgeInsets.all(8),
        tileColor: color ??
            Colors
                .white, //isEven ? Colors.blue.shade100 : Colors.orange.shade100,
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 2.8,
                color: color == null
                    ? const Color(0xFF000000)
                    : ColorComputation.getShade(
                        color), //isEven ? Colors.blue.shade500 : Colors.orange.shade500,
                strokeAlign: 0.0),
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
          expense.description + getCategoryName(cat),
          style: GoogleFonts.raleway(fontSize: 16, color: textColor),
        ),
        subtitle: Text(
          expense.person,
          maxLines: 2,
          style: GoogleFonts.raleway(fontSize: 16, color: textColor),
        ),
        trailing: SizedBox(
          width: width * 0.2,
          child: IconButton(
              onPressed: showOptionDialog,
              icon: Icon(
                Icons.more_vert,
                color: textColor,
              )),
        ),
      ),
    );
  }

  String getCategoryName(Category? cat) {
    if (cat == null) return '';
    return ' (${cat.name})';
  }
}

class ColorComputation {
  static const double _shadeFactor = 0.45;
  static const int _brightnessLimit = 125;
  static const int _colorDifferenceLimit = 500;
  static const Color _textColor = Colors.black;

  static bool colorsMatch(Color color) {
    final brightness = brightnessDifference(color);
    final colorDiff = colorDifference(color);
    return brightness && colorDiff;
  }

  static bool brightnessDifference(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    final r2 = _textColor.red;
    final g2 = _textColor.green;
    final b2 = _textColor.blue;

    final backgroundIndex = (299 * r + 587 * g + 114 * b) / 1000;
    final textIndex = (299 * r2 + 587 * g2 + 114 * b2) / 1000;
    final result = (textIndex - backgroundIndex).abs();
    print('Brightness diff: $result');
    return result >= _brightnessLimit;
  }

  static bool colorDifference(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    final r2 = _textColor.red;
    final g2 = _textColor.green;
    final b2 = _textColor.blue;

    final result = (r - r2).abs() + (g - g2).abs() + (b - b2).abs();
    print('Color diff: $result');
    return result >= _colorDifferenceLimit;
  }

  static Color getShade(Color color) {
    final r = color.red * (1 - _shadeFactor);
    final g = color.green * (1 - _shadeFactor);
    final b = color.blue * (1 - _shadeFactor);
    return Color.fromRGBO(r.toInt(), g.toInt(), b.toInt(), 1);
  }
}

class IndividualExpenseOptionsDialog extends StatelessWidget {
  const IndividualExpenseOptionsDialog(
      {Key? key,
      required this.state,
      required this.index,
      required this.date,
      required this.updateHandler,
      required this.expense})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final int index;
  final Function(Expense) updateHandler;
  final Expense expense;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      alignment: Alignment.center,
      title: const Text('Selecciona la acción que desees'),
      children: [
        TextButton.icon(
            onPressed: () {
              if (state.loading) return;
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (ctx) => CommonExpenseDialog(
                      expense: expense, updateHandler: updateHandler));
            },
            icon: const Icon(
              Icons.update,
              color: Colors.blue,
            ),
            label: const Text('Actualizar gasto',
                style: TextStyle(color: Colors.blue))),
        TextButton.icon(
            onPressed: () => {
                  state.remove(expense: state.expenses[date]![index],individual: true),
                  Navigator.of(context).pop()
                },
            icon: const Icon(Icons.update, color: Colors.blue),
            label: const Text('Eliminar gasto',
                style: TextStyle(color: Colors.blue))),
        TextButton.icon(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: Navigator.of(context).pop,
            label: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.red),
            )),
      ],
    );
  }
}
