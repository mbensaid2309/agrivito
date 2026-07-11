import 'package:flutter/material.dart';

import '../services/agriculture_store.dart';

class FieldCropScreen extends StatefulWidget {
  const FieldCropScreen({super.key});

  static const routeName = '/field-crop';

  @override
  State<FieldCropScreen> createState() => _FieldCropScreenState();
}

class _FieldCropScreenState extends State<FieldCropScreen> {
  String? _fieldId;
  String? _cropId;

  void _associate() {
    if (_fieldId == null || _cropId == null) {
      return;
    }
    setState(() => AgricultureStore.instance.cropByField[_fieldId!] = _cropId!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Culture associée à la parcelle.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AgricultureStore.instance;
    final associationTiles = store.fields.map((field) {
      final crop = store.cropForField(field.id);
      if (crop == null) {
        return const SizedBox.shrink();
      }
      return ListTile(
        leading: const Icon(Icons.link),
        title: Text(field.name),
        subtitle: Text(crop.name),
      );
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Associer culture et parcelle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (store.fields.isEmpty || store.crops.isEmpty)
            const Text(
              "Créez d'abord une exploitation avec une parcelle et une culture.",
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _fieldId,
              decoration: const InputDecoration(labelText: 'Parcelle'),
              items: [
                for (final field in store.fields)
                  DropdownMenuItem(value: field.id, child: Text(field.name)),
              ],
              onChanged: (value) => setState(() => _fieldId = value),
            ),
            DropdownButtonFormField<String>(
              initialValue: _cropId,
              decoration: const InputDecoration(labelText: 'Culture'),
              items: [
                for (final crop in store.crops)
                  DropdownMenuItem(value: crop.id, child: Text(crop.name)),
              ],
              onChanged: (value) => setState(() => _cropId = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fieldId != null && _cropId != null ? _associate : null,
              icon: const Icon(Icons.link),
              label: const Text('Associer'),
            ),
          ],
          const SizedBox(height: 24),
          Text('Associations actives', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (store.cropByField.isEmpty) const Text('Aucune association active.'),
          ...associationTiles,
        ],
      ),
    );
  }
}
