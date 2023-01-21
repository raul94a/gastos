import 'dart:isolate';


import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/expenses/expense_tile.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class JumpComputation {
  const JumpComputation({required this.v, required this.c});
  final double v;
  final AutoScrollController c;
}

class ExpenseList extends StatefulWidget {
  const ExpenseList({
    Key? key,
  }) : super(key: key);
  static void entryPoint(Map<String, dynamic> context) {
    // Calling initialize from the entry point with the context is
    // required if communication is desired. It returns a messenger which
    // allows listening and sending information to the main isolate.
    final messenger = HandledIsolate.initialize(context);

    // Triggered every time data is received from the main isolate.
    messenger.listen((msg) async {
      // Use a plugin to get some new value to send back to the main isolate.
      ;
      print(msg + 'fadfdaf');
      messenger.send(0.0);
    });
  }

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final scrollController = AutoScrollController();
  void _scrollControllerHandler(
      ExpenseProvider state, AutoScrollController controller) async {
    if (state.blockInfiniteScroll | state.blockFunction) return;
    final maxScrollExtent = controller.position.maxScrollExtent;
    final pixels = controller.position.pixels;
    final viewPort = controller.position.viewportDimension;

    if (pixels >= maxScrollExtent * 0.8) {
      print(
          '\nMaxScrollExtent: $maxScrollExtent\nPixels: $pixels\nViewPort: $viewPort');
      await state.getByScroll();
    }
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
    final jumpProvider = context.read<JumpButtonsProvider>();
    scrollController.addListener(
        () => _scrollControllerHandler(expState, scrollController));
    print('rebuild');
    return NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        jumpProvider.showButtons();
        return true;
      },
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          if (scrollController.position.pixels <=
              scrollController.position.minScrollExtent) {
            jumpProvider.hideButtons();
          }

          return true;
        },
        child: Stack(
          children: [
            Consumer<ExpenseProvider>(
              builder: (ctx, state, _) => Center(
                child: SizedBox(
                  width: width * 0.995,
                  child: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    color: Colors.red,
                    backgroundColor: Colors.black,
                    onRefresh: () => state.refreshData(),
                    child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: scrollController,
                        itemCount: state.expenses.keys.toList().length,
                        itemBuilder: (ctx, index) =>
                            ExpensesByDateList(state: state, index: index)),
                  ),
                ),
              ),
            ),
            Consumer<JumpButtonsProvider>(
              builder: (c, state, _) => Visibility(
                visible: state.show,
                child: IconButton(
                    onPressed: () {
                      //jumper(scrollController, 0.0);
                      scrollController.animateTo(0,
                          duration: const Duration(seconds: 8),
                          curve: Curves.easeInCubic);
                    },
                    icon: Icon(Icons.keyboard_double_arrow_up)),
              ),
            ),
            Positioned(
              bottom: 2,
              child: Consumer<JumpButtonsProvider>(
                builder: (c, state, _) => Visibility(
                  visible: state.show,
                  child: IconButton(
                      onPressed: () {
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(seconds: 8),
                            curve: Curves.easeIn);
                      },
                      icon: Icon(Icons.keyboard_double_arrow_down)),
                ),
              ),
            )
          ],
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
    final List<Expense> expensesOfDate = expenses[orderedKeys[keyIndex]]!;
    String titleDate = orderedKeys[keyIndex]; 
    
    if(context.read<ExpenseProvider>().preferences.getDateType() == DateType.day){
      final date = MyDateFormatter.fromYYYYMMdd(orderedKeys[keyIndex]);
      titleDate = MyDateFormatter.toFormat('dd-MM-yyyy', date);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(titleDate,
                    style: GoogleFonts.yujiBoku(fontSize: 24.2)),
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
