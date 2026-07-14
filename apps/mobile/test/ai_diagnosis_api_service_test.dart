import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agrivito_mobile/models/ai_diagnosis_models.dart';
import 'package:agrivito_mobile/services/ai_diagnosis_api_service.dart';

void main() {
  test('diagnosis service sends context and decodes structured response',
      () async {
    late Map<String, dynamic> sentPayload;
    final client = MockClient((request) async {
      sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(request.url.path, '/ai/diagnosis');
      return http.Response(jsonEncode(_responseJson()), 200);
    });
    final service = AIDiagnosisApiService(client: client);

    final response = await service.diagnose(
      question: 'Pourquoi les tomates jaunissent ?',
      language: 'fr',
      discoverySessionId: 'session-1',
      context: const AIDiagnosisContext(
        userId: 'user-1',
        farmId: 'farm-1',
        fieldId: 'field-1',
        cropId: 'crop-1',
      ),
    );

    expect(sentPayload['user_id'], 'user-1');
    expect(sentPayload['farm_id'], 'farm-1');
    expect(sentPayload['field_id'], 'field-1');
    expect(sentPayload['crop_id'], 'crop-1');
    expect(response.diagnosis.summary, 'Plusieurs causes sont possibles.');
    expect(response.diagnosis.trustScore.score, 65);
  });

  test('diagnosis service maps provider errors', () async {
    final service = AIDiagnosisApiService(
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    expect(
      () => service.diagnose(
        question: 'Question agricole',
        language: 'fr',
        discoverySessionId: 'session-1',
      ),
      throwsA(
        isA<AIDiagnosisApiException>().having(
          (error) => error.kind,
          'kind',
          AIDiagnosisErrorKind.provider,
        ),
      ),
    );
  });

  test('diagnosis service maps discovery limit', () async {
    final service = AIDiagnosisApiService(
      client: MockClient((request) async => http.Response('{}', 429)),
    );

    expect(
      () => service.diagnose(
        question: 'Question agricole',
        language: 'fr',
        discoverySessionId: 'session-1',
      ),
      throwsA(
        isA<AIDiagnosisApiException>().having(
          (error) => error.kind,
          'kind',
          AIDiagnosisErrorKind.discoveryLimit,
        ),
      ),
    );
  });
}

Map<String, dynamic> _responseJson() => {
      'diagnosis': {
        'summary': 'Plusieurs causes sont possibles.',
        'observations': ['Les feuilles jaunissent.'],
        'hypotheses': [
          {'label': "Excès d'eau", 'explanation': 'Le sol peut être humide.'},
        ],
        'recommendations': ["Vérifier l'humidité du sol."],
        'follow_up_questions': ['Depuis combien de temps ?'],
        'precautions': ['Ne pas traiter sans confirmation.'],
        'trust_score': {
          'score': 65,
          'level': 'medium',
          'explanation': 'Contexte incomplet.',
        },
        'response_mode': 'hypotheses',
        'language': 'fr',
      },
      'context_used': {
        'farmer_profile': true,
        'farm': true,
        'field': true,
        'crop': true,
      },
      'usage': {
        'mode': 'discovery',
        'questions_used': 1,
        'questions_limit': 3,
        'remaining': 2,
      },
    };
