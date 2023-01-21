import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/main_page.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/presentation/widgets/main/should_abandon.dart';
import 'package:gastos/presentation/widgets/main/sort_by_date_type.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class Init extends StatelessWidget {
  const Init({super.key});

  showExpenseDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => const ExpenseDialog());
  }

  @override
  Widget build(BuildContext context) {
    return ShouldAbandonApp(
      child: Scaffold(
        appBar: AppBar(
            //backgroundColor: Colors.white,
            title: SortDateButtons(
          expenseState: context.read<ExpenseProvider>(),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showExpenseDialog(context),
          child: const Icon(Icons.add_rounded),
        ),
        body: SafeArea(
            child: Consumer<NavigationProvider>(
                builder: (ctx, state, _) => _PageSelector(index: state.page))),
        bottomNavigationBar: Consumer<NavigationProvider>(
          builder: (ctx, state, _) => BottomNavigationBar(
              currentIndex: state.page,
              onTap: state.goTo,
              items: const [a, b, c]),
        ),
      ),
    );
  }
}

const a = BottomNavigationBarItem(icon: Icon(Icons.euro), label: 'Gastos');
const b = BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info');
const c = BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes');

class _PageSelector extends StatelessWidget {
  const _PageSelector({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 0) return const MainPage();
    if (index == 1) return const Info();

    return const Settings();
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
