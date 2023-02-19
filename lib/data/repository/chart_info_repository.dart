import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/category_expenses.dart';
import 'package:gastos/data/models/chart_models/date_expenses.dart';
import 'package:gastos/data/services/chart_info_service.dart';
import 'package:gastos/data/models/chart_models/year_expenses.dart';

class ChartInfoRepository {
  final service = ChartInfoService();
  final bool individual;
  ChartInfoRepository({this.individual = false});

  Future<List<DateExpenses>> currentWeekExpensesGroupedByDate() async {
    final results =
        await service.getCurrentWeekExpensesByDate(individual: individual);
    return results.map(DateExpenses.fromMap).toList();
  }

  Future<List<DateExpenses>> currentMonthExpensesGroupedByDate() async {
    final results =
        await service.getCurrentMonthExpensesByDay(individual: individual);
    return results.map(DateExpenses.fromMap).toList();
  }

  Future<List<YearExpenses>> currentYearExpensesGroupedByMonth() async {
    final results = await service.getCurrentYearExpensesGroupedByMonth(
        individual: individual);
    return results.map(YearExpenses.fromMap).toList();
  }

  //categories
  Future<List<CategoryExpenses>> currentWeekExpensesGroupedByCategory() async {
    final results =
        await service.getCurrentWeekExpensesByCategory(individual: individual);
    List<CategoryExpenses> list = <CategoryExpenses>[];
    for (int i = 0; i < results.length; i++) {
      final categoryExpense = CategoryExpenses.fromMap(results[i]);

      list.add(categoryExpense.copyWith(index: i));
    }
    print('WEEK CAT: $list');
    if (list.isEmpty) {
      list = List.generate(
          5,
          (index) => CategoryExpenses(
              category: '', index: index, price: 0.0, name: ''));
    }
    return list;
  }

  Future<List<CategoryExpenses>> currentMonthExpensesGroupedByCategory() async {
    final results =
        await service.getCurrentMonthExpensesByCategory(individual: individual);
    final list = <CategoryExpenses>[];
    for (int i = 0; i < results.length; i++) {
      final categoryExpense = CategoryExpenses.fromMap(results[i]);

      list.add(categoryExpense.copyWith(index: i));
    }
    return list;
  }

  Future<List<CategoryExpenses>> currentYearExpensesGroupedByCategory() async {
    final results = await service.getCurrentYearExpensesGroupedByCategory(
        individual: individual);
    final list = <CategoryExpenses>[];
    for (int i = 0; i < results.length; i++) {
      final categoryExpense = CategoryExpenses.fromMap(results[i]);

      list.add(categoryExpense.copyWith(index: i));
    }
    return list;
  }
}
