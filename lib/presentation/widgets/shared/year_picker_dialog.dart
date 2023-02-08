import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as picker;

Future<void> showYearPickerDialog(
    {required BuildContext context,
    required DateTime selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onSelected}) async {
  showDialog(
      context: context,
      builder: (_) => _YearPickerDialog(
          onSelected: onSelected,
          selectedDate: selectedDate,
          firstDate: firstDate,
          lastDate: lastDate));
}

class _YearPickerDialog extends StatefulWidget {
  const _YearPickerDialog(
      {super.key,
      required this.onSelected,
      required this.selectedDate,
      required this.firstDate,
      required this.lastDate});

  final Function(DateTime) onSelected;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late DateTime selectedDate = widget.selectedDate;

  @override
  Widget build(BuildContext context) {
    
    
    return Dialog(
      child: YearPicker(
          selectedDate: selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onChanged: (dateTime) {
            widget.onSelected(dateTime);
            setState(() {
              selectedDate = dateTime;
            });
          }),
    );
  }
}
