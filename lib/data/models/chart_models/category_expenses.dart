// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryExpenses {

  final String category;
  final int index;
  final num price;
  final String? name;
  CategoryExpenses({
    this.name,
    required this.category,
    required this.index,
    required this.price,
  });



 BarChartGroupData generateBarcharDataWeekDay(
      {Gradient? gradient, double? maxY}) {
    return BarChartGroupData(
      x: index,
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
  

  CategoryExpenses copyWith({
    String? category,
    String?name,
    int? index,
    num? price,
  }) {
    return CategoryExpenses(
      name: name ?? this.name,
      category: category ?? this.category,
      index: index ?? this.index,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category,
      'index': index,
      'price': price,
    };
  }

  factory CategoryExpenses.fromMap(Map<String, dynamic> map) {
    return CategoryExpenses(
      category: map['category'] ?? "",
      index: map['index'] ?? -1,
      price: map['price'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryExpenses.fromJson(String source) => CategoryExpenses.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CategoryExpenses(category: $category, index: $index, price: $price)';

  @override
  bool operator ==(covariant CategoryExpenses other) {
    if (identical(this, other)) return true;
  
    return 
      other.category == category &&
      other.index == index &&
      other.price == price;
  }

  @override
  int get hashCode => category.hashCode ^ index.hashCode ^ price.hashCode;
}
