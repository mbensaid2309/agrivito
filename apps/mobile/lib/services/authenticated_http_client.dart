import 'dart:async';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient({
    required AuthService auth,
    http.Client? inner,
    void Function()? onSessionExpired,
  }) : _auth = auth,
       _inner = inner ?? http.Client(),
       _onSessionExpired = onSessionExpired;

  final AuthService _auth;
  final http.Client _inner;
  final void Function()? _onSessionExpired;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_isPublic(request.url.path)) {
      final token = await _auth.getAccessToken();
      if (token == null || token.isEmpty) {
        _onSessionExpired?.call();
        throw const SessionExpiredException();
      }
      request.headers['authorization'] = 'Bearer $token';
    }
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      _onSessionExpired?.call();
      throw const SessionExpiredException();
    }
    return response;
  }

  static bool _isPublic(String path) =>
      path == '/health' || path.startsWith('/discovery/');

  @override
  void close() => _inner.close();
}
