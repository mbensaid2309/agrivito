import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/models/agriculture_models.dart';
import 'package:agrivito_mobile/models/ai_diagnosis_models.dart';
import 'package:agrivito_mobile/services/agriculture_api_service.dart';
import 'package:agrivito_mobile/services/ai_diagnosis_api_service.dart';
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
    expect(find.text('3 questions gratuites pour tester Agrivito.'),
        findsOneWidget);
    expect(find.textContaining('3 question(s) restante(s)'), findsOneWidget);
  });

  testWidgets('Chat sends context and displays structured diagnosis',
      (tester) async {
    final diagnosisApi = FakeDiagnosisApi();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          diagnosisApi: diagnosisApi,
          diagnosisContext: const AIDiagnosisContext(
            userId: 'user-1',
            farmId: 'farm-1',
            fieldId: 'field-1',
            cropId: 'crop-1',
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('diagnosis-question')),
      'Pourquoi les feuilles jaunissent ?',
    );
    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pumpAndSettle();

    expect(diagnosisApi.lastContext?.fieldId, 'field-1');
    expect(find.text('Diagnostic Agrivito'), findsOneWidget);
    expect(find.text('Résumé'), findsOneWidget);
    expect(find.text('Observations'), findsOneWidget);
    expect(find.text('Hypothèses'), findsOneWidget);
    expect(find.text('Recommandations'), findsOneWidget);
    expect(find.text('Questions complémentaires'), findsOneWidget);
    expect(find.text('Précautions'), findsOneWidget);
    expect(find.text('Niveau de confiance'), findsOneWidget);
    expect(find.textContaining('Confiance moyenne'), findsOneWidget);
  });

  testWidgets('Chat displays loading state', (tester) async {
    final diagnosisApi = LoadingDiagnosisApi();
    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(diagnosisApi: diagnosisApi)),
    );
    await tester.enterText(
      find.byKey(const Key('diagnosis-question')),
      'Pourquoi les feuilles jaunissent ?',
    );
    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pump();

    expect(find.text('Analyse en cours...'), findsOneWidget);

    diagnosisApi.complete(_diagnosisResponse());
    await tester.pumpAndSettle();
    expect(find.text('Diagnostic Agrivito'), findsOneWidget);
  });

  testWidgets('Chat displays network error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          diagnosisApi: ErrorDiagnosisApi(AIDiagnosisErrorKind.network),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('diagnosis-question')),
      'Pourquoi les feuilles jaunissent ?',
    );
    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Impossible de contacter Agrivito.'), findsOneWidget);
  });

  testWidgets('Chat displays provider error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          diagnosisApi: ErrorDiagnosisApi(AIDiagnosisErrorKind.provider),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('diagnosis-question')),
      'Pourquoi les feuilles jaunissent ?',
    );
    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text("L'analyse est temporairement indisponible."),
      findsOneWidget,
    );
  });

  testWidgets('Chat explains insufficient information', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          diagnosisApi: FakeDiagnosisApi(insufficient: true),
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('diagnosis-question')),
      'Plante malade',
    );
    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text("Agrivito a besoin de plus d'informations."),
      findsOneWidget,
    );
    expect(find.textContaining('Informations insuffisantes'), findsOneWidget);
  });

  testWidgets('Chat validates an empty question', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(diagnosisApi: FakeDiagnosisApi())),
    );

    await tester.tap(find.byKey(const Key('diagnosis-submit')));
    await tester.pump();

    expect(
      find.text('Saisissez une question agricole avant de continuer.'),
      findsOneWidget,
    );
  });

  testWidgets('Chat reaches discovery limit after three questions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(diagnosisApi: FakeDiagnosisApi())),
    );

    for (var index = 0; index < 3; index++) {
      final questionField = find.byKey(const Key('diagnosis-question'));
      final submitButton = find.byKey(const Key('diagnosis-submit'));
      await tester.ensureVisible(questionField);
      await tester.enterText(questionField, 'Question agricole ${index + 1}');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
    }

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('diagnosis-submit')),
    );
    expect(submitButton.onPressed, isNull);
    expect(
      find.text(
          'Créez un compte pour continuer et sauvegarder votre historique.'),
      findsOneWidget,
    );
  });

  testWidgets('Login screen prepares auth and discovery access',
      (tester) async {
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
  ) async =>
      profile;

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

class FakeDiagnosisApi implements AIDiagnosisApi {
  FakeDiagnosisApi({this.insufficient = false});

  final bool insufficient;
  AIDiagnosisContext? lastContext;

  @override
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context = const AIDiagnosisContext(),
  }) async {
    lastContext = context;
    return _diagnosisResponse(insufficient: insufficient);
  }
}

class LoadingDiagnosisApi implements AIDiagnosisApi {
  final Completer<AIDiagnosisResponseData> _completer =
      Completer<AIDiagnosisResponseData>();

  void complete(AIDiagnosisResponseData response) =>
      _completer.complete(response);

  @override
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context = const AIDiagnosisContext(),
  }) =>
      _completer.future;
}

class ErrorDiagnosisApi implements AIDiagnosisApi {
  ErrorDiagnosisApi(this.kind);

  final AIDiagnosisErrorKind kind;

  @override
  Future<AIDiagnosisResponseData> diagnose({
    required String question,
    required String language,
    required String discoverySessionId,
    AIDiagnosisContext context = const AIDiagnosisContext(),
  }) async {
    final message = kind == AIDiagnosisErrorKind.network
        ? 'Impossible de contacter Agrivito.'
        : "L'analyse est temporairement indisponible.";
    throw AIDiagnosisApiException(message, kind: kind);
  }
}

AIDiagnosisResponseData _diagnosisResponse({bool insufficient = false}) {
  return AIDiagnosisResponseData(
    diagnosis: DiagnosisData(
      summary: 'Plusieurs causes sont possibles.',
      observations: const ['Les feuilles jaunissent.'],
      hypotheses: const [
        DiagnosisHypothesisData(
          label: "Excès d'eau",
          explanation: 'Le sol peut être trop humide.',
        ),
      ],
      recommendations: const ["Vérifier l'humidité du sol."],
      followUpQuestions: const ['Depuis combien de temps ?'],
      precautions: const ['Ne pas traiter sans confirmation.'],
      trustScore: DiagnosisTrustScoreData(
        score: insufficient ? 30 : 65,
        level: insufficient ? 'insufficient' : 'medium',
        explanation: 'Le contexte reste incomplet.',
      ),
      responseMode: insufficient ? 'questions_required' : 'hypotheses',
      language: 'fr',
    ),
    contextUsed: const DiagnosisContextUsedData(
      farmerProfile: false,
      farm: false,
      field: false,
      crop: false,
    ),
    usage: const DiagnosisUsageData(
      mode: 'discovery',
      questionsUsed: 1,
      questionsLimit: 3,
      remaining: 2,
    ),
  );
}
