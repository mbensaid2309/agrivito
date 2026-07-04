class DiscoverySession {
  DiscoverySession({
    required this.discoverySessionId,
    required this.createdAt,
    this.questionsUsed = 0,
    this.questionsLimit = 3,
  });

  factory DiscoverySession.create() {
    final now = DateTime.now();
    return DiscoverySession(
      discoverySessionId: 'discovery-${now.millisecondsSinceEpoch}',
      createdAt: now,
    );
  }

  final String discoverySessionId;
  final int questionsUsed;
  final int questionsLimit;
  final DateTime createdAt;

  int get remaining => questionsLimit - questionsUsed;

  bool get hasRemainingQuestions => remaining > 0;

  DiscoverySession recordQuestion() {
    final nextUsed = questionsUsed + 1;
    return DiscoverySession(
      discoverySessionId: discoverySessionId,
      createdAt: createdAt,
      questionsUsed: nextUsed > questionsLimit ? questionsLimit : nextUsed,
      questionsLimit: questionsLimit,
    );
  }
}
