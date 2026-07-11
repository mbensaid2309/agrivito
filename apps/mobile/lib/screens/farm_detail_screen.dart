import 'package:flutter/material.dart';

import '../services/agriculture_store.dart';

class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({required this.farm, super.key});

  final FarmData farm;

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  Future<void> _createField() async {
    final field = await showDialog<FieldData>(
      context: context,
      builder: (_) => _CreateFieldDialog(farmId: widget.farm.id),
    );
    if (field != null) {
      setState(() => AgricultureStore.instance.fields.add(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = AgricultureStore.instance.fieldsForFarm(widget.farm.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.farm.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${widget.farm.locality}, ${widget.farm.region}'),
          if (widget.farm.totalArea != null)
            Text('Surface totale : ${widget.farm.totalArea} ha'),
          const SizedBox(height: 24),
          Text('Mes parcelles', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (fields.isEmpty) const Text('Aucune parcelle enregistrée.'),
          for (final field in fields)
            ListTile(
              leading: const Icon(Icons.landscape_outlined),
              title: Text(field.name),
              subtitle: Text(
                '${field.area} ha · Eau : ${field.waterAccess} · ${field.irrigationType}',
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _createField,
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
    final store = AgricultureStore.instance;
    Navigator.of(context).pop(
      FieldData(
        id: store.nextId(),
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
                decoration: const InputDecoration(labelText: 'Surface (ha)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    double.tryParse(value ?? '') == null ? 'Surface invalide' : null,
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
