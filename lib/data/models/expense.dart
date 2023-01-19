// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Expense {
  final String id;
  final String person;
  final String description;
  final String picture;
  final num price;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int deleted;
  Expense({
    this.id = "",
    required this.person,
    required this.description,
    this.picture = "",
    required this.price,
    required this.createdDate,
    required this.updatedDate,
    this.deleted = 0,
  });


  Expense copyWith({
    String? id,
    String? person,
    String? description,
    String? picture,
    num? price,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? deleted,
  }) {
    return Expense(
      id: id ?? this.id,
      person: person ?? this.person,
      description: description ?? this.description,
      picture: picture ?? this.picture,
      price: price ?? this.price,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'person': person,
      'description': description,
      'picture': picture,
      'price': price,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'deleted': deleted,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    print(map);
    return Expense(
      id: map['id'] as String,
      person: map['person'] as String,
      description: map['description'] as String,
      picture: map['picture'] as String,
      price: map['price'] as num,
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int).toLocal(),
      updatedDate: DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int).toLocal(),
      deleted: map['deleted'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Expense(id: $id, person: $person, description: $description, picture: $picture, price: $price, createdDate: $createdDate, updatedDate: $updatedDate, deleted: $deleted)';
  }

  @override
  bool operator ==(covariant Expense other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.person == person &&
      other.description == description &&
      other.picture == picture &&
      other.price == price &&
      other.createdDate == createdDate &&
      other.updatedDate == updatedDate &&
      other.deleted == deleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      person.hashCode ^
      description.hashCode ^
      picture.hashCode ^
      price.hashCode ^
      createdDate.hashCode ^
      updatedDate.hashCode ^
      deleted.hashCode;
  }
}
