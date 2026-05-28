import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login.dart';
import '../validator.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _passwordStrengthValue(String password) {
    if (password.isEmpty) {
      return 0;
    }
    if (password.length < 6) {
      return 0.3;
    }
    if (password.length < 10) {
      return 0.6;
    }
    return 1;
  }

  String _passwordStrengthLabel(String password) {
    final value = _passwordStrengthValue(password);
    if (value <= 0.3) {
      return 'Fraca';
    }
    if (value <= 0.6) {
      return 'Média';
    }
    return 'Forte';
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("As senhas não coincidem.")));
        return;
      }
      try {
        final userCredential = await fire_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        final newUser = User(
          id: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          profilePictureUrl: null,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toJson());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao registrar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: NameValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: EmailValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
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
                    obscureText: _obscurePassword,
                    validator: PasswordValidator.validate,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _passwordStrengthValue(_passwordController.text),
                    backgroundColor: Colors.grey[300],
                    color:
                        _passwordStrengthValue(_passwordController.text) <= 0.3
                        ? Colors.red
                        : _passwordStrengthValue(_passwordController.text) <=
                              0.6
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Força da senha: ${_passwordStrengthLabel(_passwordController.text)}',
                      style: TextStyle(
                        color:
                            _passwordStrengthValue(_passwordController.text) <=
                                0.3
                            ? Colors.red
                            : _passwordStrengthValue(
                                    _passwordController.text,
                                  ) <=
                                  0.6
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Senha',
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
                    obscureText: _obscurePassword,
                    validator: PasswordValidator.validate,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _register,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Registrar'),
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
