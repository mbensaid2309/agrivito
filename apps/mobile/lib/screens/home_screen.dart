import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../widgets/demo_mode_banner.dart';
import 'agricultural_profile_screen.dart';
import 'chat_screen.dart';
import 'crops_screen.dart';
import 'farms_screen.dart';
import 'field_crop_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'photo_upload_screen.dart';
import 'photo_diagnosis_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({
    super.key,
    this.enableHealthCheck = true,
    this.authService = const UnavailableAuthService(),
  });

  final bool enableHealthCheck;
  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _backendStatus = 'Statut backend non verifie';
  bool _isChecking = false;

  Future<void> _checkBackend() async {
    setState(() {
      _isChecking = true;
      _backendStatus = 'Verification du backend...';
    });

    try {
      final response = await http
          .get(Uri.parse('${AppConfig.backendBaseUrl}/health'))
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          _backendStatus = 'Backend indisponible (${response.statusCode}).';
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'];
      final service = body['service'];

      setState(() {
        _backendStatus = 'Backend $service: $status';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _backendStatus =
            'Backend indisponible. Verifiez que l API FastAPI est lancee.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.enableHealthCheck) {
      _checkBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agrivito')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DemoModeBanner(),
            if (AppConfig.demoMode) const SizedBox(height: 16),
            Text(
              'Assistance agricole intelligente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Posez une question, analysez une photo et organisez votre '
              'contexte agricole dans un parcours simple et prudent.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('home-discovery'),
              onPressed: () =>
                  Navigator.of(context).pushNamed(ChatScreen.routeName),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Essayer sans compte'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(LoginScreen.routeName),
                    icon: const Icon(Icons.login),
                    label: const Text('Se connecter'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(RegisterScreen.routeName),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Créer un compte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.authService.hasSession
                  ? 'Session connectée · accès aux données privées'
                  : 'Mode découverte · aucune connexion requise',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_isChecking ? Icons.sync : Icons.cloud_done_outlined),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_backendStatus)),
                    IconButton(
                      tooltip: 'Verifier le backend',
                      onPressed: _isChecking ? null : _checkBackend,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Actions principales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _NavigationButton(
              icon: Icons.chat_outlined,
              label: 'Poser une question',
              routeName: ChatScreen.routeName,
            ),
            const _NavigationButton(
              icon: Icons.add_a_photo_outlined,
              label: 'Analyser une photo',
              routeName: PhotoUploadScreen.routeName,
            ),
            const _NavigationButton(
              icon: Icons.image_search_outlined,
              label: 'Ouvrir un diagnostic photo',
              routeName: PhotoDiagnosisScreen.routeName,
            ),
            const SizedBox(height: 8),
            Text(
              'Mon contexte agricole',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _NavigationButton(
              icon: Icons.badge_outlined,
              label: 'Profil agricole',
              routeName: AgriculturalProfileScreen.routeName,
            ),
            const _NavigationButton(
              icon: Icons.agriculture_outlined,
              label: 'Mes exploitations',
              routeName: FarmsScreen.routeName,
            ),
            const _NavigationButton(
              icon: Icons.grass_outlined,
              label: 'Mes cultures',
              routeName: CropsScreen.routeName,
            ),
            const _NavigationButton(
              icon: Icons.link,
              label: 'Associer culture et parcelle',
              routeName: FieldCropScreen.routeName,
            ),
            const SizedBox(height: 8),
            const _NavigationButton(
              icon: Icons.person_outline,
              label: 'Mon compte',
              routeName: ProfileScreen.routeName,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(routeName),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
