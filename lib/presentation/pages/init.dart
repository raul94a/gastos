import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos/presentation/pages/new_expenses_list.dart';
import 'package:gastos/presentation/pages/new_individual_expense_list.dart';
import 'package:gastos/presentation/pages/settings.dart';
import 'package:gastos/presentation/pages/info.dart';
import 'package:gastos/presentation/widgets/dialogs/common_expense_dialogs.dart';
import 'package:gastos/presentation/widgets/dialogs/individual_expense_dialogs.dart';
import 'package:gastos/presentation/widgets/main/should_abandon.dart';
import 'package:gastos/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class Init extends StatelessWidget {
  const Init({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle().copyWith(
    //     systemNavigationBarDividerColor: Colors.indigo,
    //     statusBarBrightness: Brightness.light,
    //     statusBarIconBrightness: Brightness.light,
    //     systemStatusBarContrastEnforced: false,
    //     statusBarColor: Colors.transparent,
    //     systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(label: 'Mis gastos', primaryColor: 100));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.indigo,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarContrastEnforced: true,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.indigo),
      child: ShouldAbandonApp(
        child: Scaffold(
          floatingActionButton: const _Fab(),
          body: Consumer<NavigationProvider>(
              builder: (ctx, state, _) => _PageSelector(index: state.page)),
          bottomNavigationBar: Consumer<NavigationProvider>(
            builder: (ctx, state, _) => BottomNavigationBar(
                // backgroundColor: Colors.black,
                type: BottomNavigationBarType.fixed,
                currentIndex: state.page,
                onTap: state.goTo,
                items: const [alpha, a, b, c]),
          ),
        ),
      ),
    );
  }
}

const alpha = BottomNavigationBarItem(
    icon: Hero(tag: 'individual', child: Icon(Icons.person)),
    label: 'Personal');

const a = BottomNavigationBarItem(icon: Icon(Icons.euro), label: 'Comun');
const b = BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info');
const c = BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes');

class _PageSelector extends StatelessWidget {
  const _PageSelector({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 0) return const NewIndividualExpenseList();
    if (index == 1) return const NewExpenseList();
    if (index == 2) return const InfoPage();

    return const Settings();
  }
}

class _Fab extends StatelessWidget {
  const _Fab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(builder: (ctx, state, _) {
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
    });
  }

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
}
