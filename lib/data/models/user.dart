// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AppUser {
  final String firebaseUID;
  final String email;
  final String name;
  final DateTime createdDate;
  final DateTime updatedDate;
  AppUser({
    required this.firebaseUID,
    required this.email,
    required this.name,
    required this.createdDate,
    required this.updatedDate,
  });

  AppUser copyWith({
    String? firebaseUID,
    String? email,
    String? name,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return AppUser(
      firebaseUID: firebaseUID ?? this.firebaseUID,
      email: email ?? this.email,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firebaseUID': firebaseUID,
      'email': email,
      'name': name,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      firebaseUID: map['firebaseUID'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AppUser( firebaseUID: $firebaseUID, email: $email, name: $name, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant AppUser other) {
    if (identical(this, other)) return true;

    return other.firebaseUID == firebaseUID &&
        other.email == email &&
        other.name == name &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return firebaseUID.hashCode ^
        email.hashCode ^
        name.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode;
  }
}
