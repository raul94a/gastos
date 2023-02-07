import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/utils/date_formatter.dart';

class SelectedDateProvider with ChangeNotifier {
  String? selectedDate;
  String? selectedDateForExpenses;

  setDates(String selectedDate, String selectedDateForExpenses) {
    this.selectedDate = selectedDate;
    this.selectedDateForExpenses = selectedDateForExpenses;
    print('Calling selectedDateProvider');
    notifyListeners();
  }

  void setSelectedDates(DateType type) {
    final now = DateTime.now();
    String selectedDate = '';
    String selectedDateForExpenses = '';

    switch (type) {
      case DateType.day:
        selectedDate = MyDateFormatter.toFormat('dd/MM/yyyy', now);
        selectedDateForExpenses = MyDateFormatter.toYYYYMMdd(now);

        break;
      case DateType.month:
        selectedDate = MyDateFormatter.dateByType(
            DateType.month, MyDateFormatter.toYYYYMMdd(now));
        selectedDateForExpenses = MyDateFormatter.dateByType(
            DateType.month, MyDateFormatter.toYYYYMMdd(now));
        break;
      case DateType.year:
        selectedDate = MyDateFormatter.dateByType(
            DateType.year, MyDateFormatter.toYYYYMMdd(now));
        selectedDateForExpenses = selectedDate;

        break;
      case DateType.week:
        selectedDate = MyDateFormatter.toFormat('dd/MM/yyyy', now);
        selectedDateForExpenses = selectedDate;
        break;
    }
    print(
        'SELECTED DATE: $selectedDate\nSelectedDateFroExpenses:$selectedDateForExpenses');
    setDates(selectedDate, selectedDateForExpenses);
  }
}
