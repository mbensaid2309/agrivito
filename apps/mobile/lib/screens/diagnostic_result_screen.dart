import 'package:flutter/material.dart';

class DiagnosticResultScreen extends StatelessWidget {
  static const routeName = '/diagnostic-result';

  const DiagnosticResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultat du diagnostic')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Diagnostic Agrivito',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.chat_outlined),
            title: Text('Diagnostic texte structure'),
            subtitle: Text(
              'Les resultats generes depuis le Chat apparaissent directement '
              'dans la conversation.',
            ),
          ),
        ],
      ),
    );
  }
}
