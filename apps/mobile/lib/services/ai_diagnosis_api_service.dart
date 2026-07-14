import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/ai_diagnosis_models.dart';

abstract interface class AIDiagnosisApi {
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context,
  });
}

class AIDiagnosisApiService implements AIDiagnosisApi {
  const AIDiagnosisApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context = const AIDiagnosisContext(),
  }) async {
    final client = _client ?? http.Client();
    try {
      final payload = <String, dynamic>{
        'question': question,
        'language': language,
        'discovery_session_id': discoverySessionId,
        ...context.toJson(),
      };
      final response = await client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/ai/diagnosis'),
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
      return AIDiagnosisResponseData.fromJson(json);
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
