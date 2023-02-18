import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:gastos/data/enums/date_type.dart';
import 'package:gastos/utils/date_formatter.dart';

Future<void> showWeekPickerDialog(
    {required BuildContext context,
    required DateTime selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DatePeriod) onSelected}) async {
  showDialog(
      context: context,
      builder: (_) => _WeekPickerDialog(
          onSelected: onSelected,
          selectedDate: selectedDate,
          firstDate: firstDate,
          lastDate: lastDate));
}

class _WeekPickerDialog extends StatefulWidget {
  const _WeekPickerDialog(
      {super.key,
      required this.onSelected,
      required this.selectedDate,
      required this.firstDate,
      required this.lastDate});

  final Function(DatePeriod) onSelected;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;

  @override
  State<_WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<_WeekPickerDialog> {
  late DateTime selectedDate = widget.selectedDate;

  @override
  Widget build(BuildContext context) {
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(10.0), bottomEnd: Radius.circular(10.0))),
      selectedPeriodStartDecoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(10.0),
            bottomStart: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration: const BoxDecoration(
          color: Color.fromARGB(255, 62, 72, 75), shape: BoxShape.rectangle),
    );
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40,vertical: size.height*0.17),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            height: 150,
            width: width,
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Elige una semana del año'.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 15,),
                  Text(getDate(selectedDate),
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          WeekPicker(
              datePickerStyles: styles,
              selectedDate: selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onChanged: (period) {
                widget.onSelected(period);
                setState(() {
                  selectedDate = period.end;
                });
              }),
        ],
      ),
    );
  }

  String getDate(DateTime date) {
    final parsedDate = MyDateFormatter.toYYYYMMdd(date);
    return MyDateFormatter.dateByType(DateType.week, parsedDate);
  }
}
