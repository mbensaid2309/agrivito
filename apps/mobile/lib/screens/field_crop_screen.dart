import 'package:flutter/material.dart';

import '../models/agriculture_models.dart';
import '../services/agriculture_api_service.dart';

class FieldCropScreen extends StatefulWidget {
  const FieldCropScreen({required this.api, super.key});

  static const routeName = '/field-crop';
  final AgricultureApi api;

  @override
  State<FieldCropScreen> createState() => _FieldCropScreenState();
}

class _FieldCropScreenState extends State<FieldCropScreen> {
  List<FieldData> _fields = [];
  List<CropData> _crops = [];
  Map<String, FieldCropData> _associations = {};
  String? _fieldId;
  String? _cropId;
  String? _error;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final farms = await widget.api.getFarms();
      final fieldGroups = await Future.wait(
        farms.map((farm) => widget.api.getFields(farm.id)),
      );
      final fields = fieldGroups.expand((group) => group).toList();
      final crops = await widget.api.getCrops();
      final associations = <String, FieldCropData>{};
      for (final field in fields) {
        final association = await widget.api.getFieldCrop(field.id);
        if (association != null) {
          associations[field.id] = association;
        }
      }
      if (!mounted) return;
      setState(() {
        _fields = fields;
        _crops = crops;
        _associations = associations;
      });
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _associate() async {
    if (_fieldId == null || _cropId == null) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final association = await widget.api.associateCrop(_fieldId!, _cropId!);
      if (!mounted) return;
      setState(
        () => _associations = {
          ..._associations,
          association.fieldId: association,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Culture associée à la parcelle.')),
      );
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  CropData? _cropById(String cropId) {
    for (final crop in _crops) {
      if (crop.id == cropId) {
        return crop;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Associer culture et parcelle')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) ...[
                  Text(_error!),
                  TextButton.icon(
                    onPressed: _loadContext,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
                if (_fields.isEmpty || _crops.isEmpty)
                  const Text(
                    "Créez d'abord une exploitation avec une parcelle et une culture.",
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _fieldId,
                    decoration: const InputDecoration(labelText: 'Parcelle'),
                    items: [
                      for (final field in _fields)
                        DropdownMenuItem(
                          value: field.id,
                          child: Text(field.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _fieldId = value),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _cropId,
                    decoration: const InputDecoration(labelText: 'Culture'),
                    items: [
                      for (final crop in _crops)
                        DropdownMenuItem(
                          value: crop.id,
                          child: Text(crop.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _cropId = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _fieldId != null && _cropId != null && !_isSaving
                        ? _associate
                        : null,
                    icon: const Icon(Icons.link),
                    label: Text(_isSaving ? 'Association...' : 'Associer'),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Associations actives',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_associations.isEmpty)
                  const Text('Aucune association active.'),
                for (final field in _fields)
                  if (_associations[field.id] case final association?)
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(field.name),
                      subtitle: Text(
                        _cropById(association.cropId)?.name ??
                            'Culture inconnue',
                      ),
                    ),
              ],
            ),
    );
  }
}
