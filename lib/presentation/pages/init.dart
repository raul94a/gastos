import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gastos/presentation/pages/individual_expenses.dart';
import 'package:gastos/presentation/pages/new_expenses_list.dart';
import 'package:gastos/presentation/pages/settings.dart';
import 'package:gastos/presentation/pages/info.dart';
import 'package:gastos/presentation/widgets/dialogs/common_expense_dialogs.dart';
import 'package:gastos/presentation/pages/expenses_list.dart';
import 'package:gastos/presentation/widgets/dialogs/individual_expense_dialogs.dart';
import 'package:gastos/presentation/widgets/main/should_abandon.dart';
import 'package:gastos/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class Init extends StatelessWidget {
  const Init({super.key});

  showExpenseDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => const CommonExpenseDialog());
  }

  showIndividualExpenseDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => const IndividualExpenseDialog());
  }

  @override
  Widget build(BuildContext context) {
  
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle().copyWith(
        statusBarColor: Colors.black, systemNavigationBarColor: Colors.black));

    return ShouldAbandonApp(
      child: Scaffold(
        floatingActionButton:
            Consumer<NavigationProvider>(builder: (ctx, state, _) {
          return FloatingActionButton(
            heroTag: 'hero-fab',

            onPressed: () {
              switch (state.pageName) {
                case PageName.individual:
                  showIndividualExpenseDialog(context);
                  break;
                case PageName.common:
                  showExpenseDialog(context);
                  break;
                case PageName.info:
                  break;
                case PageName.settings:

                  break;
              }
            },
            child: const Icon(Icons.add_rounded),
          );
        }),
        body: Consumer<NavigationProvider>(
            builder: (ctx, state, _) => _PageSelector(index: state.page)),
        bottomNavigationBar: Consumer<NavigationProvider>(
          builder: (ctx, state, _) => BottomNavigationBar(
              backgroundColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blueAccent.shade100,
              unselectedItemColor: Colors.white,
              unselectedLabelStyle: const TextStyle(color: Colors.white),
              selectedLabelStyle: TextStyle(color: Colors.blueAccent.shade100),
              currentIndex: state.page,
              onTap: state.goTo,
              items: const [alpha, a, b, c]),
        ),
      ),
    );
  }
}

const alpha =

    BottomNavigationBarItem(icon: Hero(tag: 'individual',child: Icon(Icons.person)), label: 'Invidivuales');

const a = BottomNavigationBarItem(icon: Icon(Icons.euro), label: 'Gastos');
const b = BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info');
const c = BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes');

class _PageSelector extends StatelessWidget {
  const _PageSelector({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 0) return const IndividualExpensesPage();
    if (index == 1) return const NewExpenseList();
    if (index == 2) return const InfoPage();

    return const Settings();
  }
}
