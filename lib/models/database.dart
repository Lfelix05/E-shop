import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'user.dart';
import 'adress.dart';

class Database {
  static Future<User> addUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final users = firestore.FirebaseFirestore.instance.collection('users');
      final newDoc = users.doc();
      final user = User(
        id: newDoc.id,
        name: name,
        email: email,
        wishList: [],
        password: password,
      );
      await newDoc.set(user.toJson());
      return user;
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      throw Exception('Erro ao adicionar usuário');
    }
  }

  static Future<User?> getUserById(String userId) async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  static Future<void> createUser(User user) async {
    try {
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      print('Erro ao criar usuário: $e');
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return User.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  static Future<Adress?> addAdressToUser(String userId, Adress address) async {
    try {
      final addressesCollection = firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('adresses');

      await addressesCollection.add(address.toJson());

      return Adress(
        userId: userId,
        street: address.street,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        country: address.country,
      );
    } catch (e) {
      print('Erro ao adicionar endereço ao usuário: $e');
      return null;
    }
  }
}
