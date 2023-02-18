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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: 40, vertical: size.height * 0.17),
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
                  Text('Elige un año'.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 15,),
                  Text(selectedDate.year.toString(),
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          Expanded(
            child: YearPicker(
              
                selectedDate: selectedDate,
                firstDate: DateTime.parse('2018-02-02'),
                lastDate: widget.lastDate,
                onChanged: (dateTime) {
                  widget.onSelected(dateTime);
                  setState(() {
                    selectedDate = dateTime;
                  });
                }),
          ),
        ],
      ),
    );
  }
}
