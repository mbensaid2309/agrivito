import 'package:flutter/material.dart';

import '../models/agriculture_models.dart';
import '../services/agriculture_api_service.dart';

class AgriculturalProfileScreen extends StatefulWidget {
  const AgriculturalProfileScreen({required this.api, super.key});

  static const routeName = '/agricultural-profile';
  final AgricultureApi api;

  @override
  State<AgriculturalProfileScreen> createState() =>
      _AgriculturalProfileScreenState();
}

class _AgriculturalProfileScreenState extends State<AgriculturalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _regionController = TextEditingController();
  String _userType = 'farmer';
  String _language = 'fr';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  FarmerProfileData? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await widget.api.getFarmerProfile();
      if (!mounted) return;
      if (profile != null) {
        _nameController.text = profile.displayName;
        _countryController.text = profile.country;
        _regionController.text = profile.region;
        _userType = profile.userType;
        _language = profile.preferredLanguage;
      }
      setState(() => _profile = profile);
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final saved = await widget.api.createFarmerProfile(
        FarmerProfileData(
          userId: 'mobile-user',
          displayName: _nameController.text.trim(),
          userType: _userType,
          country: _countryController.text.trim(),
          region: _regionController.text.trim(),
          preferredLanguage: _language,
        ),
      );
      if (!mounted) return;
      setState(() => _profile = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil agricole enregistré.')),
      );
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil agricole')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    _ErrorBanner(message: _error!, onRetry: _loadProfile),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom ou pseudo'),
                    validator: _required,
                    enabled: _profile == null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _userType,
                    decoration: const InputDecoration(labelText: "Type d'utilisateur"),
                    items: const [
                      DropdownMenuItem(value: 'farmer', child: Text('Agriculteur')),
                      DropdownMenuItem(value: 'advisor', child: Text('Conseiller')),
                      DropdownMenuItem(value: 'cooperative_member', child: Text('Membre de coopérative')),
                      DropdownMenuItem(value: 'unknown', child: Text('Non précisé')),
                    ],
                    onChanged: _profile == null
                        ? (value) => setState(() => _userType = value!)
                        : null,
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Pays'),
                    validator: _required,
                    enabled: _profile == null,
                  ),
                  TextFormField(
                    controller: _regionController,
                    decoration: const InputDecoration(labelText: 'Région'),
                    validator: _required,
                    enabled: _profile == null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _language,
                    decoration: const InputDecoration(labelText: 'Langue préférée'),
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'darija', child: Text('Darija')),
                      DropdownMenuItem(value: 'ar', child: Text('Arabe')),
                      DropdownMenuItem(value: 'en', child: Text('Anglais')),
                    ],
                    onChanged: _profile == null
                        ? (value) => setState(() => _language = value!)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_profile == null)
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
                    )
                  else
                    const Text('Profil synchronisé avec Agrivito.'),
                ],
              ),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
