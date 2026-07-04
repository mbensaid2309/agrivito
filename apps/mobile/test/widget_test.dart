import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';

void main() {
  testWidgets('Agrivito app loads home screen', (tester) async {
    await tester.pumpWidget(const AgrivitoApp(enableHealthCheck: false));
    await tester.pump();

    expect(find.text('Agrivito'), findsOneWidget);
    expect(find.text('Assistance agricole intelligente'), findsOneWidget);
  });
}
