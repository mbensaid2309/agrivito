class AppConfig {
  static const backendBaseUrl = String.fromEnvironment(
    'AGRIVITO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
