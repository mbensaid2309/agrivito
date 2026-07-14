import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/app_config.dart';
import '../models/media_models.dart';

enum MediaApiErrorKind { validation, network, backend, discoveryLimit }

class MediaApiException implements Exception {
  const MediaApiException(this.message, {required this.kind});

  final String message;
  final MediaApiErrorKind kind;
}

abstract interface class MediaApi {
  Future<MediaData> upload({
    required SelectedMedia media,
    MediaUploadContext context,
  });
}

class MediaApiService implements MediaApi {
  const MediaApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<MediaData> upload({
    required SelectedMedia media,
    MediaUploadContext context = const MediaUploadContext(),
  }) async {
    final client = _client ?? http.Client();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.backendBaseUrl}/media/upload'),
      );
      request.fields.addAll(context.toFields());
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          media.bytes,
          filename: media.filename,
          contentType: MediaType.parse(media.contentType),
        ),
      );
      final streamed = await client.send(request).timeout(
            const Duration(seconds: 35),
          );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 400 ||
          response.statusCode == 413 ||
          response.statusCode == 415 ||
          response.statusCode == 422) {
        throw MediaApiException(
          response.statusCode == 413
              ? 'La photo est trop volumineuse.'
              : 'Ce format n’est pas supporté.',
          kind: MediaApiErrorKind.validation,
        );
      }
      if (response.statusCode == 429) {
        throw const MediaApiException(
          'Vous avez atteint la limite du mode découverte.',
          kind: MediaApiErrorKind.discoveryLimit,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MediaApiException(
          'Impossible d’envoyer la photo.',
          kind: MediaApiErrorKind.backend,
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return MediaData.fromJson(body['media'] as Map<String, dynamic>);
    } on MediaApiException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const MediaApiException(
        'Impossible d’envoyer la photo.',
        kind: MediaApiErrorKind.network,
      );
    } on http.ClientException catch (_) {
      throw const MediaApiException(
        'Impossible d’envoyer la photo.',
        kind: MediaApiErrorKind.network,
      );
    } on FormatException catch (_) {
      throw const MediaApiException(
        'Impossible d’envoyer la photo.',
        kind: MediaApiErrorKind.backend,
      );
    } finally {
      if (_client == null) client.close();
    }
  }
}
