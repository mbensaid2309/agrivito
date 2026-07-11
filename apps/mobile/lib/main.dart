import 'package:flutter/material.dart';

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
import 'screens/register_screen.dart';

void main() {
  runApp(const AgrivitoApp());
}

class AgrivitoApp extends StatelessWidget {
  const AgrivitoApp({super.key, this.enableHealthCheck = true});

  final bool enableHealthCheck;

  @override
  Widget build(BuildContext context) {
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
        ChatScreen.routeName: (_) => const ChatScreen(),
        DiagnosticResultScreen.routeName: (_) => const DiagnosticResultScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        AgriculturalProfileScreen.routeName: (_) =>
            const AgriculturalProfileScreen(),
        FarmsScreen.routeName: (_) => const FarmsScreen(),
        CropsScreen.routeName: (_) => const CropsScreen(),
        FieldCropScreen.routeName: (_) => const FieldCropScreen(),
      },
    );
  }
}
