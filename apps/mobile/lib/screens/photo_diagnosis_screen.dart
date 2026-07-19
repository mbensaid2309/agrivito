import 'package:flutter/material.dart';

import '../models/ai_diagnosis_models.dart';
import '../models/media_models.dart';
import '../models/photo_diagnosis_models.dart';
import '../services/photo_diagnosis_api_service.dart';

class PhotoDiagnosisScreen extends StatefulWidget {
  static const routeName = '/photo-diagnosis';

  const PhotoDiagnosisScreen({
    super.key,
    required this.api,
    this.initialMedia,
    this.context = const PhotoDiagnosisContext(),
    this.discoverySessionId,
  });

  final PhotoDiagnosisApi api;
  final MediaData? initialMedia;
  final PhotoDiagnosisContext context;
  final String? discoverySessionId;

  @override
  State<PhotoDiagnosisScreen> createState() => _PhotoDiagnosisScreenState();
}

class _PhotoDiagnosisScreenState extends State<PhotoDiagnosisScreen> {
  late final TextEditingController _mediaController;
  final TextEditingController _questionController = TextEditingController();
  late final String _discoverySessionId;
  PhotoDiagnosisState _state = PhotoDiagnosisState.idle;
  PhotoDiagnosisResponseData? _result;
  String _message = 'Sélectionnez une photo déjà envoyée.';

  @override
  void initState() {
    super.initState();
    _mediaController = TextEditingController(
      text: widget.initialMedia?.id ?? '',
    );
    _discoverySessionId =
        widget.discoverySessionId ??
        'photo-diagnosis-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _mediaController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _diagnose() async {
    if (_mediaController.text.trim().isEmpty) {
      setState(() {
        _state = PhotoDiagnosisState.mediaNotFound;
        _message = 'Sélectionnez une photo déjà envoyée.';
      });
      return;
    }
    setState(() {
      _state = PhotoDiagnosisState.loading;
      _message = 'Analyse de la photo en cours...';
      _result = null;
    });
    try {
      final result = await widget.api.diagnose(
        mediaId: _mediaController.text,
        question: _questionController.text,
        language: 'fr',
        discoverySessionId: _discoverySessionId,
        context: widget.context,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        final diagnosis = result.diagnosis;
        if (diagnosis.photoQuality.level == 'poor') {
          _state = PhotoDiagnosisState.poorPhoto;
          _message = 'La photo n’est pas assez nette.';
        } else if (diagnosis.photoQuality.retakeRequired) {
          _state = PhotoDiagnosisState.retakeRequired;
          _message = 'La photo n’est pas exploitable.';
        } else if (diagnosis.status == 'insufficient') {
          _state = PhotoDiagnosisState.insufficientInformation;
          _message = 'Agrivito a besoin de plus d’informations.';
        } else {
          _state = PhotoDiagnosisState.success;
          _message = 'Analyse terminée.';
        }
      });
    } on PhotoDiagnosisApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _state = switch (error.kind) {
          PhotoDiagnosisApiErrorKind.network =>
            PhotoDiagnosisState.networkError,
          PhotoDiagnosisApiErrorKind.provider =>
            PhotoDiagnosisState.providerError,
          PhotoDiagnosisApiErrorKind.mediaNotFound =>
            PhotoDiagnosisState.mediaNotFound,
          PhotoDiagnosisApiErrorKind.discoveryLimit =>
            PhotoDiagnosisState.discoveryLimitReached,
          PhotoDiagnosisApiErrorKind.validation =>
            PhotoDiagnosisState.insufficientInformation,
        };
        _message = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _state == PhotoDiagnosisState.loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic photo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Analyse visuelle prudente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrivito évalue ce qui est visible sans confirmer une maladie '
              'à partir d’une photo seule.',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('photo-diagnosis-media-id'),
              controller: _mediaController,
              enabled: !loading,
              decoration: const InputDecoration(
                labelText: 'Référence du média',
                hintText: 'Collez l’identifiant reçu après l’envoi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('photo-diagnosis-question'),
              controller: _questionController,
              enabled: !loading,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Question (optionnelle)',
                hintText: 'Pourquoi les feuilles sont-elles tachées ?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('photo-diagnosis-submit'),
              onPressed:
                  loading || _state == PhotoDiagnosisState.discoveryLimitReached
                  ? null
                  : _diagnose,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Analyser la photo'),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              key: const Key('photo-diagnosis-status'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _isError(_state)
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
            if (_state == PhotoDiagnosisState.discoveryLimitReached) ...[
              const SizedBox(height: 8),
              const Text(
                'Créez un compte pour continuer et sauvegarder vos diagnostics.',
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _QualityCard(quality: _result!.diagnosis.photoQuality),
              const SizedBox(height: 12),
              _TextSection(
                title: 'Résumé',
                items: [_result!.diagnosis.summary],
              ),
              _TextSection(
                title: 'Observations visuelles',
                items: _result!.diagnosis.observations,
              ),
              _HypothesesSection(items: _result!.diagnosis.hypotheses),
              _TextSection(
                title: 'Recommandations',
                items: _result!.diagnosis.recommendations,
              ),
              _TextSection(
                title: 'Questions complémentaires',
                items: _result!.diagnosis.followUpQuestions,
              ),
              _TextSection(
                title: 'Précautions',
                items: _result!.diagnosis.precautions,
              ),
              Card(
                key: const Key('photo-diagnosis-trust-score'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau de confiance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_result!.diagnosis.trustScore.score}% — '
                        '${_result!.diagnosis.trustScore.level}',
                      ),
                      Text(_result!.diagnosis.trustScore.explanation),
                    ],
                  ),
                ),
              ),
              if (_result!.usage.remaining == 0 &&
                  _result!.usage.mode == 'discovery')
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Analyse découverte utilisée. Créez un compte pour continuer.',
                    key: Key('photo-diagnosis-limit-invitation'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static bool _isError(PhotoDiagnosisState state) => {
    PhotoDiagnosisState.networkError,
    PhotoDiagnosisState.providerError,
    PhotoDiagnosisState.mediaNotFound,
    PhotoDiagnosisState.discoveryLimitReached,
  }.contains(state);
}

class _QualityCard extends StatelessWidget {
  const _QualityCard({required this.quality});

  final PhotoQualityData quality;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('photo-diagnosis-quality'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qualité photo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('${quality.score}% — ${quality.level}'),
            for (final issue in quality.issues) Text('• $issue'),
            if (quality.retakeRequired) ...[
              const SizedBox(height: 8),
              const Text(
                'Reprendre la photo',
                key: Key('photo-diagnosis-retake'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final instruction in quality.retakeInstructions)
                Text('• $instruction'),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final item in items) Text('• $item'),
        ],
      ),
    );
  }
}

class _HypothesesSection extends StatelessWidget {
  const _HypothesesSection({required this.items});

  final List<DiagnosisHypothesisData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hypothèses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final item in items)
            Text('• ${item.label} — ${item.explanation}'),
        ],
      ),
    );
  }
}
