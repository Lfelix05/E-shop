import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';

import 'adress.dart';

/// Acesso ao Firestore para os dados do app.
///
/// Hoje só guardamos o endereço de entrega do usuário. Login e cadastro usam
/// o Firebase Auth diretamente nas telas correspondentes.
class Database {
  /// Salva (cria ou atualiza) o endereço do usuário.
  ///
  /// Guardamos um único endereço por usuário em `addresses/{userId}`, o que
  /// funciona tanto para contas registradas quanto para visitantes anônimos.
  static Future<void> saveAddress(String userId, Adress address) async {
    await firestore.FirebaseFirestore.instance
        .collection('addresses')
        .doc(userId)
        .set(address.toJson());
  }

  /// Carrega o endereço salvo do usuário, ou `null` se ainda não houver um.
  static Future<Adress?> getAddress(String userId) async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('addresses')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Adress.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar endereço: $e');
      return null;
    }
  }
}
