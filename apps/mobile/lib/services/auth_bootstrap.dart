import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import 'auth_service.dart';

class AuthBootstrap {
  static Future<AuthService> initialize() async {
    if (!AppConfig.hasSupabaseConfiguration) {
      return const UnavailableAuthService();
    }
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      return SupabaseAuthService(Supabase.instance.client);
    } catch (_) {
      return const UnavailableAuthService();
    }
  }
}
