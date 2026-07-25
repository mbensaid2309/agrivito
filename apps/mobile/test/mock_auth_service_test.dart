import 'package:agrivito_mobile/config/app_config.dart';
import 'package:agrivito_mobile/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('demo credentials create a backend-compatible session', () async {
    final service = MockAuthService.initialize(
      await SharedPreferences.getInstance(),
    );

    final result = await service.signIn(
      email: AppConfig.demoEmail,
      password: AppConfig.demoPassword,
    );

    expect(result.status, AuthStatus.authenticated);
    expect(service.currentUser?.email, AppConfig.demoEmail);
    expect(await service.getAccessToken(), 'mock-valid-token');
  });

  test('mock session is restored and can be cleared', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = MockAuthService.initialize(preferences);
    await first.signIn(
      email: AppConfig.demoEmail,
      password: AppConfig.demoPassword,
    );

    final restored = MockAuthService.initialize(preferences);
    expect(restored.hasSession, isTrue);

    await restored.signOut();
    final signedOut = MockAuthService.initialize(preferences);
    expect(signedOut.hasSession, isFalse);
  });

  test('mock auth rejects unknown credentials', () async {
    final service = MockAuthService.initialize(
      await SharedPreferences.getInstance(),
    );
    final result = await service.signIn(
      email: 'unknown@example.test',
      password: 'wrong-password',
    );

    expect(result.status, AuthStatus.invalidCredentials);
    expect(service.hasSession, isFalse);
  });
}
