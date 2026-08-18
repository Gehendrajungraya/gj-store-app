import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> submit() async {
    final trimmedEmail = email.text.trim();
    final trimmedPassword = password.text.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      setState(() => error = 'Please enter your email and password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = await AuthService.login(trimmedEmail, trimmedPassword);
      if (!mounted) return;
      if (token == null) {
        setState(() => error = 'Login failed. Please check your email and password.');
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Login error: $e');
        setState(() => error = e is Exception ? e.toString() : 'Login failed. Please check your email and password.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.storefront, size: 70),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : submit,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}
