import 'dart:crypto';
import 'dart:convert';

class User {
  String name;
  String email;
  String password;

  String? hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  User({required this.name, required this.email, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: hashPassword(json['password']),
    );
  }
}
