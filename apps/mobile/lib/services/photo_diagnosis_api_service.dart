import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/photo_diagnosis_models.dart';

enum PhotoDiagnosisApiErrorKind {
  validation,
  network,
  provider,
  mediaNotFound,
  discoveryLimit,
}

class PhotoDiagnosisApiException implements Exception {
  const PhotoDiagnosisApiException(this.message, {required this.kind});

  final String message;
  final PhotoDiagnosisApiErrorKind kind;
}

abstract interface class PhotoDiagnosisApi {
  Future<PhotoDiagnosisResponseData> diagnose({
    required String mediaId,
    required String question,
    required String language,
    required String discoverySessionId,
    PhotoDiagnosisContext context,
  });
}

class PhotoDiagnosisApiService implements PhotoDiagnosisApi {
  const PhotoDiagnosisApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<PhotoDiagnosisResponseData> diagnose({
    required String mediaId,
    required String question,
    required String language,
    required String discoverySessionId,
    PhotoDiagnosisContext context = const PhotoDiagnosisContext(),
  }) async {
    final client = _client ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/ai/photo-diagnosis'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'media_id': mediaId.trim(),
              'question': question.trim(),
              'language': language,
              'discovery_session_id': discoverySessionId,
              ...context.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 50));

      if (response.statusCode == 404) {
        throw const PhotoDiagnosisApiException(
          'La photo demandée est introuvable.',
          kind: PhotoDiagnosisApiErrorKind.mediaNotFound,
        );
      }
      if (response.statusCode == 422 || response.statusCode == 415) {
        throw const PhotoDiagnosisApiException(
          'Vérifiez la photo et la question avant de continuer.',
          kind: PhotoDiagnosisApiErrorKind.validation,
        );
      }
      if (response.statusCode == 429) {
        throw const PhotoDiagnosisApiException(
          'Vous avez atteint la limite du mode découverte.',
          kind: PhotoDiagnosisApiErrorKind.discoveryLimit,
        );
      }
      if ({502, 503, 504}.contains(response.statusCode)) {
        throw const PhotoDiagnosisApiException(
          'L’analyse visuelle est temporairement indisponible.',
          kind: PhotoDiagnosisApiErrorKind.provider,
        );
      }
      if (response.statusCode != 200) {
        throw const PhotoDiagnosisApiException(
          'Impossible de contacter Agrivito.',
          kind: PhotoDiagnosisApiErrorKind.network,
        );
      }
      return PhotoDiagnosisResponseData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on PhotoDiagnosisApiException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const PhotoDiagnosisApiException(
        'Impossible de contacter Agrivito.',
        kind: PhotoDiagnosisApiErrorKind.network,
      );
    } on http.ClientException catch (_) {
      throw const PhotoDiagnosisApiException(
        'Impossible de contacter Agrivito.',
        kind: PhotoDiagnosisApiErrorKind.network,
      );
    } on FormatException catch (_) {
      throw const PhotoDiagnosisApiException(
        'L’analyse visuelle est temporairement indisponible.',
        kind: PhotoDiagnosisApiErrorKind.provider,
      );
    } finally {
      if (_client == null) client.close();
    }
  }
}
