import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'farms_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    await widget.authService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil authentifié')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person_outline)),
            const SizedBox(height: 16),
            Text(user?.email ?? 'Aucune session active'),
            const SizedBox(height: 8),
            Text(user == null ? 'Non authentifié' : 'Session authentifiée'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () =>
                        Navigator.of(context).pushNamed(FarmsScreen.routeName),
              child: const Text('Accéder à mes données privées'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: user == null ? null : _signOut,
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
