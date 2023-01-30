import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/individual_expenses_provider.dart';
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
    final individualExpenseProvider = context.read<IndividualExpenseProvider>();
    final currentUID = FirebaseAuth.instance.currentUser!.uid;

    Future.microtask(() => individualExpenseProvider.initialLoad(currentUID));
    if (context.read<UserProvider>().loggedUser == null) {
      context.read<UserProvider>().setLoggedUser(currentUID);
    }
    if (expensesProvider.loading || !expensesProvider.initialFetchFinished) {
      return const Scaffold(body: Loading());
    }

    goToExpenseList(context);

    return const Scaffold(body: Loading());
  }
}
