import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/category_expenses.dart';
import 'package:gastos/data/repository/chart_info_repository.dart';
import 'package:gastos/presentation/style/chart_styles.dart';
import 'package:gastos/presentation/widgets/charts/chart_card_wrapper.dart';
import 'package:gastos/presentation/widgets/charts/my_bar_chart.dart';
import 'package:gastos/presentation/widgets/charts/my_bar_chart_category.dart';
import 'package:gastos/presentation/widgets/shared/double_material_button.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:provider/provider.dart';

class CurrentYearInfo extends StatefulWidget {
  const CurrentYearInfo({super.key});

  @override
  State<CurrentYearInfo> createState() => _CurrentYearInfoState();
}

class _CurrentYearInfoState extends State<CurrentYearInfo> {
  List<BarChartGroupData> myData = [];
  List<CategoryExpenses> expenses = [];
  double maxY = 0;
  bool showByDay = true;
  @override
  void initState() {
    currentYearDataByDate();
    super.initState();
  }

  void currentYearDataByDate() async {
    final data =
        await ChartInfoRepository().currentYearExpensesGroupedByMonth();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];
    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }

    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i]
          .generateBarcharDataYearMonth(gradient: barsGradient, maxY: mY));
    }
    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY;
      showByDay = true;
    });
  }

  Future<void> currentYearDataByCategory(BuildContext context) async {
    final categories = context.read<CategoriesProvider>().categories;
    final data =
        await ChartInfoRepository().currentYearExpensesGroupedByCategory();
    List<CategoryExpenses> mExpenses = [];
    List<BarChartGroupData> charData = [];
    double mY = 0.0;
    for (final expense in data) {
      if (mY < expense.price) {
        mY = expense.price.toDouble();
      }
    }
    for (final expense in data) {
      try {
        mExpenses.add(expense.copyWith(
            name: categories
                .firstWhere((element) => element.id == expense.category)
                .name));
      } catch (err) {
        mExpenses.add(expense.copyWith(name: 'Otros'));
      }
      charData.add(
          expense.generateBarcharDataWeekDay(gradient: barsGradient, maxY: mY));
    }
    setState(() {
      expenses = mExpenses;
      myData = charData;
      maxY = mY;

      showByDay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoubleMaterialButton(
            leftSelected: showByDay,
            onPressedLeft: currentYearDataByDate,
            onPressedRight: () async =>
                await currentYearDataByCategory(context),
            leftText: 'Por días',
            rightText: 'Por categoría'),
       
        if (!showByDay)
          ChartCard(
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(4),
              height: size.height * 0.3,
              child: MyBarChartCategory(
                barChartType: BarChartCategoryType.weekCategory,
                categoriesExpenses: expenses,
                data: myData,
                maxY: maxY + 100,
                xAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                yAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                xAxisWidgetLabel:
                    Text('Mes actual', style: TextStyle(color: Colors.white)),
                yAxisWidgetLabel:
                    Text('Euros (€)', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        else
          ChartCard(
            child: Container(
              padding: const EdgeInsets.all(5),
              //decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: Colors.indigo),
              height: size.height * 0.3,
              margin: const EdgeInsets.all(4),
              child: MyBarChart(
                barChartType: BarChartType.yearMonth,
                data: myData,
                maxY: maxY + 100,
                xAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                yAxisTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                xAxisWidgetLabel:
                    Text('Meses', style: TextStyle(color: Colors.white)),
                yAxisWidgetLabel:
                    Text('Euros (€)', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }
}
