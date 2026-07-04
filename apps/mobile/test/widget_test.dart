import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/screens/chat_screen.dart';
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
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Mode découverte'), findsOneWidget);
    expect(find.text('3 questions gratuites pour tester Agrivito.'), findsOneWidget);
    expect(find.textContaining('3 question(s) restante(s)'), findsOneWidget);
  });

  testWidgets('Login screen prepares auth and discovery access', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Connexion Agrivito'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Continuer en mode découverte'), findsOneWidget);
  });

  testWidgets('Register screen shows confirmation field', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte Agrivito'), findsOneWidget);
    expect(find.text('Confirmation mot de passe'), findsOneWidget);
  });
}
