import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class DiscoveryApiService {
  const DiscoveryApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<Map<String, dynamic>> askQuestion({
    required String sessionId,
    required String question,
    String language = 'fr',
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/discovery/question'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'session_id': sessionId,
              'question': question,
              'language': language,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw DiscoveryApiException(
          'Backend indisponible (${response.statusCode}).',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on DiscoveryApiException {
      rethrow;
    } catch (_) {
      throw const DiscoveryApiException(
        'Backend indisponible. Verifiez que l API FastAPI est lancee.',
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

class DiscoveryApiException implements Exception {
  const DiscoveryApiException(this.message);

  final String message;
}
