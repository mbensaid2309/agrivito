import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agrivito_mobile/models/photo_diagnosis_models.dart';
import 'package:agrivito_mobile/services/auth_service.dart';
import 'package:agrivito_mobile/services/photo_diagnosis_api_service.dart';

void main() {
  test(
    'photo diagnosis service sends context and parses structured response',
    () async {
      late Map<String, dynamic> sent;
      final api = PhotoDiagnosisApiService(
        client: MockClient((request) async {
          expect(request.url.path, '/ai/photo-diagnosis');
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(_responseJson()), 200);
        }),
      );

      final result = await api.diagnose(
        mediaId: ' media-1 ',
        question: ' Pourquoi ? ',
        language: 'fr',
        discoverySessionId: 'session-1',
        context: const PhotoDiagnosisContext(
          farmId: 'farm-1',
          fieldId: 'field-1',
          cropId: 'crop-1',
        ),
      );

      expect(sent['media_id'], 'media-1');
      expect(sent['question'], 'Pourquoi ?');
      expect(sent['farm_id'], 'farm-1');
      expect(result.diagnosis.photoQuality.level, 'good');
      expect(result.diagnosis.trustScore.score, 82);
      expect(result.usage.remaining, 0);
    },
  );

  test('anonymous photo diagnosis uses the isolated discovery route', () async {
    late Map<String, dynamic> sent;
    final api = PhotoDiagnosisApiService(
      authService: const UnavailableAuthService(),
      client: MockClient((request) async {
        expect(request.url.path, '/discovery/photo-diagnosis');
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(_responseJson()), 200);
      }),
    );

    await api.diagnose(
      mediaId: 'media-1',
      question: 'Pourquoi ?',
      language: 'fr',
      discoverySessionId: 'session-1',
    );

    expect(sent['discovery_session_id'], 'session-1');
    expect(sent.containsKey('user_id'), isFalse);
  });

  for (final entry in {
    404: PhotoDiagnosisApiErrorKind.mediaNotFound,
    429: PhotoDiagnosisApiErrorKind.discoveryLimit,
    503: PhotoDiagnosisApiErrorKind.provider,
    422: PhotoDiagnosisApiErrorKind.validation,
  }.entries) {
    test('photo diagnosis maps HTTP ${entry.key}', () async {
      final api = PhotoDiagnosisApiService(
        client: MockClient((_) async => http.Response('{}', entry.key)),
      );
      expect(
        () => api.diagnose(
          mediaId: 'media-1',
          question: '',
          language: 'fr',
          discoverySessionId: 'session-1',
        ),
        throwsA(
          isA<PhotoDiagnosisApiException>().having(
            (error) => error.kind,
            'kind',
            entry.value,
          ),
        ),
      );
    });
  }
}

Map<String, dynamic> _responseJson() => {
  'diagnosis': {
    'id': 'diagnosis-1',
    'media_id': 'media-1',
    'summary': 'Résumé prudent.',
    'photo_quality': {
      'score': 88,
      'level': 'good',
      'issues': <String>[],
      'retake_required': false,
      'retake_instructions': <String>[],
    },
    'observations': ['Observation visible.'],
    'hypotheses': [
      {'label': 'Hypothèse', 'explanation': 'Explication prudente.'},
    ],
    'recommendations': ['Observer.'],
    'follow_up_questions': ['Depuis quand ?'],
    'precautions': ['Photo seule insuffisante.'],
    'trust_score': {
      'score': 82,
      'level': 'high',
      'explanation': 'Contexte suffisant.',
    },
    'response_mode': 'hypotheses',
    'language': 'fr',
    'status': 'completed',
  },
  'context_used': {
    'farmer_profile': false,
    'farm': true,
    'field': true,
    'crop': true,
  },
  'usage': {
    'mode': 'discovery',
    'diagnoses_used': 1,
    'diagnoses_limit': 1,
    'remaining': 0,
  },
};
