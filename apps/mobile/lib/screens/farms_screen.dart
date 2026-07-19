import 'package:flutter/material.dart';

import '../models/agriculture_models.dart';
import '../services/agriculture_api_service.dart';
import 'farm_detail_screen.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({required this.api, super.key});

  static const routeName = '/farms';
  final AgricultureApi api;

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  List<FarmData> _farms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final farms = await widget.api.getFarms();
      if (!mounted) return;
      setState(() => _farms = farms);
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createFarm() async {
    final draft = await showDialog<FarmData>(
      context: context,
      builder: (_) => const _CreateFarmDialog(),
    );
    if (draft == null) {
      return;
    }
    try {
      final farm = await widget.api.createFarm(draft);
      if (!mounted) return;
      setState(() => _farms = [..._farms, farm]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exploitation enregistrée.')),
      );
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes exploitations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadFarms)
          : _farms.isEmpty
          ? const Center(child: Text('Aucune exploitation enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _farms.length,
              itemBuilder: (context, index) {
                final farm = _farms[index];
                return ListTile(
                  leading: const Icon(Icons.agriculture_outlined),
                  title: Text(farm.name),
                  subtitle: Text('${farm.locality}, ${farm.region}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          FarmDetailScreen(farm: farm, api: widget.api),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Créer une exploitation',
        onPressed: _isLoading ? null : _createFarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateFarmDialog extends StatefulWidget {
  const _CreateFarmDialog();

  @override
  State<_CreateFarmDialog> createState() => _CreateFarmDialogState();
}

class _CreateFarmDialogState extends State<_CreateFarmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _country = TextEditingController();
  final _region = TextEditingController();
  final _locality = TextEditingController();
  final _area = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _region.dispose();
    _locality.dispose();
    _area.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      FarmData(
        id: '',
        name: _name.text.trim(),
        country: _country.text.trim(),
        region: _region.text.trim(),
        locality: _locality.text.trim(),
        totalArea: double.tryParse(_area.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une exploitation'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: _required,
              ),
              TextFormField(
                controller: _country,
                decoration: const InputDecoration(labelText: 'Pays'),
                validator: _required,
              ),
              TextFormField(
                controller: _region,
                decoration: const InputDecoration(labelText: 'Région'),
                validator: _required,
              ),
              TextFormField(
                controller: _locality,
                decoration: const InputDecoration(
                  labelText: 'Commune / localité',
                ),
                validator: _required,
              ),
              TextFormField(
                controller: _area,
                decoration: const InputDecoration(
                  labelText: 'Surface totale (hectares)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
