import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Text('Espace de question agricole a connecter au backend.'),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Votre question agricole',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
