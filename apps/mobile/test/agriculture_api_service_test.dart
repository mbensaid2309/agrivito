import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agrivito_mobile/services/agriculture_api_service.dart';

void main() {
  test('farm service decodes a backend list', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/farms');
      return http.Response(
        '[{"farm_id":"farm-1","user_id":"mobile-user","name":"Ferme Atlas","country":"Maroc","region":"Souss-Massa","locality":"Taroudant","total_area":4,"area_unit":"hectare","created_at":"2026-07-12T00:00:00Z"}]',
        200,
      );
    });
    final service = AgricultureApiService(client: client);

    final farms = await service.getFarms();

    expect(farms, hasLength(1));
    expect(farms.single.name, 'Ferme Atlas');
  });

  test('farm service exposes a clear backend error', () async {
    final service = AgricultureApiService(
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    await expectLater(
      service.getFarms(),
      throwsA(
        isA<AgricultureApiException>().having(
          (error) => error.kind,
          'kind',
          AgricultureApiErrorKind.backend,
        ),
      ),
    );
  });

  test('farm service exposes a clear network error', () async {
    final service = AgricultureApiService(
      client: MockClient((request) async {
        throw http.ClientException('offline');
      }),
    );

    await expectLater(
      service.getFarms(),
      throwsA(
        isA<AgricultureApiException>()
            .having(
              (error) => error.kind,
              'kind',
              AgricultureApiErrorKind.network,
            )
            .having(
              (error) => error.message,
              'message',
              'Impossible de contacter le serveur.',
            ),
      ),
    );
  });
}
