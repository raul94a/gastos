import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/data/models/chart_models/category_expenses.dart';
import 'package:gastos/data/repository/chart_info_repository.dart';
import 'package:gastos/presentation/style/chart_styles.dart';
import 'package:gastos/presentation/widgets/charts/chart_card_wrapper.dart';
import 'package:gastos/presentation/widgets/charts/my_bar_chart.dart';
import 'package:gastos/presentation/widgets/charts/my_bar_chart_category.dart';
import 'package:gastos/presentation/widgets/shared/double_material_button.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:provider/provider.dart';

class CurrentMonthInfo extends StatefulWidget {
  const CurrentMonthInfo({super.key});

  @override
  State<CurrentMonthInfo> createState() => _CurrentMonthInfoState();
}

class _CurrentMonthInfoState extends State<CurrentMonthInfo> {
  List<BarChartGroupData> myData = [];
  List<CategoryExpenses> expenses = [];
  double maxY = 0;
  bool showByDay = true;
  @override
  void initState() {
    currentMonthDataByDate();
    super.initState();
  }

  void currentMonthDataByDate() async {
    final data =
        await ChartInfoRepository().currentMonthExpensesGroupedByDate();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];

    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }
    //then, we can create the list of bars
    for (int i = 0; i < data.length; ++i) {
      chartData.add(data[i].generateBarcharDataMonthDay(
          gradient: barsGradient, maxY: mY.toInt() == 0 ? 300 : mY));
    }

    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY.toInt() == 0 ? 300 : mY;
      showByDay = true;
    });
  }

  Future<void> currentMonthDataByCategory(BuildContext context) async {
    final categories = context.read<CategoriesProvider>().categories;
    final data =
        await ChartInfoRepository().currentMonthExpensesGroupedByCategory();
    List<CategoryExpenses> mExpenses = [];
    List<BarChartGroupData> charData = [];
    double mY = 0.0;
    for (final expense in data) {
      if (mY < expense.price) {
        mY = expense.price.toDouble();
      }
    }
    for (final expense in data) {
      mExpenses.add(expense.copyWith(
          name: categories
              .firstWhere((element) => element.id == expense.category,
                  orElse: () => Category(
                      name: '',
                      r: 0,
                      g: 0,
                      b: 0,
                      createdDate: DateTime.now(),
                      updatedDate: DateTime.now()))
              .name));
      charData.add(expense.generateBarcharDataWeekDay(
          gradient: barsGradient, maxY: mY.toInt() == 0 ? 300 : mY));
    }
    setState(() {
      print('mExpenses,$expenses');
      expenses = mExpenses;
      maxY = mY.toInt() == 0 ? 300 : mY;
      myData = charData;
      showByDay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      children: [
        DoubleMaterialButton(
            leftSelected: showByDay,
            onPressedLeft: currentMonthDataByDate,
            onPressedRight: () async =>
                await currentMonthDataByCategory(context),
            leftText: 'Por días',
            rightText: 'Por categoría'),
                        const SizedBox(height: 20,),

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
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                yAxisTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                xAxisWidgetLabel:
                    Text('Mes actual', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                yAxisWidgetLabel:
                    Text('Euros (€)', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
              ),
            ),
          )
        else
          ChartCard(
            child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(4),
                height: size.height * 0.3,
                child: MyBarChart(
                  barChartType: BarChartType.monthDay,
                  data: myData,
                  maxY: maxY + 50,
                  xAxisTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  yAxisTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  xAxisWidgetLabel:
                      Text('Días', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                  yAxisWidgetLabel:
                      Text('Euros (€)', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                )),
          ),
      ],
    );
  }
}
