import 'package:flutter/material.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:gastos/providers/selected_date_provider.dart';
import 'package:gastos/utils/date_formatter.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

class AddExpenseToDateButton extends StatelessWidget
    with MaterialStatePropertyMixin {
  const AddExpenseToDateButton({
    super.key,
    required this.selectedDateState,
    this.individual = false,
  });
  final bool individual;
  final SelectedDateProvider selectedDateState;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Consumer<SelectedDateProvider>(
      builder: (ctx, state, _) => Visibility(
        visible: show(),
        child: ElevatedButton.icon(
            style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                fixedSize: getProperty(Size(width, 45)),
                shape: getProperty(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
            onPressed: () {
              if (individual) {
                //personal expense
                return;
              }

              //common
            },
            icon: Icon(Icons.add_box_outlined),
            label: Text(
              'Añadir gasto a ${selectedDateState.selectedDateForExpenses}',
              style: Theme.of(context).textTheme.labelLarge,
            )),
      ),
    );
  }

  bool show() {
    final dateType = SharedPreferencesHelper.instance.getDateType();
    print(dateType);
    if (dateType != DateType.day) {
      return false;
    }
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    final selectedDateString = selectedDateState.selectedDateForExpenses;
    final selectedDate = MyDateFormatter.fromYYYYMMdd(selectedDateString);
    print('NOW: $now');
    print('SELECTED DATE: $selectedDate');
    return now.isAfter(selectedDate);
  }
}
