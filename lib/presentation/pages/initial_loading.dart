import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/logic/loader_service.dart';
import 'package:gastos/presentation/widgets/shared/loading.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class InitialLoading extends StatefulWidget {
  const InitialLoading({super.key, required this.userUID});
  final String userUID;
  @override
  State<InitialLoading> createState() => _InitialLoadingState();
}

class _InitialLoadingState extends State<InitialLoading> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    String userUID = widget.userUID;
    print('CURRENT UID $userUID');
    await LoaderService().initialLoad(context, userUID);
    if (context.read<UserProvider>().loggedUser == null) {
      context.read<UserProvider>().setLoggedUser(userUID);
    }
    goToExpenseList(context);
  }

  void goToExpenseList(BuildContext context) {
    context.go('/init');
  }

  @override
  Widget build(BuildContext context) {
    print('Building initial Loading');


    return const Scaffold(body: Loading());
  }
}
