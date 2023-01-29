import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class InitialLoading extends StatelessWidget {
  const InitialLoading({super.key});

  void goToExpenseList(BuildContext context) {
    Future.microtask(() => context.go('/init'));
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = context.watch<ExpenseProvider>();
    if (context.read<UserProvider>().loggedUser == null) {
      context
          .read<UserProvider>()
          .setLoggedUser(FirebaseAuth.instance.currentUser!.uid);
    }
    if (expensesProvider.loading || !expensesProvider.initialFetchFinished) {
      return const Scaffold(body: Loading());
    }

    goToExpenseList(context);

    return const Scaffold(body: Loading());
  }
}
