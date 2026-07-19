import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  idle,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  invalidCredentials,
  emailNotConfirmed,
  passwordResetSent,
  networkError,
  providerError,
  sessionExpired,
  configurationError,
}

class AuthUserData {
  const AuthUserData({required this.id, required this.email});

  final String id;
  final String? email;
}

class AuthResult {
  const AuthResult({required this.status, required this.message, this.user});

  final AuthStatus status;
  final String message;
  final AuthUserData? user;

  bool get success =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.registrationSuccess ||
      status == AuthStatus.passwordResetSent;
}

abstract class AuthService {
  Future<AuthResult> signUp({required String email, required String password});
  Future<AuthResult> signIn({required String email, required String password});
  Future<AuthResult> signOut();
  Future<AuthResult> resetPassword(String email);
  AuthUserData? get currentUser;
  bool get hasSession;
  Stream<AuthUserData?> get authStateChanges;
  Future<String?> getAccessToken();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  AuthUserData? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Stream<AuthUserData?> get authStateChanges => _client.auth.onAuthStateChange
      .map((event) => _mapUser(event.session?.user));

  @override
  Future<String?> getAccessToken() async =>
      _client.auth.currentSession?.accessToken;

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = _mapUser(response.user);
      if (response.session == null) {
        return AuthResult(
          status: AuthStatus.emailNotConfirmed,
          message: 'Compte créé. Vérifiez votre adresse email.',
          user: user,
        );
      }
      return AuthResult(
        status: AuthStatus.authenticated,
        message: 'Compte créé.',
        user: user,
      );
    } on AuthException catch (error) {
      return _mapException(error);
    } catch (_) {
      return const AuthResult(
        status: AuthStatus.networkError,
        message:
            'Le service d’authentification est temporairement indisponible.',
      );
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return AuthResult(
        status: AuthStatus.authenticated,
        message: 'Connexion réussie.',
        user: _mapUser(response.user),
      );
    } on AuthException catch (error) {
      return _mapException(error);
    } catch (_) {
      return const AuthResult(
        status: AuthStatus.networkError,
        message:
            'Le service d’authentification est temporairement indisponible.',
      );
    }
  }

  @override
  Future<AuthResult> signOut() async {
    try {
      await _client.auth.signOut();
      return const AuthResult(
        status: AuthStatus.unauthenticated,
        message: 'Vous êtes déconnecté.',
      );
    } catch (_) {
      return const AuthResult(
        status: AuthStatus.providerError,
        message: 'La déconnexion a échoué.',
      );
    }
  }

  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const AuthResult(
        status: AuthStatus.passwordResetSent,
        message: 'Un lien de réinitialisation a été envoyé.',
      );
    } on AuthException catch (error) {
      return _mapException(error);
    } catch (_) {
      return const AuthResult(
        status: AuthStatus.networkError,
        message:
            'Le service d’authentification est temporairement indisponible.',
      );
    }
  }

  static AuthUserData? _mapUser(User? user) =>
      user == null ? null : AuthUserData(id: user.id, email: user.email);

  static AuthResult _mapException(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login') || message.contains('credentials')) {
      return const AuthResult(
        status: AuthStatus.invalidCredentials,
        message: 'Identifiants incorrects.',
      );
    }
    if (message.contains('confirm')) {
      return const AuthResult(
        status: AuthStatus.emailNotConfirmed,
        message: 'Vérifiez votre adresse email.',
      );
    }
    return const AuthResult(
      status: AuthStatus.providerError,
      message: 'Le service d’authentification est temporairement indisponible.',
    );
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  static const _result = AuthResult(
    status: AuthStatus.configurationError,
    message: 'La configuration Supabase Auth est absente.',
  );

  @override
  Stream<AuthUserData?> get authStateChanges => const Stream.empty();
  @override
  AuthUserData? get currentUser => null;
  @override
  bool get hasSession => false;
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<AuthResult> resetPassword(String email) async => _result;
  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async => _result;
  @override
  Future<AuthResult> signOut() async => _result;
  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async => _result;
}
