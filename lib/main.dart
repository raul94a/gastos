import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/presentation/pages/inital_load.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/presentation/widgets/main/should_abandon.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesHelper.instance;
  await SqliteManager.instance.open();
  await Firebase.initializeApp();
  FirestoreManager.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  showExpenseDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => const ExpenseDialog());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (c) => JumpButtonsProvider())
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Builder(builder: (appContext) {
            final size = MediaQuery.of(appContext).size;
            final width = size.width;
            return ShouldAbandonApp(
              child: Scaffold(
                appBar: AppBar(
                    //backgroundColor: Colors.white,
                    title: SortDateButtons(
                  expenseState: appContext.read<ExpenseProvider>(),
                )),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => showExpenseDialog(appContext),
                  child: const Icon(Icons.add_rounded),
                ),
                body: const SafeArea(child: InitialLoad()),
              ),
            );
          })),
    );
  }
}

class SortDateButtons extends StatelessWidget with MaterialStatePropertyMixin {
  const SortDateButtons({Key? key, required this.expenseState})
      : super(key: key);

  final ExpenseProvider expenseState;
  Future<void> _sortBy(DateType type) async {
    expenseState.preferences.saveDateType(type);
    expenseState.getByDateType(type);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
            style: ButtonStyle(fixedSize: getProperty(Size(width * 0.21, 40))),
            onPressed: () {
              const type = DateType.day;
              _sortBy(type);
            },
            child: Text('Dia')),
        ElevatedButton(
            style: ButtonStyle(fixedSize: getProperty(Size(width * 0.25, 40))),
            onPressed: () {
              const type = DateType.week;
              _sortBy(type);
            },
            child: Text('Semana')),
        ElevatedButton(
            style: ButtonStyle(fixedSize: getProperty(Size(width * 0.21, 40))),
            onPressed: () {
              const type = DateType.month;
              _sortBy(type);
            },
            child: Text('Mes')),
        ElevatedButton(
            style: ButtonStyle(fixedSize: getProperty(Size(width * 0.21, 40))),
            onPressed: () {
              const type = DateType.year;
              _sortBy(type);
            },
            child: Text('Año'))
      ],
    );
  }
}
