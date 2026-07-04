class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class AuthService {
  const AuthService();

  Future<AuthResult> login({
    required String email,
    required String password,
  }) {
    final hasRequiredFields = email.trim().isNotEmpty && password.isNotEmpty;
    if (!hasRequiredFields) {
      return Future.value(const AuthResult(
        success: false,
        message: 'Email et mot de passe sont obligatoires.',
      ));
    }

    return Future.value(const AuthResult(
      success: false,
      message: 'Auth Cognito via Amplify sera connectée plus tard.',
    ));
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) {
    final hasRequiredFields =
        name.trim().isNotEmpty && email.trim().isNotEmpty && password.isNotEmpty;
    if (!hasRequiredFields) {
      return Future.value(const AuthResult(
        success: false,
        message: 'Nom, email et mot de passe sont obligatoires.',
      ));
    }

    return Future.value(const AuthResult(
      success: false,
      message: 'Création de compte Cognito via Amplify sera connectée plus tard.',
    ));
  }
}
