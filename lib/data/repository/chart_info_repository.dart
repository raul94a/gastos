import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/date_expenses.dart';
import 'package:gastos/data/services/chart_info_service.dart';
import 'package:gastos/data/models/chart_models/year_expenses.dart';
class ChartInfoRepository {
  ChartInfoRepository();
  final service = ChartInfoService();

  Future<List<DateExpenses>> currentWeekExpensesGroupedByDate() async {
    final results = await service.getCurrentWeekExpensesByDate();
        return results.map(DateExpenses.fromMap).toList();
  }
   Future<List<DateExpenses>> currentMonthExpensesGroupedByDate() async {
    final results = await service.getCurrentMonthExpensesByDay();
    return results.map(DateExpenses.fromMap).toList();
  }

  Future<List<YearExpenses>> currentYearExpensesGroupedByMonth() async {
    final results  = await service.getCurrentYearExpensesGroupedByMonth();
    return results.map(YearExpenses.fromMap).toList();
  }

}
