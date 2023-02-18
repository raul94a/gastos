import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/utils/date_formatter.dart';

enum BarChartType { weekDay, weekCategory, monthDay, monthCategory, yearMonth }

class MyBarChart extends StatelessWidget {
  const MyBarChart(
      {required this.data,
      required this.barChartType,
      this.maxY,
      this.xAxisWidgetLabel,
      this.yAxisWidgetLabel,
      required this.xAxisTextStyle,
      required this.yAxisTextStyle});

  final List<BarChartGroupData> data;
  final double? maxY;
  final BarChartType barChartType;
  final TextStyle xAxisTextStyle;
  final TextStyle yAxisTextStyle;
  final Widget? xAxisWidgetLabel;
  final Widget? yAxisWidgetLabel;

  @override
  Widget build(BuildContext context) {
    late FlTitlesData mTitlesData;
    BarChartAlignment alignment = BarChartAlignment.spaceEvenly;
    if (barChartType == BarChartType.weekDay) {
      mTitlesData = titlesData;
    } else if (barChartType == BarChartType.monthDay) {
      mTitlesData = _monthDaysTitleData;
    } else if (barChartType == BarChartType.yearMonth) {
      mTitlesData = _yearMonthsTitleData;
      // alignment = BarChartAlignment.spaceBetween;
    } else {
      mTitlesData = titlesData;
    }
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: mTitlesData,
        borderData: borderData,
        barGroups: data,
        maxY: maxY,
        gridData: FlGridData(show: false),
        alignment: alignment,
      ),
    );
  }

  FlTitlesData get _yearMonthsTitleData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: xAxisWidgetLabel,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitlesYearMonths,
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
          tooltipMargin: 2.0,
          // fitInsideVertically: true,
          
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

  Widget getTitles(double value, TitleMeta meta) {
    final style = xAxisTextStyle;
    String text;
    switch (value.toInt()) {
      case 2:
        text = 'M';
        break;
      case 3:
        text = 'X';
        break;
      case 4:
        text = 'J';
        break;
      case 5:
        text = 'V';
        break;
      case 6:
        text = 'S';
        break;
      case 7:
        text = 'D';
        break;
      default:
        text = 'L';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
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

  FlBorderData get borderData => FlBorderData(
        show: false,
      );
}
