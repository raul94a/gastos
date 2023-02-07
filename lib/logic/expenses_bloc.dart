import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/presentation/widgets/shared/week_picker_dialog.dart';
import 'package:gastos/presentation/widgets/shared/year_picker_dialog.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/months_parser.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

class ExpensesBloc {
  final BuildContext context;
  ExpensesBloc({required this.context}) {
    _expenseProvider = context.read<ExpenseProvider>();
  }

  late ExpenseProvider _expenseProvider;

  //getter
  ExpenseProvider get state => _expenseProvider;

  //logic
  Future<void> fetchExpenses({required String userUID}) async {
    final dateType = state.dateType;
    switch (dateType) {
      case DateType.day:
        _fetchExpensesByDay(userUID);
        break;
      case DateType.month:
        _fetchExpensesByMonth(userUID);
        break;
      case DateType.year:
        _fetchExpensesByYear(userUID);
        break;
      case DateType.week:
        _fetchExpenseByWeek(userUID);
        break;
    }
  }

  Future<void> _fetchExpensesByYear(String userUID) async {
    String? selectedDate;
    String? selectedDateForExpenses;
    showYearPickerDialog(
        context: context,
        selectedDate: DateTime.now(),
        firstDate: DateTime.parse('1900-01-01'),
        lastDate: DateTime.now(),
        onSelected: (value) async {
          //print('Expenses: ${state.expenses[selectedDateForExpenses]}');
          print(state.expenses);
          final date = value;
          //week

          selectedDate = MyDateFormatter.dateByType(
              DateType.year, MyDateFormatter.toYYYYMMdd(date));
          selectedDateForExpenses = selectedDate;

          if (state.expenses[selectedDateForExpenses] == null) {
            await state.getByYear(date.year, userUID);
          }

          if (selectedDateForExpenses != null) {
            context
                .read<SelectedDateProvider>()
                .setDates(selectedDate!, selectedDateForExpenses!);
          }
        });
  }

  Future<void> _fetchExpensesByDay(String userUID) async {
    String? selectedDate;
    String? selectedDateForExpenses;
    final date = await showDatePicker(
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        initialDate: selectedDate != null
            ? MyDateFormatter.fromFormat('dd/MM/yyyy', selectedDate)
            : DateTime.now(),
        firstDate: DateTime.parse('1900-01-01'),
        lastDate: DateTime.now());
    print(date);
    print(context.read<ExpenseProvider>().expenses);
    if (date != null) {
      selectedDate = MyDateFormatter.toFormat('dd/MM/yyyy', date);
      selectedDateForExpenses = MyDateFormatter.toYYYYMMdd(date);
      print(selectedDate);
      print(selectedDateForExpenses);
    }
    if (state.expenses[selectedDateForExpenses] == null &&
        selectedDateForExpenses != null) {
      await state.getByDate(selectedDateForExpenses, 0, userUID);
    }
    if (selectedDateForExpenses != null) {
      context
          .read<SelectedDateProvider>()
          .setDates(selectedDate!, selectedDateForExpenses);
    }
  }

  Future<void> _fetchExpensesByMonth(String userUID) async {
    String? selectedDate;
    String? selectedDateForExpenses;
    final date = await showMonthYearPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.parse('1900-01-01'),
        lastDate: DateTime.now());

    if (date != null) {
      int monthNumber = date.month - 1;
      Month month = months[monthNumber];
      print(month);
      selectedDate = MyDateFormatter.dateByType(
          DateType.month, MyDateFormatter.toYYYYMMdd(date));
      selectedDateForExpenses = MyDateFormatter.dateByType(
          DateType.month, MyDateFormatter.toYYYYMMdd(date));

      print('Selected Date: $selectedDate');

      if (state.expenses[selectedDateForExpenses] == null &&
          selectedDateForExpenses != null) {
        await state.getByMonth(month.number, date.year, userUID);
      }
    }
    if (selectedDateForExpenses != null) {
      context
          .read<SelectedDateProvider>()
          .setDates(selectedDate!, selectedDateForExpenses);
    }
  }

  Future<void> _fetchExpenseByWeek(String userUID) async {
    String? selectedDate;
    String? selectedDateForExpenses;
    await showWeekPickerDialog(
        context: context,
        selectedDate: DateTime.now(),
        firstDate: DateTime.parse('1900-01-01'),
        lastDate: DateTime.now(),
        onSelected: (value) async {
          print('dateperiod: ${value.start} \n${value.end}');
          final date = value.start;
          //week
          final week = MyDateFormatter.weekYearString(date);
          print(week);
          selectedDate = MyDateFormatter.dateByType(
              DateType.week, MyDateFormatter.toYYYYMMdd(date));
          selectedDateForExpenses = selectedDate;

          if (state.expenses[selectedDateForExpenses] == null &&
              selectedDateForExpenses != null) {
            await state.getByWeek(week, date.year, userUID);
          }
          if (selectedDateForExpenses != null) {
            context
                .read<SelectedDateProvider>()
                .setDates(selectedDate!, selectedDateForExpenses!);
          }
        });
  }
}
