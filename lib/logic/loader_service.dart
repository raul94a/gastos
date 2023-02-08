import 'package:flutter/material.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:provider/provider.dart';

class LoaderService{


  Future<void> initialLoad(BuildContext context, String firebaseUID) async {
    final usersProvider = context.read<UserProvider>();
    final categoriesProvider = context.read<CategoriesProvider>();
    final expensesProvider = context.read<ExpenseProvider>();
    await categoriesProvider.initialLoad();
    await usersProvider.initialLoad();
    await expensesProvider.initialLoad(firebaseUID: firebaseUID);
  }

}