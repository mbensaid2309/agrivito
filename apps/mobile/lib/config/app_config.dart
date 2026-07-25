class AppConfig {
  static const backendBaseUrl = String.fromEnvironment(
    'AGRIVITO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );
  static const authMode = String.fromEnvironment(
    'AUTH_MODE',
    defaultValue: 'mock',
  );

  static const demoEmail = 'agriculteur.demo@agrivito.local';
  static const demoPassword = 'DemoAgrivito123!';

  static bool get usesMockAuth => authMode.toLowerCase() == 'mock';

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
