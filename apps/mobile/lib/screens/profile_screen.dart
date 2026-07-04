import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 32, child: Icon(Icons.person_outline)),
            SizedBox(height: 16),
            Text('Profil utilisateur Sprint 1'),
            SizedBox(height: 8),
            Text('Cognito via Amplify Auth sera integre dans un sprint futur.'),
          ],
        ),
      ),
    );
  }
}
