// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final int r;
  final int g;
  final int b;
  final int deleted;
  final DateTime createdDate;
  final DateTime updatedDate;
  Category({
    this.id = "",
    required this.name,
    required this.r,
    required this.g,
    required this.b,
    this.deleted = 0,
    required this.createdDate,
    required this.updatedDate,
  });

  Category copyWith({
    String? id,
    String? name,
    int? r,
    int? g,
    int? b,
    int? deleted,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      r: r ?? this.r,
      g: g ?? this.g,
      b: b ?? this.b,
      deleted: deleted ?? this.deleted,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'r': r,
      'g': g,
      'b': b,
      'deleted': deleted,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      r: map['r'] as int,
      g: map['g'] as int,
      b: map['b'] as int,
      deleted: map['deleted'] as int,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Category(id: $id, name: $name, r: $r, g: $g, b: $b, deleted: $deleted, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.r == r &&
        other.g == g &&
        other.b == b &&
        other.deleted == deleted &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        r.hashCode ^
        g.hashCode ^
        b.hashCode ^
        deleted.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode;
  }
}
