import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/screens/chat_screen.dart';
import 'package:agrivito_mobile/screens/agricultural_profile_screen.dart';
import 'package:agrivito_mobile/screens/crops_screen.dart';
import 'package:agrivito_mobile/screens/farms_screen.dart';
import 'package:agrivito_mobile/screens/field_crop_screen.dart';
import 'package:agrivito_mobile/screens/login_screen.dart';
import 'package:agrivito_mobile/screens/register_screen.dart';

void main() {
  testWidgets('Agrivito app loads home screen', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.pump();

    expect(find.text('Agrivito'), findsOneWidget);
    expect(find.text('Assistance agricole intelligente'), findsOneWidget);
  });

  testWidgets('Chat screen shows discovery mode and limit', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.ensureVisible(find.text('Chat'));
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Mode découverte'), findsOneWidget);
    expect(find.text('3 questions gratuites pour tester Agrivito.'), findsOneWidget);
    expect(find.textContaining('3 question(s) restante(s)'), findsOneWidget);
  });

  testWidgets('Login screen prepares auth and discovery access', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Connexion Agrivito'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Continuer en mode découverte'), findsOneWidget);
  });

  testWidgets('Register screen shows confirmation field', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte Agrivito'), findsOneWidget);
    expect(find.text('Confirmation mot de passe'), findsOneWidget);
  });

  testWidgets('Agricultural profile form is accessible', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.ensureVisible(find.text('Profil agricole'));
    await tester.tap(find.text('Profil agricole'));
    await tester.pumpAndSettle();

    expect(find.byType(AgriculturalProfileScreen), findsOneWidget);
    expect(find.text('Nom ou pseudo'), findsOneWidget);
    expect(find.text('Pays'), findsOneWidget);
    expect(find.text('Région'), findsOneWidget);
  });

  testWidgets('Agricultural sections are available from home', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));

    expect(find.text('Mes exploitations'), findsOneWidget);
    expect(find.text('Mes cultures'), findsOneWidget);
    expect(find.text('Associer culture et parcelle'), findsOneWidget);
    expect(find.byType(FarmsScreen), findsNothing);
    expect(find.byType(CropsScreen), findsNothing);
    expect(find.byType(FieldCropScreen), findsNothing);
  });
}
