import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agrivito_mobile/models/media_models.dart';
import 'package:agrivito_mobile/services/media_api_service.dart';

void main() {
  test('media service builds multipart upload with agricultural context',
      () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode(_responseJson()), 201);
    });
    final service = MediaApiService(client: client);

    final media = await service.upload(
      media: SelectedMedia(
        bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0]),
        filename: 'tomate.jpg',
        contentType: 'image/jpeg',
      ),
      context: const MediaUploadContext(
        userId: 'user-1',
        discoverySessionId: 'session-1',
        farmId: 'farm-1',
        fieldId: 'field-1',
        cropId: 'crop-1',
      ),
    );

    expect(captured.url.path, '/media/upload');
    expect(
        captured.headers['content-type'], startsWith('multipart/form-data;'));
    final body = latin1.decode(captured.bodyBytes);
    expect(body, contains('name="file"; filename="tomate.jpg"'));
    expect(body, contains('content-type: image/jpeg'));
    expect(body, contains('name="user_id"'));
    expect(body, contains('user-1'));
    expect(body, contains('name="farm_id"'));
    expect(body, contains('farm-1'));
    expect(body, contains('name="field_id"'));
    expect(body, contains('field-1'));
    expect(body, contains('name="crop_id"'));
    expect(body, contains('crop-1'));
    expect(media.id, 'media-1');
    expect(media.status, 'uploaded');
  });

  test('media service maps validation and discovery errors', () async {
    for (final entry in {
      413: MediaApiErrorKind.validation,
      429: MediaApiErrorKind.discoveryLimit
    }.entries) {
      final service = MediaApiService(
        client: MockClient((request) async => http.Response('{}', entry.key)),
      );
      expect(
        () => service.upload(media: _selectedMedia()),
        throwsA(
          isA<MediaApiException>().having(
            (error) => error.kind,
            'kind',
            entry.value,
          ),
        ),
      );
    }
  });

  test('media service maps backend errors', () async {
    final service = MediaApiService(
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    expect(
      () => service.upload(media: _selectedMedia()),
      throwsA(
        isA<MediaApiException>().having(
          (error) => error.kind,
          'kind',
          MediaApiErrorKind.backend,
        ),
      ),
    );
  });
}

SelectedMedia _selectedMedia() => SelectedMedia(
      bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0]),
      filename: 'tomate.jpg',
      contentType: 'image/jpeg',
    );

Map<String, dynamic> _responseJson() => {
      'media': {
        'id': 'media-1',
        'original_filename': 'tomate.jpg',
        'content_type': 'image/jpeg',
        'size_bytes': 4,
        'storage_provider': 'local',
        'status': 'uploaded',
        'farm_id': 'farm-1',
        'field_id': 'field-1',
        'crop_id': 'crop-1',
        'created_at': '2026-07-14T12:00:00Z',
      },
    };
