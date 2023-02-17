// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/providers/navigation_provider.dart';
import 'package:gastos/providers/scroll_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/routes/router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    print(FirebaseAuth.instance.currentUser?.uid);
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
        ChangeNotifierProvider(create: (c) => JumpButtonsProvider()),
        ChangeNotifierProvider(create: (c) => SelectedDateProvider()),
        ChangeNotifierProvider(create: (_) => ScrollProvider())
      ],
      child: Builder(builder: (context) {
        return MaterialApp.router(
          title: 'Mis Gastos App',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          locale: Locale('es', 'ES'),
          supportedLocales: [Locale('es')],
          theme: ThemeData.light(
                  // useMaterial3: true,
                  //primarySwatch: Colors.blueC,
                  )
              .copyWith(
                  textTheme: TextTheme(
                      // titleLarge: GoogleFonts.raleway(fontSize:16.0,color: Colors.black),
                      //titlemedium control the formtext style
                      titleMedium: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      headlineLarge: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      headlineMedium: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      headlineSmall: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      //control del texto general
                      bodyMedium: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      bodySmall: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      labelSmall: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      labelMedium: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      displayLarge: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      displayMedium: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      displaySmall: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      bodyLarge: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black),
                      labelLarge: TextStyle(color: Colors.white),
                      titleSmall: GoogleFonts.raleway(
                          fontSize: 16.0, color: Colors.black)),
                  cardColor: Colors.white,
                  // textTheme: TextTheme(),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                          textStyle: MaterialStateProperty.resolveWith(
                              (states) => TextStyle(color: Colors.white)),
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.indigoAccent))),
                  buttonTheme: ButtonThemeData(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      buttonColor: Colors.indigo,
                      colorScheme:
                          ColorScheme.light(background: Colors.indigo)),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      backgroundColor: Colors.indigo,
                      selectedItemColor: Colors.yellow,
                      unselectedItemColor: Colors.white,
                      selectedLabelStyle: TextStyle(color: Colors.yellow),
                      unselectedLabelStyle: TextStyle(color: Colors.white)),
                  bottomSheetTheme:
                      BottomSheetThemeData(backgroundColor: Colors.white),
                  tabBarTheme: TabBarTheme(
                      labelStyle: TextStyle(fontSize: 16.0),
                      unselectedLabelColor: Colors.white,
                      dividerColor: Colors.white,
                      indicatorColor: Colors.white,
                      labelColor: Color.fromARGB(255, 223, 228, 154)),
                  cardTheme: CardTheme(color: Colors.white),
                  colorScheme: ColorScheme.light(
                      // onPrimary: Colors.black,
                      primary: Colors.indigo,
                      error: Colors.red,
                      onSecondary: Colors.indigo,
                      secondary: Color.fromARGB(255, 255, 237, 75))),
          routerConfig: router,
        );
      }),
    );
  }
}
