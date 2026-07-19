import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/agriculture_api_service.dart';
import 'services/ai_diagnosis_api_service.dart';
import 'services/media_api_service.dart';
import 'services/media_picker_service.dart';
import 'services/photo_diagnosis_api_service.dart';
import 'services/auth_bootstrap.dart';
import 'services/auth_service.dart';
import 'services/authenticated_http_client.dart';
import 'screens/agricultural_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/crops_screen.dart';
import 'screens/diagnostic_result_screen.dart';
import 'screens/farms_screen.dart';
import 'screens/field_crop_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/photo_diagnosis_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthBootstrap.initialize();
  runApp(AgrivitoApp(authService: authService));
}

final _navigatorKey = GlobalKey<NavigatorState>();

class AgrivitoApp extends StatelessWidget {
  const AgrivitoApp({
    super.key,
    this.enableHealthCheck = true,
    this.agricultureApi,
    this.diagnosisApi,
    this.mediaApi,
    this.mediaPicker,
    this.photoDiagnosisApi,
    this.authService = const UnavailableAuthService(),
    this.httpClient,
  });

  final bool enableHealthCheck;
  final AgricultureApi? agricultureApi;
  final AIDiagnosisApi? diagnosisApi;
  final MediaApi? mediaApi;
  final MediaPicker? mediaPicker;
  final PhotoDiagnosisApi? photoDiagnosisApi;
  final AuthService authService;
  final http.Client? httpClient;

  @override
  Widget build(BuildContext context) {
    final privateClient =
        httpClient ??
        AuthenticatedHttpClient(
          auth: authService,
          onSessionExpired: () => _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false),
        );
    final api = agricultureApi ?? AgricultureApiService(client: privateClient);
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Agrivito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7D32)),
        useMaterial3: true,
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) =>
            HomeScreen(enableHealthCheck: enableHealthCheck),
        ChatScreen.routeName: (_) => ChatScreen(
          diagnosisApi:
              diagnosisApi ??
              AIDiagnosisApiService(
                client: privateClient,
                authService: authService,
              ),
        ),
        DiagnosticResultScreen.routeName: (_) => const DiagnosticResultScreen(),
        LoginScreen.routeName: (_) => LoginScreen(authService: authService),
        RegisterScreen.routeName: (_) =>
            RegisterScreen(authService: authService),
        ForgotPasswordScreen.routeName: (_) =>
            ForgotPasswordScreen(authService: authService),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        ProfileScreen.routeName: (_) => ProfileScreen(authService: authService),
        AgriculturalProfileScreen.routeName: (_) =>
            AgriculturalProfileScreen(api: api),
        FarmsScreen.routeName: (_) => FarmsScreen(api: api),
        CropsScreen.routeName: (_) => CropsScreen(api: api),
        FieldCropScreen.routeName: (_) => FieldCropScreen(api: api),
        PhotoUploadScreen.routeName: (_) => PhotoUploadScreen(
          mediaApi:
              mediaApi ??
              MediaApiService(client: privateClient, authService: authService),
          mediaPicker: mediaPicker ?? ImagePickerMediaPicker(),
          photoDiagnosisApi:
              photoDiagnosisApi ??
              PhotoDiagnosisApiService(
                client: privateClient,
                authService: authService,
              ),
        ),
        PhotoDiagnosisScreen.routeName: (_) => PhotoDiagnosisScreen(
          api:
              photoDiagnosisApi ??
              PhotoDiagnosisApiService(
                client: privateClient,
                authService: authService,
              ),
        ),
      },
    );
  }
}
