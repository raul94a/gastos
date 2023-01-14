import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/presentation/widgets/custom_dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesHelper.instance;
  await SqliteManager.instance.open();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(
          builder: (appContext) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: ()=> addExpenseDialog(context: appContext),
                child: const Icon(Icons.add_rounded),
              ),
              body: SafeArea(child: MainPage()),
            );
          }
        ));
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (ctx, index) => ListTile(
                      leading: Text('$index'),
                      title: Text('jflasfjñadf'),
                      subtitle: Text('ladfjdaf'),
                    )))
      ],
    );
  }
}

//TODO
class InitialLoad extends StatelessWidget {
  const InitialLoad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
