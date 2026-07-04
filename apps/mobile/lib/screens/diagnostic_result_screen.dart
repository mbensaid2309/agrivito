import 'package:flutter/material.dart';

class DiagnosticResultScreen extends StatelessWidget {
  static const routeName = '/diagnostic-result';

  const DiagnosticResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Trust Score',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.speed_outlined),
            title: Text('70 / 100'),
            subtitle: Text('Niveau moyen - Score provisoire MVP.'),
          ),
          SizedBox(height: 16),
          Text('Le diagnostic IA reel sera implemente dans un sprint ulterieur.'),
        ],
      ),
    );
  }
}
