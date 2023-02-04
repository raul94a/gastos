import 'package:flutter/material.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_options_dialog.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExpenseTile extends StatefulWidget {
  const ExpenseTile(
      {Key? key,
      required this.state,
      required this.date,
      required this.expense,
      required this.position})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final Expense expense;
  final int position;

  @override
  State<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  late Expense expense;
  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  void updateExpense(Expense exp) {
    setState(() {
      expense = expense.copyWith(
          updatedDate: exp.updatedDate,
          person: exp.person,
          category: exp.category,
          price: exp.price,
          description: exp.description);
    });
  }

  void showOptionDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return ExpenseOptionsDialog(
              updateHandler: updateExpense,
              expense: expense,
              state: widget.state,
              index: widget.position,
              date: widget.date);
        });
  }

  @override
  Widget build(BuildContext context) {
//    print('Rebuild Expense with ID: ${widget.expense.id}');
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final categories = context.read<CategoriesProvider>().categories;
    Category? cat;
    Color? color;
    Color textColor = Colors.black;
    try {
      cat = categories.firstWhere((element) => element.id == expense.category);
      color = Color.fromARGB(190,cat.r, cat.g, cat.b);
      if (!ColorComputation.colorsMatch(color)) {
        textColor = Colors.white;
      }
    } catch (err) {
      print(err);
    }

    return Container(
      key: Key(widget.expense.id),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        isThreeLine: true,
        onLongPress: showOptionDialog,
        contentPadding: const EdgeInsets.all(8),
        tileColor: color ??
            Colors
                .white, //isEven ? Colors.blue.shade100 : Colors.orange.shade100,
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 2.8,
                color: color == null
                    ? const Color(0xFF000000)
                    : ColorComputation.getShade(
                        color), //isEven ? Colors.blue.shade500 : Colors.orange.shade500,
                strokeAlign: 0.0),
            borderRadius: BorderRadius.circular(7)),
        leading: CircleAvatar(
          
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
                child: Column(
              children: [
                Text(
                  '${expense.price} €',
                  style: GoogleFonts.raleway(fontSize: 16),
                ),
              ],
            )),
          ),
        ),
        title: Text(
          expense.description + getCategoryName(cat),
          style: GoogleFonts.raleway(fontSize: 16, color: textColor),
        ),
        subtitle: Text(
          expense.person,
          maxLines: 2,
          style: GoogleFonts.raleway(fontSize: 16, color: textColor),
        ),
        trailing: SizedBox(
          width: width * 0.2,
          child: IconButton(
              onPressed: showOptionDialog,
              icon: Icon(
                Icons.more_vert,
                color: textColor,
              )),
        ),
      ),
    );
  }
   String getCategoryName(Category? cat){
    if(cat == null) return '';
    return ' (${cat.name})';
  }
}

class ColorComputation {
  static const double _shadeFactor = 0.45;
  static const int _brightnessLimit = 125;
  static const int _colorDifferenceLimit = 500;
  static const Color _textColor = Colors.black;

  static bool colorsMatch(Color color) {
    final brightness = brightnessDifference(color);
    final colorDiff = colorDifference(color);
    return brightness && colorDiff;
  }

  static bool brightnessDifference(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    final r2 = _textColor.red;
    final g2 = _textColor.green;
    final b2 = _textColor.blue;

    final backgroundIndex = (299 * r + 587 * g + 114 * b) / 1000;
    final textIndex = (299 * r2 + 587 * g2 + 114 * b2) / 1000;
    final result = (textIndex - backgroundIndex).abs();
    // print('Brightness diff: $result');
    return result >= _brightnessLimit;
  }

  static bool colorDifference(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    final r2 = _textColor.red;
    final g2 = _textColor.green;
    final b2 = _textColor.blue;

    final result = (r - r2).abs() + (g - g2).abs() + (b - b2).abs();
    // print('Color diff: $result');
    return result >= _colorDifferenceLimit;
  }

  static Color getShade(Color color) {
    final r = color.red * (1 - _shadeFactor);
    final g = color.green * (1 - _shadeFactor);
    final b = color.blue * (1 - _shadeFactor);
    return Color.fromRGBO(r.toInt(), g.toInt(), b.toInt(), 1);
  }

 
}
