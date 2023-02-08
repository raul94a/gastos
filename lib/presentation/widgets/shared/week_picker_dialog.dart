import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

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
    return Dialog(
      child: WeekPicker(
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
    );
  }
}
