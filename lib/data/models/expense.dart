// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:gastos/data/models/category.dart';

class Expense {
  final String id;
  final String personFirebaseUID;
  final String person;
  final String description;
  final String picture;
  final num price;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int deleted;
  final String category;
  final int isCommonExpense;
  Expense({
    this.id  ="",
    this.personFirebaseUID = "",
    required this.person,
    required this.description,
    this.picture = "",
    required this.price,
    required this.createdDate,
    required this.updatedDate,
    this.deleted = 0,
    this.category = "",
    this.isCommonExpense = 1,
  });


  Expense copyWith({
    String? id,
    String? personFirebaseUID,
    String? person,
    String? description,
    String? picture,
    num? price,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? deleted,
    String? category,
    int? isCommonExpense,
  }) {
    return Expense(
      id: id ?? this.id,
      personFirebaseUID: personFirebaseUID ?? this.personFirebaseUID,
      person: person ?? this.person,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      price: price ?? this.price,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      deleted: deleted ?? this.deleted,
      category: category ?? this.category,
      isCommonExpense: isCommonExpense ?? this.isCommonExpense,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'personFirebaseUID': personFirebaseUID,
      'person': person,
      'description': description,
      'picture': picture,
      'price': price,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'deleted': deleted,
      'category': category,
      'isCommonExpense': isCommonExpense,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      personFirebaseUID: map['personFirebaseUID'] ?? '',
      person: map['person'] as String,
      description: map['description'] as String,
      picture: map['picture'] as String,
      price: map['price'] as num,
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      updatedDate: DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
      deleted: map['deleted'] as int,
      category: map['category'] as String,
      isCommonExpense: map['isCommonExpense'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Expense(id: $id, personFirebaseUID: $personFirebaseUID, person: $person, description: $description, picture: $picture, price: $price, createdDate: $createdDate, updatedDate: $updatedDate, deleted: $deleted, category: $category, isCommonExpense: $isCommonExpense)';
  }

  @override
  bool operator ==(covariant Expense other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.personFirebaseUID == personFirebaseUID &&
      other.person == person &&
      other.description == description &&
      other.picture == picture &&
      other.price == price &&
      other.createdDate == createdDate &&
      other.updatedDate == updatedDate &&
      other.deleted == deleted &&
      other.category == category &&
      other.isCommonExpense == isCommonExpense;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      personFirebaseUID.hashCode ^
      person.hashCode ^
      description.hashCode ^
      picture.hashCode ^
      price.hashCode ^
      createdDate.hashCode ^
      updatedDate.hashCode ^
      deleted.hashCode ^
      category.hashCode ^
      isCommonExpense.hashCode;
  }
}
