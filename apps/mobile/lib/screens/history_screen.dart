import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text('Historique a connecter apres authentification.'),
      ),
    );
  }
}
