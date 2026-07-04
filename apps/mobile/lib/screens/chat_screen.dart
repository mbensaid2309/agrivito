import 'package:flutter/material.dart';

import '../services/discovery_api_service.dart';
import '../services/discovery_session.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  final DiscoveryApiService _apiService = const DiscoveryApiService();
  DiscoverySession _session = DiscoverySession.create();
  DiscoveryAnswerView? _answer;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() {
        _error = 'Saisissez une question agricole avant d envoyer.';
      });
      return;
    }

    if (!_session.hasRemainingQuestions) {
      setState(() {
        _error =
            'Vous avez atteint la limite du mode découverte. Créez un compte pour continuer plus tard.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payload = await _apiService.askQuestion(
        sessionId: _session.discoverySessionId,
        question: question,
      );

      if (!mounted) return;

      setState(() {
        _answer = DiscoveryAnswerView.fromJson(
          payload['answer'] as Map<String, dynamic>,
        );
        _session = _session.recordQuestion();
        _questionController.clear();
      });
    } on DiscoveryApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetDiscoverySession() {
    setState(() {
      _session = DiscoverySession.create();
      _answer = null;
      _error = null;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _session.remaining;
    final hasReachedLimit = !_session.hasRemainingQuestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
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
            const Text(
              'Créez un compte pour sauvegarder votre historique plus tard.',
            ),
            const SizedBox(height: 12),
            _UsageBanner(
              remaining: remaining,
              limit: _session.questionsLimit,
              used: _session.questionsUsed,
            ),
            const SizedBox(height: 16),
            TextField(
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
              onPressed: _isLoading || hasReachedLimit ? null : _sendQuestion,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_isLoading ? 'Envoi...' : 'Poser la question'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _resetDiscoverySession,
              icon: const Icon(Icons.refresh),
              label: const Text('Réinitialiser la session découverte'),
            ),
            if (hasReachedLimit) ...[
              const SizedBox(height: 12),
              const _LimitMessage(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(LoginScreen.routeName),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(RegisterScreen.routeName),
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_answer != null) ...[
              const SizedBox(height: 20),
              _DiscoveryAnswerCard(answer: _answer!),
            ],
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

class _LimitMessage extends StatelessWidget {
  const _LimitMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Vous avez atteint la limite du mode découverte. Créez un compte pour continuer plus tard.',
        ),
      ),
    );
  }
}

class _DiscoveryAnswerCard extends StatelessWidget {
  const _DiscoveryAnswerCard({required this.answer});

  final DiscoveryAnswerView answer;

  @override
  Widget build(BuildContext context) {
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
              answer.summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(answer.response),
            const SizedBox(height: 16),
            _TrustScoreView(trustScore: answer.trustScore),
            const SizedBox(height: 16),
            const Text(
              'Questions complémentaires',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...answer.followUpQuestions.map(
              (question) => _BulletText(text: question),
            ),
            const SizedBox(height: 16),
            const Text(
              'Précautions',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...answer.precautions.map((item) => _BulletText(text: item)),
          ],
        ),
      ),
    );
  }
}

class _TrustScoreView extends StatelessWidget {
  const _TrustScoreView({required this.trustScore});

  final TrustScoreViewData trustScore;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.speed_outlined),
      title: Text('${trustScore.score} / 100 - ${trustScore.level}'),
      subtitle: Text(trustScore.explanation),
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

class DiscoveryAnswerView {
  const DiscoveryAnswerView({
    required this.summary,
    required this.response,
    required this.trustScore,
    required this.followUpQuestions,
    required this.precautions,
  });

  factory DiscoveryAnswerView.fromJson(Map<String, dynamic> json) {
    return DiscoveryAnswerView(
      summary: json['summary'] as String,
      response: json['response'] as String,
      trustScore: TrustScoreViewData.fromJson(
        json['trust_score'] as Map<String, dynamic>,
      ),
      followUpQuestions:
          (json['follow_up_questions'] as List<dynamic>).cast<String>(),
      precautions: (json['precautions'] as List<dynamic>).cast<String>(),
    );
  }

  final String summary;
  final String response;
  final TrustScoreViewData trustScore;
  final List<String> followUpQuestions;
  final List<String> precautions;
}

class TrustScoreViewData {
  const TrustScoreViewData({
    required this.score,
    required this.level,
    required this.explanation,
  });

  factory TrustScoreViewData.fromJson(Map<String, dynamic> json) {
    return TrustScoreViewData(
      score: json['score'] as int,
      level: json['level'] as String,
      explanation: json['explanation'] as String,
    );
  }

  final int score;
  final String level;
  final String explanation;
}
