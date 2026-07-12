import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/models/agriculture_models.dart';
import 'package:agrivito_mobile/services/agriculture_api_service.dart';
import 'package:agrivito_mobile/screens/chat_screen.dart';
import 'package:agrivito_mobile/screens/agricultural_profile_screen.dart';
import 'package:agrivito_mobile/screens/crops_screen.dart';
import 'package:agrivito_mobile/screens/farms_screen.dart';
import 'package:agrivito_mobile/screens/field_crop_screen.dart';
import 'package:agrivito_mobile/screens/login_screen.dart';
import 'package:agrivito_mobile/screens/register_screen.dart';

void main() {
  testWidgets('Agrivito app loads home screen', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );
    await tester.pump();

    expect(find.text('Agrivito'), findsOneWidget);
    expect(find.text('Assistance agricole intelligente'), findsOneWidget);
  });

  testWidgets('Chat screen shows discovery mode and limit', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );
    await tester.ensureVisible(find.text('Chat'));
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Mode découverte'), findsOneWidget);
    expect(find.text('3 questions gratuites pour tester Agrivito.'), findsOneWidget);
    expect(find.textContaining('3 question(s) restante(s)'), findsOneWidget);
  });

  testWidgets('Login screen prepares auth and discovery access', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );
    await tester.scrollUntilVisible(find.text('Login'), 300);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Connexion Agrivito'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Continuer en mode découverte'), findsOneWidget);
  });

  testWidgets('Register screen shows confirmation field', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );
    await tester.scrollUntilVisible(find.text('Register'), 300);
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte Agrivito'), findsOneWidget);
    expect(find.text('Confirmation mot de passe'), findsOneWidget);
  });

  testWidgets('Agricultural profile form is accessible', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );
    await tester.ensureVisible(find.text('Profil agricole'));
    await tester.tap(find.text('Profil agricole'));
    await tester.pumpAndSettle();

    expect(find.byType(AgriculturalProfileScreen), findsOneWidget);
    expect(find.text('Nom ou pseudo'), findsOneWidget);
    expect(find.text('Pays'), findsOneWidget);
    expect(find.text('Région'), findsOneWidget);
  });

  testWidgets('Agricultural sections are available from home', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: FakeAgricultureApi(),
      ),
    );

    expect(find.text('Mes exploitations'), findsOneWidget);
    expect(find.text('Mes cultures'), findsOneWidget);
    expect(find.text('Associer culture et parcelle'), findsOneWidget);
    expect(find.byType(FarmsScreen), findsNothing);
    expect(find.byType(CropsScreen), findsNothing);
    expect(find.byType(FieldCropScreen), findsNothing);
  });

  testWidgets('Farms screen shows loading then empty state', (tester) async {
    final api = LoadingAgricultureApi();
    await tester.pumpWidget(MaterialApp(home: FarmsScreen(api: api)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    api.complete([]);
    await tester.pumpAndSettle();

    expect(find.text('Aucune exploitation enregistrée.'), findsOneWidget);
  });

  testWidgets('Farms screen shows backend data', (tester) async {
    final api = FakeAgricultureApi(
      farms: const [
        FarmData(
          id: 'farm-1',
          userId: 'mobile-user',
          name: 'Ferme Atlas',
          country: 'Maroc',
          region: 'Souss-Massa',
          locality: 'Taroudant',
          totalArea: 4,
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: FarmsScreen(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('Ferme Atlas'), findsOneWidget);
    expect(find.text('Taroudant, Souss-Massa'), findsOneWidget);
  });

  testWidgets('Farms screen shows network error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FarmsScreen(api: NetworkErrorAgricultureApi())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impossible de contacter le serveur.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}

class FakeAgricultureApi implements AgricultureApi {
  FakeAgricultureApi({List<FarmData>? farms}) : farms = farms ?? [];

  final List<FarmData> farms;

  @override
  Future<FieldCropData> associateCrop(String fieldId, String cropId) async =>
      FieldCropData(
        id: 'association-1',
        fieldId: fieldId,
        cropId: cropId,
        status: 'active',
      );

  @override
  Future<CropData> createCrop(CropData crop) async => crop;

  @override
  Future<FarmData> createFarm(FarmData farm) async => FarmData(
        id: 'farm-created',
        userId: farm.userId,
        name: farm.name,
        country: farm.country,
        region: farm.region,
        locality: farm.locality,
        totalArea: farm.totalArea,
      );

  @override
  Future<FarmerProfileData> createFarmerProfile(
    FarmerProfileData profile,
  ) async => profile;

  @override
  Future<FieldData> createField(String farmId, FieldData field) async => field;

  @override
  Future<List<CropData>> getCrops() async => [];

  @override
  Future<List<FarmData>> getFarms() async => farms;

  @override
  Future<FarmerProfileData?> getFarmerProfile() async => null;

  @override
  Future<FieldCropData?> getFieldCrop(String fieldId) async => null;

  @override
  Future<List<FieldData>> getFields(String farmId) async => [];
}

class LoadingAgricultureApi extends FakeAgricultureApi {
  final Completer<List<FarmData>> _completer = Completer<List<FarmData>>();

  void complete(List<FarmData> farms) => _completer.complete(farms);

  @override
  Future<List<FarmData>> getFarms() => _completer.future;
}

class NetworkErrorAgricultureApi extends FakeAgricultureApi {
  @override
  Future<List<FarmData>> getFarms() async {
    throw const AgricultureApiException(
      'Impossible de contacter le serveur.',
      kind: AgricultureApiErrorKind.network,
    );
  }
}
