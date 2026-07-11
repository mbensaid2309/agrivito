import 'package:flutter/material.dart';

import '../services/agriculture_store.dart';

class AgriculturalProfileScreen extends StatefulWidget {
  const AgriculturalProfileScreen({super.key});

  static const routeName = '/agricultural-profile';

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

  @override
  void initState() {
    super.initState();
    final profile = AgricultureStore.instance.profile;
    if (profile != null) {
      _nameController.text = profile.displayName;
      _countryController.text = profile.country;
      _regionController.text = profile.region;
      _userType = profile.userType;
      _language = profile.preferredLanguage;
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

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      AgricultureStore.instance.profile = FarmerProfileData(
        displayName: _nameController.text.trim(),
        userType: _userType,
        country: _countryController.text.trim(),
        region: _regionController.text.trim(),
        preferredLanguage: _language,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil agricole enregistré.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil agricole')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom ou pseudo'),
              validator: _required,
            ),
            DropdownButtonFormField<String>(
              initialValue: _userType,
              decoration: const InputDecoration(labelText: "Type d'utilisateur"),
              items: const [
                DropdownMenuItem(value: 'farmer', child: Text('Agriculteur')),
                DropdownMenuItem(value: 'advisor', child: Text('Conseiller')),
                DropdownMenuItem(
                  value: 'cooperative_member',
                  child: Text('Membre de coopérative'),
                ),
                DropdownMenuItem(value: 'unknown', child: Text('Non précisé')),
              ],
              onChanged: (value) => setState(() => _userType = value!),
            ),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Pays'),
              validator: _required,
            ),
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(labelText: 'Région'),
              validator: _required,
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
              onChanged: (value) => setState(() => _language = value!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
