import 'package:flutter/material.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:provider/provider.dart';

class ProviderService {
  late ExpenseProvider expenseProvider;
  late UserProvider userProvider;
  late CategoriesProvider categoriesProvider;

  ProviderService({required BuildContext context}) {
    expenseProvider = context.read<ExpenseProvider>();
    userProvider = context.read<UserProvider>();
    categoriesProvider = context.read<CategoriesProvider>();
  }

  
}
