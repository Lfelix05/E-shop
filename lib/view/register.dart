import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../validator.dart';
import 'login.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 0.3;
    if (password.length < 10) return 0.6;
    return 1;
  }

  String _passwordStrengthLabel(String password) {
    final value = _passwordStrength(password);
    if (value <= 0.3) return 'Fraca';
    if (value <= 0.6) return 'Média';
    return 'Forte';
  }

  Color _passwordStrengthColor(String password) {
    final value = _passwordStrength(password);
    if (value <= 0.3) return Colors.red;
    if (value <= 0.6) return Colors.orange;
    return Colors.green;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('As senhas não coincidem.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final credential = await fire_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final newUser = User(
        id: credential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toJson());

      if (!mounted) return;
      _showMessage('Conta criada! Faça login para continuar.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    } on fire_auth.FirebaseAuthException catch (e) {
      var message = 'Não foi possível criar a conta.';
      if (e.code == 'email-already-in-use') {
        message = 'Este email já está em uso.';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca.';
      }
      _showMessage(message);
    } catch (_) {
      _showMessage('Ocorreu um erro inesperado.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final password = _passwordController.text;
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crie sua conta',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'É rápido e gratuito.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: NameValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: EmailValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: PasswordValidator.validate,
                  ),
                  if (password.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _passwordStrength(password),
                      backgroundColor: Colors.grey[300],
                      color: _passwordStrengthColor(password),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Força da senha: ${_passwordStrengthLabel(password)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _passwordStrengthColor(password),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: PasswordValidator.validate,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _register,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Registrar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginView(),
                            ),
                          ),
                    child: const Text('Já tem conta? Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
