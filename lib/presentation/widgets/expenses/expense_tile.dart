import 'package:flutter/material.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/pages/individual_expenses.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_options_dialog.dart';
import 'package:gastos/presentation/widgets/dialogs/individual_expense_options_dialog.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExpenseTile extends StatefulWidget {
  const ExpenseTile(
      {Key? key,
      this.individualExpense = false,
      required this.state,
      required this.date,
      required this.expense,
      required this.position})
      : super(key: key);
  final ExpenseProvider state;
  final String date;
  final Expense expense;
  final int position;
  final bool individualExpense;

  @override
  State<ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  static const titleFontSize = 18.2;
  static const subTitleFontSize = 16.0;
  static const tileHeight = 105.0;

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
          if (widget.individualExpense) {
            return IndividualExpenseOptionsDialog(
                updateHandler: updateExpense,
                expense: expense,
                
                state: widget.state,
                index: widget.position,
                date: widget.date);
          }
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
    try {
      cat = categories.firstWhere((element) => element.id == expense.category);
      color = Color.fromARGB(190, cat.r, cat.g, cat.b);
    } catch (err) {
      print(err);
    }
    Color avatarColor = color ?? Colors.white;
    avatarColor = avatarColor.withOpacity(0.55).withAlpha(20);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(6.5)),
        boxShadow: [
          BoxShadow(
              color: Color.fromARGB(181, 119, 118, 118),
              blurRadius: 5,
              offset: Offset(0.5, 1.25))
        ],
      ),
      key: Key(widget.expense.id),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            height: 15,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              (color ?? Colors.white).withOpacity(0.35),
              color ?? Colors.white,
            ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
          ),
          SizedBox(
            height: tileHeight,
            child: ListTile(
              isThreeLine: true,
              tileColor: Colors.white,
              onLongPress: showOptionDialog,
              contentPadding: const EdgeInsets.all(8),
              style: ListTileStyle.list,
              leading: AvatarPrice(price: expense.price),
              title: Text(
                expense.description + getCategoryName(cat),
                overflow: TextOverflow.fade,
                style: GoogleFonts.raleway(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              subtitle: Text(
                expense.person,
                maxLines: 2,
                style: GoogleFonts.raleway(
                    fontSize: subTitleFontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              trailing: SizedBox(
                width: width * 0.2,
                child: IconButton(
                    onPressed: showOptionDialog,
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getCategoryName(Category? cat) {
    if (cat == null) return '';
    return ' (${cat.name})';
  }
}

class AvatarPrice extends StatelessWidget {
  const AvatarPrice({super.key, required this.price});
  final num price;

  static const backgroundColor = Color.fromARGB(219, 0, 0, 0);
  static const borderColor = Colors.black;
  static const textColor = Colors.black;
  static const circleRadius = 70.0;
  static const padding = EdgeInsets.all(5.0);
  static const fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: circleRadius,
      child: Center(
        child: Text(
          '${price.toStringAsFixed(2)} €',
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
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
