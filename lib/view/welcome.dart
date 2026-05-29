import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';

import 'login.dart';
import 'main_shell.dart';
import 'register.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  Future<void> _continueAsGuest(BuildContext context) async {
    try {
      final credential = await fire_auth.FirebaseAuth.instance
          .signInAnonymously();
      final uid = credential.user?.uid;
      if (uid == null) {
        if (!context.mounted) return;
        _showError(context, 'Não foi possível autenticar anonimamente.');
        return;
      }
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainShell(userId: uid, userName: 'Visitante'),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, 'Erro ao entrar como visitante.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'E-Shop',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sua loja simples e completa',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: colors.primary,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      ),
                      child: const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      ),
                      child: const Text('Criar conta'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _continueAsGuest(context),
                      child: const Text('Continuar como visitante'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
