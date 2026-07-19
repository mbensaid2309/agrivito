import 'dart:async';

import 'package:agrivito_mobile/screens/forgot_password_screen.dart';
import 'package:agrivito_mobile/screens/login_screen.dart';
import 'package:agrivito_mobile/screens/profile_screen.dart';
import 'package:agrivito_mobile/screens/register_screen.dart';
import 'package:agrivito_mobile/services/auth_service.dart';
import 'package:agrivito_mobile/services/authenticated_http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('login validates email and displays invalid credentials', (
    tester,
  ) async {
    final auth = FakeAuthService(
      signInResult: const AuthResult(
        status: AuthStatus.invalidCredentials,
        message: 'Identifiants incorrects.',
      ),
    );
    await tester.pumpWidget(_authApp(auth));
    await tester.tap(find.text('Connexion'));
    await tester.pump();
    expect(
      find.text('Email et mot de passe sont obligatoires.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).at(0), 'invalid');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Connexion'));
    await tester.pump();
    expect(find.text('Saisissez une adresse email valide.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'farmer@example.test');
    await tester.tap(find.text('Connexion'));
    await tester.pumpAndSettle();
    expect(find.text('Identifiants incorrects.'), findsOneWidget);
  });

  testWidgets('register validates password confirmation and succeeds', (
    tester,
  ) async {
    final auth = FakeAuthService(
      signUpResult: const AuthResult(
        status: AuthStatus.registrationSuccess,
        message: 'Compte créé.',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(authService: auth)),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Farmer');
    await tester.enterText(fields.at(1), 'farmer@example.test');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'different123');
    await tester.tap(find.text('Créer le compte'));
    await tester.pump();
    expect(
      find.text('La confirmation du mot de passe ne correspond pas.'),
      findsOneWidget,
    );
    await tester.enterText(fields.at(3), 'password123');
    await tester.tap(find.text('Créer le compte'));
    await tester.pumpAndSettle();
    expect(find.text('Compte créé.'), findsOneWidget);
  });

  testWidgets('password reset and logout use the auth abstraction', (
    tester,
  ) async {
    final auth = FakeAuthService(
      user: const AuthUserData(id: 'user-a', email: 'farmer@example.test'),
    );
    await tester.pumpWidget(
      MaterialApp(home: ForgotPasswordScreen(authService: auth)),
    );
    await tester.enterText(find.byType(TextField), 'farmer@example.test');
    await tester.tap(find.text('Envoyer le lien'));
    await tester.pumpAndSettle();
    expect(
      find.text('Un lien de réinitialisation a été envoyé.'),
      findsOneWidget,
    );
    expect(auth.resetCalls, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(authService: auth),
        routes: {LoginScreen.routeName: (_) => LoginScreen(authService: auth)},
      ),
    );
    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
  });

  test('authenticated client adds token only to private requests', () async {
    final seen = <http.Request>[];
    final auth = FakeAuthService(
      user: const AuthUserData(id: 'user-a', email: 'a@example.test'),
      accessToken: 'jwt-value',
    );
    final client = AuthenticatedHttpClient(
      auth: auth,
      inner: MockClient((request) async {
        seen.add(request);
        return http.Response('{}', 200);
      }),
    );
    await client.get(Uri.parse('http://localhost/farms'));
    await client.get(Uri.parse('http://localhost/health'));
    await client.post(Uri.parse('http://localhost/discovery/question'));
    expect(seen[0].headers['authorization'], 'Bearer jwt-value');
    expect(seen[1].headers.containsKey('authorization'), isFalse);
    expect(seen[2].headers.containsKey('authorization'), isFalse);
  });

  test('missing or expired session is surfaced', () async {
    var expirationCallbacks = 0;
    final noSession = AuthenticatedHttpClient(
      auth: FakeAuthService(),
      onSessionExpired: () => expirationCallbacks += 1,
      inner: MockClient((request) async => http.Response('{}', 200)),
    );
    await expectLater(
      noSession.get(Uri.parse('http://localhost/farms')),
      throwsA(isA<SessionExpiredException>()),
    );

    final expired = AuthenticatedHttpClient(
      auth: FakeAuthService(accessToken: 'expired'),
      onSessionExpired: () => expirationCallbacks += 1,
      inner: MockClient((request) async => http.Response('{}', 401)),
    );
    await expectLater(
      expired.get(Uri.parse('http://localhost/farms')),
      throwsA(isA<SessionExpiredException>()),
    );
    expect(expirationCallbacks, 2);
  });
}

Widget _authApp(AuthService auth) => MaterialApp(
  initialRoute: LoginScreen.routeName,
  routes: {
    LoginScreen.routeName: (_) => LoginScreen(authService: auth),
    RegisterScreen.routeName: (_) => RegisterScreen(authService: auth),
    ForgotPasswordScreen.routeName: (_) =>
        ForgotPasswordScreen(authService: auth),
    ProfileScreen.routeName: (_) => ProfileScreen(authService: auth),
  },
);

class FakeAuthService implements AuthService {
  FakeAuthService({
    this.user,
    this.accessToken,
    this.signInResult = const AuthResult(
      status: AuthStatus.authenticated,
      message: 'Connexion réussie.',
    ),
    this.signUpResult = const AuthResult(
      status: AuthStatus.registrationSuccess,
      message: 'Compte créé.',
    ),
  });

  AuthUserData? user;
  final String? accessToken;
  final AuthResult signInResult;
  final AuthResult signUpResult;
  int resetCalls = 0;
  int signOutCalls = 0;

  @override
  Stream<AuthUserData?> get authStateChanges => Stream.value(user);
  @override
  AuthUserData? get currentUser => user;
  @override
  bool get hasSession => user != null || accessToken != null;
  @override
  Future<String?> getAccessToken() async => accessToken;
  @override
  Future<AuthResult> resetPassword(String email) async {
    resetCalls += 1;
    return const AuthResult(
      status: AuthStatus.passwordResetSent,
      message: 'Un lien de réinitialisation a été envoyé.',
    );
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async => signInResult;
  @override
  Future<AuthResult> signOut() async {
    signOutCalls += 1;
    user = null;
    return const AuthResult(
      status: AuthStatus.unauthenticated,
      message: 'Vous êtes déconnecté.',
    );
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async => signUpResult;
}
