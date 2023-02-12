import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gastos/utils/date_formatter.dart';

class YearExpenses {
  final num price;
  final String date;
  final String month;
  YearExpenses({
    required this.price,
    required this.date,
    required this.month,
  });
  DateTime get dateTime {
    return MyDateFormatter.fromYYYYMMdd(date);
  }

  int get weekDay => dateTime.weekday;
  int get monthDay => dateTime.day;

  YearExpenses copyWith({
    num? price,
    String? date,
    String? month,
  }) {
    return YearExpenses(
      price: price ?? this.price,
      date: date ?? this.date,
      month: month ?? this.month,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'date': date,
      'month': month,
    };
  }

  factory YearExpenses.fromMap(Map<String, dynamic> map) {
    return YearExpenses(
      price: map['price'] as num,
      date: map['date'] as String,
      month: map['month'] as String,
    );
  }
  BarChartGroupData generateBarcharDataWeekDay({Gradient? gradient, double? maxY}) {
    return BarChartGroupData(
      x: dateTime.month,
      barRods: [
        BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: const Color.fromARGB(66, 202, 202, 202),
          ),
          toY: price.toDouble(),
          gradient: gradient,
        )
      ],
      showingTooltipIndicators: price.toInt() == 0 ? [] : [0],
    );
  }

  String toJson() => json.encode(toMap());

  factory YearExpenses.fromJson(String source) =>
      YearExpenses.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'YearExpenses(price: $price, date: $date, month: $month)';

  @override
  bool operator ==(covariant YearExpenses other) {
    if (identical(this, other)) return true;

    return other.price == price && other.date == date && other.month == month;
  }

  @override
  int get hashCode => price.hashCode ^ date.hashCode ^ month.hashCode;
}
