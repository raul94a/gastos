import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos/presentation/pages/main_page.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/presentation/widgets/main/should_abandon.dart';
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle().copyWith(
        statusBarColor: Colors.black, systemNavigationBarColor: Colors.black));
    return ShouldAbandonApp(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => showExpenseDialog(context),
          child: const Icon(Icons.add_rounded),
        ),
        body: Consumer<NavigationProvider>(
            builder: (ctx, state, _) => _PageSelector(index: state.page)),
        bottomNavigationBar: Consumer<NavigationProvider>(
          builder: (ctx, state, _) => BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.blueAccent.shade100,
            unselectedItemColor: Colors.white,
            unselectedLabelStyle: const TextStyle(color: Colors.white),
            selectedLabelStyle: TextStyle(color: Colors.blueAccent.shade100),
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
