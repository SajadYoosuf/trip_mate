import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int points;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.points = 0,
  });

  @override
  List<Object?> get props => [id, name, email, phone, photoUrl, points];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    int? points,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'points': points,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      points: map['points'] ?? 0,
    );
  }
}
