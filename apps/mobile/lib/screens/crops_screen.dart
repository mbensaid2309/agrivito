import 'package:flutter/material.dart';

import '../models/agriculture_models.dart';
import '../services/agriculture_api_service.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({required this.api, super.key});

  static const routeName = '/crops';
  final AgricultureApi api;

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  List<CropData> _crops = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final crops = await widget.api.getCrops();
      if (!mounted) return;
      setState(() => _crops = crops);
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createCrop() async {
    final draft = await showDialog<CropData>(
      context: context,
      builder: (_) => const _CreateCropDialog(),
    );
    if (draft == null) {
      return;
    }
    try {
      final crop = await widget.api.createCrop(draft);
      if (!mounted) return;
      setState(() => _crops = [..._crops, crop]);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Culture enregistrée.')));
    } on AgricultureApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes cultures')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _crops.isEmpty
          ? const Center(child: Text('Aucune culture enregistrée.'))
          : RefreshIndicator(
              onRefresh: _loadCrops,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _crops.length,
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  return ListTile(
                    leading: const Icon(Icons.grass_outlined),
                    title: Text(crop.name),
                    subtitle: Text('${crop.category} · ${crop.growthStage}'),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Créer une culture',
        onPressed: _isLoading ? null : _createCrop,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateCropDialog extends StatefulWidget {
  const _CreateCropDialog();

  @override
  State<_CreateCropDialog> createState() => _CreateCropDialogState();
}

class _CreateCropDialogState extends State<_CreateCropDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _variety = TextEditingController();
  String _category = 'unknown';
  String _growthStage = 'unknown';

  @override
  void dispose() {
    _name.dispose();
    _variety.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      CropData(
        id: '',
        name: _name.text.trim(),
        category: _category,
        variety: _variety.text.trim(),
        growthStage: _growthStage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une culture'),
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
                controller: _variety,
                decoration: const InputDecoration(labelText: 'Variété'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: const [
                  DropdownMenuItem(value: 'vegetable', child: Text('Légume')),
                  DropdownMenuItem(
                    value: 'fruit_tree',
                    child: Text('Arbre fruitier'),
                  ),
                  DropdownMenuItem(value: 'cereal', child: Text('Céréale')),
                  DropdownMenuItem(value: 'legume', child: Text('Légumineuse')),
                  DropdownMenuItem(
                    value: 'industrial_crop',
                    child: Text('Culture industrielle'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                  DropdownMenuItem(
                    value: 'unknown',
                    child: Text('Non précisée'),
                  ),
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              DropdownButtonFormField<String>(
                initialValue: _growthStage,
                decoration: const InputDecoration(
                  labelText: 'Stade de culture',
                ),
                items: const [
                  DropdownMenuItem(value: 'seedling', child: Text('Plantule')),
                  DropdownMenuItem(
                    value: 'vegetative',
                    child: Text('Végétatif'),
                  ),
                  DropdownMenuItem(
                    value: 'flowering',
                    child: Text('Floraison'),
                  ),
                  DropdownMenuItem(
                    value: 'fruiting',
                    child: Text('Fructification'),
                  ),
                  DropdownMenuItem(value: 'harvest', child: Text('Récolte')),
                  DropdownMenuItem(
                    value: 'post_harvest',
                    child: Text('Après récolte'),
                  ),
                  DropdownMenuItem(
                    value: 'unknown',
                    child: Text('Non précisé'),
                  ),
                ],
                onChanged: (value) => setState(() => _growthStage = value!),
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
