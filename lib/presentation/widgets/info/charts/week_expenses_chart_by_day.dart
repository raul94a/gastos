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

class CurrentWeekInfo extends StatefulWidget {
  const CurrentWeekInfo({super.key});

  @override
  State<CurrentWeekInfo> createState() => _CurrentWeekInfoState();
}

class _CurrentWeekInfoState extends State<CurrentWeekInfo> {
  List<BarChartGroupData> myData = [];
  List<CategoryExpenses> expenses = [];
  double maxY = 0;
  bool showByDay = true;

  @override
  void initState() {
    currentWeekDataByDate();
    super.initState();
  }

  //
  void currentWeekDataByDate() async {
    final data = await ChartInfoRepository().currentWeekExpensesGroupedByDate();
    double mY = 0.0;
    List<BarChartGroupData> chartData = [];
    //first it needed to know the yMax for drawing the background of the chart bars
    for (int i = 0; i < data.length; ++i) {
      if (data[i].price > mY) {
        mY = data[i].price.toDouble();
      }
    }
    for (int i = 0; i < data.length; ++i) {
      chartData.add(
          data[i].generateBarcharDataWeekDay(gradient: barsGradient, maxY: mY));
    }
    setState(() {
      myData = chartData..sort((a, b) => a.x.compareTo(b.x));
      maxY = mY;
      showByDay = true;
    });
  }

  Future<void> currentWeekDataByCategory(BuildContext context) async {
    final categories = context.read<CategoriesProvider>().categories;
    final data =
        await ChartInfoRepository().currentWeekExpensesGroupedByCategory();
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
              .firstWhere((element) => element.id == expense.category)
              .name));
      charData.add(
          expense.generateBarcharDataWeekDay(gradient: barsGradient, maxY: mY));
    }
    setState(() {
      print('mExpenses,$expenses');
      expenses = mExpenses;
      myData = charData;
      showByDay = false;
      maxY = mY;
    });
  }

  changeShowByDayStatus() => setState(() => showByDay = !showByDay);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      children: [
        DoubleMaterialButton(
          leftText: 'Por días',
          rightText: 'Por categoría',
          leftSelected: showByDay,
          onPressedLeft: () {
            if (showByDay) {
              return;
            }
            currentWeekDataByDate();
          },
          onPressedRight: () async {
            if (!showByDay) {
              return;
            }
            await currentWeekDataByCategory(context);
          },
        ),
       
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                // width: width * 0.28,
                height: size.height * 0.3,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(235, 17, 22, 48),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text('Resumen',
                        style: TextStyle(color: Colors.white, fontSize: 22))
                  ],
                ),
              ),
            ),
            ChartCard(
              child: Container(
                  padding: const EdgeInsets.all(5),
                  width: width * 0.6,
                  height: size.height * 0.3,
                  child: !showByDay
                      ? MyBarChartCategory(
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
                          xAxisWidgetLabel: Text('Semana actual',
                              style: TextStyle(color: Colors.white)),
                          yAxisWidgetLabel: Text('Euros (€)',
                              style: TextStyle(color: Colors.white)),
                        )
                      : MyBarChart(
                          barChartType: BarChartType.weekDay,
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
                          xAxisWidgetLabel: Text('Semana actual',
                              style: TextStyle(color: Colors.white)),
                          yAxisWidgetLabel: Text('Euros (€)',
                              style: TextStyle(color: Colors.white)),
                        )),
            ),
          ],
        ),
      ],
    );
  }
}
