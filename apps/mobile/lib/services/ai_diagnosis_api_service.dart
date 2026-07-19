import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/ai_diagnosis_models.dart';
import 'auth_service.dart';

abstract interface class AIDiagnosisApi {
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context,
  });
}

class AIDiagnosisApiService implements AIDiagnosisApi {
  const AIDiagnosisApiService({http.Client? client, AuthService? authService})
    : _client = client,
      _authService = authService;

  final http.Client? _client;
  final AuthService? _authService;

  @override
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context = const AIDiagnosisContext(),
  }) async {
    final client = _client ?? http.Client();
    try {
      final isAuthenticated = _authService?.hasSession ?? true;
      final payload = <String, dynamic>{
        'question': question,
        'language': language,
        if (!isAuthenticated) 'session_id': discoverySessionId,
        ...context.toJson(),
      };
      final path = isAuthenticated ? '/ai/diagnosis' : '/discovery/question';
      final response = await client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}$path'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode == 422) {
        throw const AIDiagnosisApiException(
          'Vérifiez votre question avant de continuer.',
          kind: AIDiagnosisErrorKind.validation,
        );
      }
      if (response.statusCode == 429) {
        throw const AIDiagnosisApiException(
          'Vous avez atteint la limite du mode découverte.',
          kind: AIDiagnosisErrorKind.discoveryLimit,
        );
      }
      if (response.statusCode == 502 ||
          response.statusCode == 503 ||
          response.statusCode == 504) {
        throw const AIDiagnosisApiException(
          "L'analyse est temporairement indisponible.",
          kind: AIDiagnosisErrorKind.provider,
        );
      }
      if (response.statusCode != 200) {
        throw const AIDiagnosisApiException(
          'Impossible de contacter Agrivito.',
          kind: AIDiagnosisErrorKind.network,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (isAuthenticated) {
        return AIDiagnosisResponseData.fromJson(json);
      }
      return _fromDiscovery(json, language);
    } on AIDiagnosisApiException {
      rethrow;
    } on FormatException catch (_) {
      throw const AIDiagnosisApiException(
        "L'analyse est temporairement indisponible.",
        kind: AIDiagnosisErrorKind.provider,
      );
    } catch (_) {
      throw const AIDiagnosisApiException(
        'Impossible de contacter Agrivito.',
        kind: AIDiagnosisErrorKind.network,
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  static AIDiagnosisResponseData _fromDiscovery(
    Map<String, dynamic> json,
    String language,
  ) {
    final answer = json['answer'] as Map<String, dynamic>;
    final usage = json['usage'] as Map<String, dynamic>;
    final trust = Map<String, dynamic>.from(
      answer['trust_score'] as Map<String, dynamic>,
    );
    const levels = {
      'élevé': 'high',
      'moyen': 'medium',
      'faible': 'low',
      'insuffisant': 'insufficient',
    };
    trust['level'] = levels[trust['level']] ?? 'insufficient';
    return AIDiagnosisResponseData(
      diagnosis: DiagnosisData(
        summary: answer['summary'] as String,
        observations: const [],
        hypotheses: const [],
        recommendations: [answer['response'] as String],
        followUpQuestions: (answer['follow_up_questions'] as List<dynamic>)
            .cast<String>(),
        precautions: (answer['precautions'] as List<dynamic>).cast<String>(),
        trustScore: DiagnosisTrustScoreData.fromJson(trust),
        responseMode: 'hypotheses',
        language: language,
      ),
      contextUsed: const DiagnosisContextUsedData(
        farmerProfile: false,
        farm: false,
        field: false,
        crop: false,
      ),
      usage: DiagnosisUsageData(
        mode: 'discovery',
        questionsUsed: usage['questions_used'] as int?,
        questionsLimit: usage['questions_limit'] as int?,
        remaining: usage['remaining'] as int?,
      ),
    );
  }
}

enum AIDiagnosisErrorKind {
  validation,
  network,
  provider,
  insufficientInformation,
  discoveryLimit,
}

class AIDiagnosisApiException implements Exception {
  const AIDiagnosisApiException(this.message, {required this.kind});

  final String message;
  final AIDiagnosisErrorKind kind;
}
