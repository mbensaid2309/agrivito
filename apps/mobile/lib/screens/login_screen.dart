import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Mot de passe',
              ),
            ),
            SizedBox(height: 16),
            FilledButton(
              onPressed: null,
              child: Text('Connexion bientot disponible'),
            ),
          ],
        ),
      ),
    );
  }
}
