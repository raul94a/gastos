import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/init.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:provider/provider.dart';

class InitialLoading extends StatelessWidget {
  const InitialLoading({super.key});

  void goToExpenseList(BuildContext context) {
    Future.microtask(() => Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => const Init())));
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = context.watch<ExpenseProvider>();
    if (expensesProvider.loading || !expensesProvider.initialFetchFinished) {
      return const Scaffold(body: Loading());
    }

    goToExpenseList(context);

    return const Scaffold(body: SizedBox.shrink());
  }
}