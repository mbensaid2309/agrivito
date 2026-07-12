import 'package:flutter/material.dart';

import '../models/agriculture_models.dart';
import '../services/agriculture_api_service.dart';

class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({required this.farm, required this.api, super.key});

  final FarmData farm;
  final AgricultureApi api;

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  List<FieldData> _fields = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fields = await widget.api.getFields(widget.farm.id);
      if (!mounted) return;
      setState(() => _fields = fields);
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createField() async {
    final draft = await showDialog<FieldData>(
      context: context,
      builder: (_) => _CreateFieldDialog(farmId: widget.farm.id),
    );
    if (draft == null) {
      return;
    }
    try {
      final field = await widget.api.createField(widget.farm.id, draft);
      if (!mounted) return;
      setState(() => _fields = [..._fields, field]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parcelle enregistrée.')),
      );
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.farm.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${widget.farm.locality}, ${widget.farm.region}'),
          if (widget.farm.totalArea != null)
            Text(
              'Surface totale : ${widget.farm.totalArea} ${widget.farm.areaUnit}',
            ),
          const SizedBox(height: 24),
          Text('Mes parcelles', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_error != null) ...[
            Text(_error!),
            TextButton.icon(
              onPressed: _loadFields,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
          if (!_isLoading && _error == null && _fields.isEmpty)
            const Text('Aucune parcelle enregistrée.'),
          for (final field in _fields)
            ListTile(
              leading: const Icon(Icons.landscape_outlined),
              title: Text(field.name),
              subtitle: Text(
                '${field.area} ${field.areaUnit} · Eau : ${field.waterAccess} · ${field.irrigationType}',
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLoading ? null : _createField,
            icon: const Icon(Icons.add),
            label: const Text('Créer une parcelle'),
          ),
        ],
      ),
    );
  }
}

class _CreateFieldDialog extends StatefulWidget {
  const _CreateFieldDialog({required this.farmId});

  final String farmId;

  @override
  State<_CreateFieldDialog> createState() => _CreateFieldDialogState();
}

class _CreateFieldDialogState extends State<_CreateFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _soil = TextEditingController();
  String _waterAccess = 'unknown';
  String _irrigation = 'unknown';

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _soil.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      FieldData(
        id: '',
        farmId: widget.farmId,
        name: _name.text.trim(),
        area: double.parse(_area.text),
        soilType: _soil.text.trim(),
        waterAccess: _waterAccess,
        irrigationType: _irrigation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une parcelle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Champ obligatoire'
                    : null,
              ),
              TextFormField(
                controller: _area,
                decoration: const InputDecoration(labelText: 'Surface (hectares)'),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'Surface invalide'
                    : null,
              ),
              TextFormField(
                controller: _soil,
                decoration: const InputDecoration(labelText: 'Type de sol'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _waterAccess,
                decoration: const InputDecoration(labelText: "Accès à l'eau"),
                items: const [
                  DropdownMenuItem(value: 'yes', child: Text('Oui')),
                  DropdownMenuItem(value: 'no', child: Text('Non')),
                  DropdownMenuItem(value: 'seasonal', child: Text('Saisonnier')),
                  DropdownMenuItem(value: 'unknown', child: Text('Non précisé')),
                ],
                onChanged: (value) => setState(() => _waterAccess = value!),
              ),
              DropdownButtonFormField<String>(
                initialValue: _irrigation,
                decoration: const InputDecoration(labelText: 'Irrigation'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Aucune')),
                  DropdownMenuItem(value: 'drip', child: Text('Goutte-à-goutte')),
                  DropdownMenuItem(value: 'sprinkler', child: Text('Aspersion')),
                  DropdownMenuItem(value: 'flood', child: Text('Submersion')),
                  DropdownMenuItem(value: 'manual', child: Text('Manuelle')),
                  DropdownMenuItem(value: 'unknown', child: Text('Non précisée')),
                ],
                onChanged: (value) => setState(() => _irrigation = value!),
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
