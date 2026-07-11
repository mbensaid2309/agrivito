import 'package:flutter/material.dart';

import '../services/agriculture_store.dart';
import 'farm_detail_screen.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({super.key});

  static const routeName = '/farms';

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  Future<void> _createFarm() async {
    final farm = await showDialog<FarmData>(
      context: context,
      builder: (_) => const _CreateFarmDialog(),
    );
    if (farm != null) {
      setState(() => AgricultureStore.instance.farms.add(farm));
    }
  }

  @override
  Widget build(BuildContext context) {
    final farms = AgricultureStore.instance.farms;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes exploitations')),
      body: farms.isEmpty
          ? const Center(child: Text('Aucune exploitation enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: farms.length,
              itemBuilder: (context, index) {
                final farm = farms[index];
                return ListTile(
                  leading: const Icon(Icons.agriculture_outlined),
                  title: Text(farm.name),
                  subtitle: Text('${farm.locality}, ${farm.region}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FarmDetailScreen(farm: farm),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Créer une exploitation',
        onPressed: _createFarm,
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
    final store = AgricultureStore.instance;
    Navigator.of(context).pop(
      FarmData(
        id: store.nextId(),
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
                decoration: const InputDecoration(labelText: 'Commune / localité'),
                validator: _required,
              ),
              TextFormField(
                controller: _area,
                decoration: const InputDecoration(labelText: 'Surface totale (ha)'),
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
