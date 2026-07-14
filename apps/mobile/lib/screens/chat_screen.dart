import 'package:flutter/material.dart';

import '../models/ai_diagnosis_models.dart';
import '../services/ai_diagnosis_api_service.dart';
import '../services/discovery_session.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({
    super.key,
    required this.diagnosisApi,
    this.diagnosisContext = const AIDiagnosisContext(),
  });

  final AIDiagnosisApi diagnosisApi;
  final AIDiagnosisContext diagnosisContext;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

enum ChatDiagnosisState {
  idle,
  loading,
  success,
  validationError,
  networkError,
  providerError,
  insufficientInformation,
  discoveryLimitReached,
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  DiscoverySession _session = DiscoverySession.create();
  AIDiagnosisResponseData? _answer;
  String? _errorMessage;
  ChatDiagnosisState _state = ChatDiagnosisState.idle;

  bool get _isLoading => _state == ChatDiagnosisState.loading;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() {
        _state = ChatDiagnosisState.validationError;
        _errorMessage = 'Saisissez une question agricole avant de continuer.';
      });
      return;
    }
    if (!_session.hasRemainingQuestions) {
      _showDiscoveryLimit();
      return;
    }

    setState(() {
      _state = ChatDiagnosisState.loading;
      _errorMessage = null;
    });

    try {
      final result = await widget.diagnosisApi.diagnose(
        question: question,
        language: 'fr',
        discoverySessionId: _session.discoverySessionId,
        context: widget.diagnosisContext,
      );
      if (!mounted) return;

      setState(() {
        _answer = result;
        _session = _session.recordQuestion();
        _questionController.clear();
        _state = result.diagnosis.trustScore.level == 'insufficient'
            ? ChatDiagnosisState.insufficientInformation
            : ChatDiagnosisState.success;
        _errorMessage = result.diagnosis.trustScore.level == 'insufficient'
            ? "Agrivito a besoin de plus d'informations."
            : null;
      });
    } on AIDiagnosisApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _state = _stateForError(error.kind);
        _errorMessage = error.message;
      });
    }
  }

  ChatDiagnosisState _stateForError(AIDiagnosisErrorKind kind) {
    switch (kind) {
      case AIDiagnosisErrorKind.validation:
        return ChatDiagnosisState.validationError;
      case AIDiagnosisErrorKind.network:
        return ChatDiagnosisState.networkError;
      case AIDiagnosisErrorKind.provider:
        return ChatDiagnosisState.providerError;
      case AIDiagnosisErrorKind.insufficientInformation:
        return ChatDiagnosisState.insufficientInformation;
      case AIDiagnosisErrorKind.discoveryLimit:
        return ChatDiagnosisState.discoveryLimitReached;
    }
  }

  void _showDiscoveryLimit() {
    setState(() {
      _state = ChatDiagnosisState.discoveryLimitReached;
      _errorMessage = 'Vous avez atteint la limite du mode découverte.';
    });
  }

  void _resetDiscoverySession() {
    setState(() {
      _session = DiscoverySession.create();
      _answer = null;
      _errorMessage = null;
      _state = ChatDiagnosisState.idle;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasReachedLimit = !_session.hasRemainingQuestions ||
        _state == ChatDiagnosisState.discoveryLimitReached;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Agrivito')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Mode découverte',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('3 questions gratuites pour tester Agrivito.'),
            const SizedBox(height: 12),
            _UsageBanner(
              remaining: _session.remaining,
              limit: _session.questionsLimit,
              used: _session.questionsUsed,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('diagnosis-question'),
              controller: _questionController,
              enabled: !hasReachedLimit && !_isLoading,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pourquoi les feuilles de mes tomates jaunissent ?',
                labelText: 'Votre question agricole',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('diagnosis-submit'),
              onPressed: _isLoading || hasReachedLimit ? null : _sendQuestion,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Analyser la question'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Analyse en cours...'),
                ],
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _StatusMessage(
                message: _errorMessage!,
                isError: _state != ChatDiagnosisState.insufficientInformation,
              ),
            ],
            if (hasReachedLimit) ...[
              const SizedBox(height: 12),
              const _AccountInvitation(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(LoginScreen.routeName),
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(RegisterScreen.routeName),
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ],
            if (_answer != null) ...[
              const SizedBox(height: 20),
              _DiagnosisResultView(result: _answer!),
            ],
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _resetDiscoverySession,
              icon: const Icon(Icons.refresh),
              label: const Text('Réinitialiser la session découverte'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBanner extends StatelessWidget {
  const _UsageBanner({
    required this.remaining,
    required this.limit,
    required this.used,
  });

  final int remaining;
  final int limit;
  final int used;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.explore_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$remaining question(s) restante(s) sur $limit. Utilisées: $used.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _AccountInvitation extends StatelessWidget {
  const _AccountInvitation();

  @override
  Widget build(BuildContext context) {
    return const _StatusMessage(
      message:
          'Créez un compte pour continuer et sauvegarder votre historique.',
      isError: false,
    );
  }
}

class _DiagnosisResultView extends StatelessWidget {
  const _DiagnosisResultView({required this.result});

  final AIDiagnosisResponseData result;

  @override
  Widget build(BuildContext context) {
    final diagnosis = result.diagnosis;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Agrivito',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _TextSection(title: 'Résumé', items: [diagnosis.summary]),
            _TextSection(title: 'Observations', items: diagnosis.observations),
            _HypothesesSection(items: diagnosis.hypotheses),
            _TextSection(
              title: 'Recommandations',
              items: diagnosis.recommendations,
            ),
            _TextSection(
              title: 'Questions complémentaires',
              items: diagnosis.followUpQuestions,
            ),
            _TextSection(title: 'Précautions', items: diagnosis.precautions),
            _TrustScoreView(trustScore: diagnosis.trustScore),
            const SizedBox(height: 8),
            Text(
              'Mode de réponse : ${_responseModeLabel(diagnosis.responseMode)}',
            ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...items.map((item) => _BulletText(text: item)),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hypothèses',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(item.explanation),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustScoreView extends StatelessWidget {
  const _TrustScoreView({required this.trustScore});

  final DiagnosisTrustScoreData trustScore;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Niveau de confiance ${_trustLevelLabel(trustScore.level)}',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.speed_outlined),
        title: const Text(
          'Niveau de confiance',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_trustLevelLabel(trustScore.level)} - ${trustScore.score} / 100\n'
          '${trustScore.explanation}',
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

String _trustLevelLabel(String level) {
  return switch (level) {
    'high' => 'Confiance élevée',
    'medium' => 'Confiance moyenne',
    'low' => 'Confiance faible',
    _ => 'Informations insuffisantes',
  };
}

String _responseModeLabel(String mode) {
  return switch (mode) {
    'reliable' => 'réponse fiable',
    'hypotheses' => 'hypothèses',
    'questions_required' => 'questions requises',
    _ => 'refus de conclure',
  };
}
