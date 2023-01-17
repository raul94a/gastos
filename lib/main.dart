import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/presentation/pages/inital_load.dart';
import 'package:gastos/presentation/widgets/dialogs/custom_dialogs.dart';
import 'package:gastos/providers/expense_provider.dart';
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
    showDialog(context: context, barrierDismissible: true,builder: (ctx) => const ExpenseDialog());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
          lazy: false,
        )
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Builder(builder: (appContext) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => showExpenseDialog(appContext),
                child: const Icon(Icons.add_rounded),
              ),
              body: const SafeArea(child: InitialLoad()),
            );
          })),
    );
  }
}
