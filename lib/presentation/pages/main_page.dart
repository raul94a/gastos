import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/expenses/expenses_list.dart';

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