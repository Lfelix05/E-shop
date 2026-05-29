import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? password;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
  });

  String? get hashedPassword {
    if (password == null) return null;
    final bytes = utf8.encode(password!);
    return sha256.convert(bytes).toString();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'password': hashedPassword};
  }
}
