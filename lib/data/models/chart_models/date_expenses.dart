// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:gastos/utils/date_formatter.dart';

class DateExpenses {
  const DateExpenses({
    required this.date,
    required this.price,
  });

  final String date;
  final num price;

  DateTime get dateTime {
    return MyDateFormatter.fromYYYYMMdd(date);
  }

  int get weekDay => dateTime.weekday;
  int get monthDay => dateTime.day;

  BarChartGroupData generateBarcharDataWeekDay(
      {Gradient? gradient, double? maxY}) {
    return BarChartGroupData(
      x: weekDay,
      barRods: [
        BarChartRodData(
          width: 20,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: const Color.fromARGB(66, 202, 202, 202),
          ),
          toY: price.toDouble(),
          gradient: gradient,
        )
      ],
      showingTooltipIndicators:  price.toInt() == 0 ? [] : [0],
    );
  }

  BarChartGroupData generateBarcharDataMonthDay(
      {Gradient? gradient, double? maxY}) {
    return BarChartGroupData(
      x: monthDay,
      barsSpace: 12,
      barRods: [
        BarChartRodData(
          
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: const Color.fromARGB(66, 202, 202, 202),
          ),
          // width: 5,
          toY: price.toDouble(),
          gradient: gradient,
        )
      ],
      showingTooltipIndicators: price.toInt() == 0 ? [] : [0],
    );
  }

  @override
  String toString() => 'DateExpenses(date: $date, price: $price)';

  DateExpenses copyWith({
    String? date,
    num? price,
  }) {
    return DateExpenses(
      date: date ?? this.date,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'price': price,
    };
  }

  factory DateExpenses.fromMap(Map<String, dynamic> map) {
    return DateExpenses(
      date: map['date'],
      price: map['price'] ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DateExpenses.fromJson(String source) =>
      DateExpenses.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant DateExpenses other) {
    if (identical(this, other)) return true;

    return other.date == date && other.price == price;
  }

  @override
  int get hashCode => date.hashCode ^ price.hashCode;
}
