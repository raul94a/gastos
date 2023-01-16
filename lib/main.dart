import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos/data/firestore_manager.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/data/sqlite_manager.dart';
import 'package:gastos/presentation/widgets/custom_dialogs.dart';
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
    showDialog(context: context, builder: (ctx) => const ExpenseDialog());
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

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [Expanded(child: ExpenseList())],
    );
  }
}

class ExpenseList extends StatelessWidget {
  const ExpenseList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Consumer<ExpenseProvider>(
      builder: (ctx, state, _) => Center(
        child: SizedBox(
          width: width * 0.96,
          child: ListView.builder(
              itemCount: state.expenses.keys.toList().length,
              itemBuilder: (ctx, index) =>
                  ExpensesByDateList(state: state, index: index)),
        ),
      ),
    );
  }
}

class ExpensesByDateList extends StatefulWidget {
  const ExpensesByDateList({Key? key, required this.state, required this.index})
      : super(key: key);
  final ExpenseProvider state;
  final int index;

  @override
  State<ExpensesByDateList> createState() => _ExpensesByDateListState();
}

class _ExpensesByDateListState extends State<ExpensesByDateList> {
  bool show = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show = widget.index == 0 ? true : false;
  }

  void changeShowStatus() => setState(() => show = !show);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Wrap(
      children: [
        GestureDetector(
            onTap: changeShowStatus,
            child: Text(widget.state.orderedDate[widget.index])),
        if (show)
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.state
                  .expenses[widget.state.orderedDate[widget.index]]!.length,
              itemBuilder: ((context, i) {
                final date = widget.state.orderedDate[widget.index];
                final List<Expense> expenses = widget.state.expenses[date]!;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return ExpenseOptionsDialog(
                                state: widget.state, index: i, date: date);
                          });
                    },
                    contentPadding: const EdgeInsets.all(8),
                    style: ListTileStyle.list,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(7)),
                    leading: Text('${i + 1}'),
                    title: Text(expenses[i].description),
                    subtitle: Text(expenses[i].person),
                    trailing: CircleAvatar(
                      radius: 70,
                      child: Text('${expenses[i].price} €'),
                    ),
                  ),
                );
              })),
        if (widget.index != 0 && show)
          ElevatedButton(
              onPressed: () {},
              child: Text(
                  'Añadir gasto a ${widget.state.orderedDate[widget.index]}'))
      ],
    );
  }
}

class ExpenseOptionsDialog extends StatelessWidget {
  const ExpenseOptionsDialog(
      {Key? key, required this.state, required this.index, required this.date})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final int index;
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Selecciona la acción que desees'),
      children: [
        TextButton.icon(
            onPressed: state.loading
                ? null
                : () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (ctx) => ExpenseDialog(
                            expense: state.expenses[date]![index]));
                  },
            icon: const Icon(Icons.update),
            label: const Text('Actualizar gasto')),
        TextButton.icon(
            onPressed: state.loading
                ? null
                : () => state
                    .remove(state.expenses[date]![index])
                    .whenComplete(() => Navigator.of(context).pop()),
            icon: Icon(Icons.update),
            label: Text('Eliminar gasto')),
        ElevatedButton(
            onPressed: Navigator.of(context).pop, child: Text('Cancelar')),
      ],
    );
  }
}

class InitialLoad extends StatelessWidget {
  const InitialLoad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async => await initialLoad(context));
    return Consumer<ExpenseProvider>(builder: (ctx, state, _) {
      if (state.initialFetchFinished) {
        return const MainPage();
      }
      return Center(
        child: Column(
          children: const [
            CircularProgressIndicator(),
            Text('Obteniendo datos...')
          ],
        ),
      );
    });
  }

  Future<void> initialLoad(BuildContext context) async {
    final expenseProvider = context.read<ExpenseProvider>();
    await expenseProvider.fetchExpenses();
    await expenseProvider.get();
  }
}
