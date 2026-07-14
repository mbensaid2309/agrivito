import 'package:flutter/material.dart';

import 'services/agriculture_api_service.dart';
import 'services/ai_diagnosis_api_service.dart';
import 'services/media_api_service.dart';
import 'services/media_picker_service.dart';
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
import 'screens/register_screen.dart';

void main() {
  runApp(const AgrivitoApp());
}

class AgrivitoApp extends StatelessWidget {
  const AgrivitoApp({
    super.key,
    this.enableHealthCheck = true,
    this.agricultureApi,
    this.diagnosisApi,
    this.mediaApi,
    this.mediaPicker,
  });

  final bool enableHealthCheck;
  final AgricultureApi? agricultureApi;
  final AIDiagnosisApi? diagnosisApi;
  final MediaApi? mediaApi;
  final MediaPicker? mediaPicker;

  @override
  Widget build(BuildContext context) {
    final api = agricultureApi ?? const AgricultureApiService();
    return MaterialApp(
      title: 'Agrivito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7D32)),
        useMaterial3: true,
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => HomeScreen(
              enableHealthCheck: enableHealthCheck,
            ),
        ChatScreen.routeName: (_) => ChatScreen(
              diagnosisApi: diagnosisApi ?? const AIDiagnosisApiService(),
            ),
        DiagnosticResultScreen.routeName: (_) => const DiagnosticResultScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        AgriculturalProfileScreen.routeName: (_) =>
            AgriculturalProfileScreen(api: api),
        FarmsScreen.routeName: (_) => FarmsScreen(api: api),
        CropsScreen.routeName: (_) => CropsScreen(api: api),
        FieldCropScreen.routeName: (_) => FieldCropScreen(api: api),
        PhotoUploadScreen.routeName: (_) => PhotoUploadScreen(
              mediaApi: mediaApi ?? const MediaApiService(),
              mediaPicker: mediaPicker ?? ImagePickerMediaPicker(),
            ),
      },
    );
  }
}
