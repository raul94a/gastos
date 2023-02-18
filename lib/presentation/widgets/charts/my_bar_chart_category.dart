import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/chart_models/category_expenses.dart';
import 'package:gastos/utils/date_formatter.dart';

enum BarChartCategoryType { weekCategory, monthCategory, yearCategory }

class MyBarChartCategory extends StatelessWidget {
  const MyBarChartCategory(
      {required this.data,
      required this.barChartType,
      this.maxY,
      this.xAxisWidgetLabel,
      this.yAxisWidgetLabel,
      required this.categoriesExpenses,
      required this.xAxisTextStyle,
      required this.yAxisTextStyle});

  final List<BarChartGroupData> data;
  final double? maxY;
  final BarChartCategoryType barChartType;
  final TextStyle xAxisTextStyle;
  final TextStyle yAxisTextStyle;
  final Widget? xAxisWidgetLabel;
  final Widget? yAxisWidgetLabel;
  final List<CategoryExpenses> categoriesExpenses;

  @override
  Widget build(BuildContext context) {
    BarChartAlignment alignment = BarChartAlignment.spaceEvenly;

    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: data,
        maxY: maxY,
        gridData: FlGridData(show: false),
        alignment: alignment,
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = xAxisTextStyle;
    int val = value.toInt();

    String text =
        categoriesExpenses.firstWhere((element) => element.index == val).name!;

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text.substring(0, getEndSubstringLength(text)), style: style),
    );
  }

  int getEndSubstringLength(String text) {
    const nrLettersToShow = 8;
    if (text.isEmpty) {
      return 0;
    }
    int textLength = text.length;
    bool goodLength = textLength >= nrLettersToShow;
    if (goodLength) {
      return nrLettersToShow;
    }
    return textLength - 1;
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: xAxisWidgetLabel,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: yAxisWidgetLabel,
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget getTitlesYearMonths(double value, TitleMeta meta) {
    final style = xAxisTextStyle;
    String text = MyDateFormatter.monthThreeLetters(
        value.toInt() < 10 ? "0${value.toInt()}" : "${value.toInt()}");

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get _monthDaysTitleData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: xAxisWidgetLabel,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 20,
            getTitlesWidget: getTitlesMonthDays,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: yAxisWidgetLabel,
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget getTitlesMonthDays(double value, TitleMeta meta) {
    final style = xAxisTextStyle;
    int val = value.toInt();
    bool isMultipleOfTwo = val % 2 == 0;
    String text = isMultipleOfTwo ? '' : val.toString();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      // angle: 0.5,
      child: Text(text, style: style),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 20.0,
          fitInsideVertically: true,
          direction: TooltipDirection.top,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(rod.toY.round().toString(), yAxisTextStyle);
          },
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );
}
