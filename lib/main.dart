import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/providers/navigation_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/routes/router.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

void main() async {
  await _initDependencies();
  runApp(const MyApp());
}

Future<void> _initDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesHelper.instance;
  await SqliteManager.instance.open();
  await Firebase.initializeApp();

  FirestoreManager.instance;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => NavigationProvider()),
        ChangeNotifierProvider(
          lazy: false,
          create: (ctx) => CategoriesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (c) => JumpButtonsProvider())
      ],
      child: Builder(builder: (context) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          locale: Locale('es','ES'),
          supportedLocales: [
            Locale('es')
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routerConfig: router,
        );
      }),
    );
  }
}
