import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/expenses/expenses_by_date_list.dart';
import 'package:gastos/presentation/widgets/expenses/main_scroll_notification.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/presentation/widgets/slivers/sliver_date_flexible_app_bar.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/providers/show_expenses_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({
    Key? key,
  }) : super(key: key);

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
      if (kDebugMode) {
        print(
            '\nMaxScrollExtent: $maxScrollExtent\nPixels: $pixels\nViewPort: $viewPort');
      }
      await state.getByScroll();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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
    scrollController.addListener(
        () => _scrollControllerHandler(expState, scrollController));
    print('Build Main Page');
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
                        onRefresh: () => state.refreshData(),
                        child: ChangeNotifierProvider(
                          create: (ctx) => ShowExpensesProvider(),
                          child: SliverDateFlexibleAppBar(
                            controller: scrollController,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const NeverScrollableScrollPhysics(),
                                //controller: scrollController,
                                itemCount: state.expenses.keys.toList().length,
                                itemBuilder: (ctx, index) => ExpensesByDateList(
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
                    duration: const Duration(seconds: 8),
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
