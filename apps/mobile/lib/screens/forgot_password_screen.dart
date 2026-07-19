import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _message = 'Saisissez une adresse email valide.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    final result = await widget.authService.resetPassword(email);
    if (mounted) {
      setState(() {
        _loading = false;
        _message = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mot de passe oublié')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Recevoir un lien de réinitialisation'),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: Text(_loading ? 'Envoi...' : 'Envoyer le lien'),
        ),
        if (_message != null) ...[const SizedBox(height: 12), Text(_message!)],
      ],
    ),
  );
}
