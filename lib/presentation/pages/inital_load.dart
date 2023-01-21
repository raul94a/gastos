import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/main_page.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:provider/provider.dart';

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
    final type = expenseProvider.preferences.getDateType();
    await expenseProvider.get(type);
  }
}
