class AppConfig {
  static const backendBaseUrl = String.fromEnvironment(
    'AGRIVITO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
