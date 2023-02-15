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
      color = Color.fromARGB(190, cat.r, cat.g, cat.b);
      if (!ColorComputation.colorsMatch(color)) {
        textColor = Colors.white;
      }
    } catch (err) {
      print(err);
    }
    Color avatarColor = color ?? Colors.white;
    avatarColor = avatarColor.withOpacity(0.55).withAlpha(20);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          width: 0.75,
        ),
      ),
      key: Key(widget.expense.id),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Container(
            height: tileHeight,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.white,
              color ?? Colors.white,
            ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
            child: ListTile(
              isThreeLine: true,
              onLongPress: showOptionDialog,
              contentPadding: const EdgeInsets.all(8),
              style: ListTileStyle.list,
              leading: AvatarPrice(price: expense.price),
              title: Text(
                expense.description + getCategoryName(cat),
                overflow: TextOverflow.fade,
                style: GoogleFonts.raleway(
                  fontSize: titleFontSize,
                ),
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
                    icon: Icon(
                      Icons.more_vert,
                      color: textColor,
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
  static const textColor = Colors.white;
  static const circleRadius = 70.0;
  static const padding = EdgeInsets.all(5.0);
  static const fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      // clipBehavior: Clip.hardEdge,
      child: Container(
        width: circleRadius , 
        height: circleRadius,
        padding: padding,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(color: borderColor)),
        child: FittedBox(
          alignment: Alignment.center,
            // fit: BoxFit.scaleDown,
            child: Text(
              '${price.toStringAsFixed(2)} €',
              style: GoogleFonts.raleway(fontSize: fontSize, color: textColor),
            )),
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
