import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/models/ai_diagnosis_models.dart';
import 'package:agrivito_mobile/models/media_models.dart';
import 'package:agrivito_mobile/models/photo_diagnosis_models.dart';
import 'package:agrivito_mobile/screens/photo_diagnosis_screen.dart';
import 'package:agrivito_mobile/services/photo_diagnosis_api_service.dart';

void main() {
  testWidgets('photo diagnosis screen is accessible from home', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        photoDiagnosisApi: FakePhotoDiagnosisApi(_result()),
      ),
    );
    await tester.scrollUntilVisible(find.text('Analyser une photo'), 300);
    await tester.tap(find.text('Analyser une photo'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoDiagnosisScreen), findsOneWidget);
  });

  testWidgets('selected media, question, loading and all result sections',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = LoadingPhotoDiagnosisApi();
    await tester.pumpWidget(_screen(api));
    expect(find.text('media-1'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('photo-diagnosis-question')),
      'Pourquoi les feuilles sont-elles tachées ?',
    );
    await tester.tap(find.byKey(const Key('photo-diagnosis-submit')));
    await tester.pump();
    expect(find.text('Analyse de la photo en cours...'), findsOneWidget);
    expect(api.question, 'Pourquoi les feuilles sont-elles tachées ?');
    expect(api.mediaId, 'media-1');

    api.complete(_result());
    await tester.pumpAndSettle();
    for (final text in [
      'Qualité photo',
      'Résumé',
      'Observations visuelles',
      'Hypothèses',
      'Recommandations',
      'Questions complémentaires',
      'Précautions',
      'Niveau de confiance',
    ]) {
      expect(find.text(text), findsWidgets);
    }
    expect(find.byKey(const Key('photo-diagnosis-limit-invitation')),
        findsOneWidget);
  });

  testWidgets('poor photo displays retake instructions', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester
        .pumpWidget(_screen(FakePhotoDiagnosisApi(_result(retake: true))));
    await tester.tap(find.byKey(const Key('photo-diagnosis-submit')));
    await tester.pumpAndSettle();
    expect(find.text('La photo n’est pas assez nette.'), findsOneWidget);
    expect(find.textContaining('Prenez une photo plus proche.'), findsOneWidget);
  });

  for (final entry in {
    PhotoDiagnosisApiErrorKind.network: 'Impossible de contacter Agrivito.',
    PhotoDiagnosisApiErrorKind.provider:
        'L’analyse visuelle est temporairement indisponible.',
    PhotoDiagnosisApiErrorKind.mediaNotFound:
        'La photo demandée est introuvable.',
    PhotoDiagnosisApiErrorKind.discoveryLimit:
        'Vous avez atteint la limite du mode découverte.',
  }.entries) {
    testWidgets('displays ${entry.key.name} error', (tester) async {
      await tester.pumpWidget(
        _screen(ErrorPhotoDiagnosisApi(entry.key, entry.value)),
      );
      await tester.tap(find.byKey(const Key('photo-diagnosis-submit')));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      if (entry.key == PhotoDiagnosisApiErrorKind.discoveryLimit) {
        expect(find.textContaining('Créez un compte'), findsOneWidget);
      }
    });
  }
}

Widget _screen(PhotoDiagnosisApi api) => MaterialApp(
      home: PhotoDiagnosisScreen(
        api: api,
        initialMedia: _media(),
        discoverySessionId: 'session-1',
      ),
    );

MediaData _media() => MediaData(
      id: 'media-1',
      originalFilename: 'leaf.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 2048,
      storageProvider: 'local',
      status: 'uploaded',
      createdAt: DateTime.utc(2026, 7, 19),
    );

PhotoDiagnosisResponseData _result({bool retake = false}) =>
    PhotoDiagnosisResponseData(
      diagnosis: PhotoDiagnosisData(
        id: 'diagnosis-1',
        mediaId: 'media-1',
        summary: 'Résumé prudent.',
        photoQuality: PhotoQualityData(
          score: retake ? 42 : 88,
          level: retake ? 'poor' : 'good',
          issues: retake ? ['Photo floue.'] : [],
          retakeRequired: retake,
          retakeInstructions: retake ? ['Prenez une photo plus proche.'] : [],
        ),
        observations: const ['Observation visible.'],
        hypotheses: const [
          DiagnosisHypothesisData(
            label: 'Hypothèse prudente',
            explanation: 'Plusieurs causes restent possibles.',
          ),
        ],
        recommendations: const ['Observer plusieurs plants.'],
        followUpQuestions: const ['Depuis combien de temps ?'],
        precautions: const ['Une photo seule ne confirme pas une maladie.'],
        trustScore: const DiagnosisTrustScoreData(
          score: 72,
          level: 'medium',
          explanation: 'Score calculé par Agrivito.',
        ),
        responseMode: retake ? 'questions_required' : 'hypotheses',
        language: 'fr',
        status: 'completed',
      ),
      contextUsed: const DiagnosisContextUsedData(
        farmerProfile: false,
        farm: false,
        field: false,
        crop: false,
      ),
      usage: const PhotoDiagnosisUsageData(
        mode: 'discovery',
        diagnosesUsed: 1,
        diagnosesLimit: 1,
        remaining: 0,
      ),
    );

class FakePhotoDiagnosisApi implements PhotoDiagnosisApi {
  FakePhotoDiagnosisApi(this.result);

  final PhotoDiagnosisResponseData result;

  @override
  Future<PhotoDiagnosisResponseData> diagnose({
    required String mediaId,
    required String question,
    required String language,
    required String discoverySessionId,
    PhotoDiagnosisContext context = const PhotoDiagnosisContext(),
  }) async =>
      result;
}

class LoadingPhotoDiagnosisApi implements PhotoDiagnosisApi {
  final Completer<PhotoDiagnosisResponseData> _completer = Completer();
  String? mediaId;
  String? question;

  void complete(PhotoDiagnosisResponseData result) =>
      _completer.complete(result);

  @override
  Future<PhotoDiagnosisResponseData> diagnose({
    required String mediaId,
    required String question,
    required String language,
    required String discoverySessionId,
    PhotoDiagnosisContext context = const PhotoDiagnosisContext(),
  }) {
    this.mediaId = mediaId;
    this.question = question;
    return _completer.future;
  }
}

class ErrorPhotoDiagnosisApi implements PhotoDiagnosisApi {
  ErrorPhotoDiagnosisApi(this.kind, this.message);

  final PhotoDiagnosisApiErrorKind kind;
  final String message;

  @override
  Future<PhotoDiagnosisResponseData> diagnose({
    required String mediaId,
    required String question,
    required String language,
    required String discoverySessionId,
    PhotoDiagnosisContext context = const PhotoDiagnosisContext(),
  }) async {
    throw PhotoDiagnosisApiException(message, kind: kind);
  }
}
