import 'package:flutter/material.dart';
import 'package:gastos/presentation/widgets/expenses/expenses_list.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return const  ExpenseList();
  }
}
