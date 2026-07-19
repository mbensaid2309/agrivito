import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrivito_mobile/main.dart';
import 'package:agrivito_mobile/models/agriculture_models.dart';
import 'package:agrivito_mobile/models/media_models.dart';
import 'package:agrivito_mobile/screens/photo_upload_screen.dart';
import 'package:agrivito_mobile/services/agriculture_api_service.dart';
import 'package:agrivito_mobile/services/media_api_service.dart';
import 'package:agrivito_mobile/services/media_picker_service.dart';

void main() {
  testWidgets('photo screen is accessible from home', (tester) async {
    await tester.pumpWidget(
      AgrivitoApp(
        enableHealthCheck: false,
        agricultureApi: EmptyAgricultureApi(),
        mediaApi: FakeMediaApi(),
        mediaPicker: QueueMediaPicker([]),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer une photo'));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoUploadScreen), findsOneWidget);
    expect(find.text('Choisissez ou prenez une photo.'), findsOneWidget);
    expect(find.textContaining('analyse visuelle prudente'), findsOneWidget);
  });

  testWidgets('gallery selection shows preview and cancellation clears it', (
    tester,
  ) async {
    final picker = QueueMediaPicker([_selectedMedia('gallery.png')]);
    await tester.pumpWidget(_app(picker: picker));

    await tester.tap(find.byKey(const Key('photo-gallery')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-preview')), findsOneWidget);
    expect(picker.sources, [MediaPickSource.gallery]);

    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-empty-preview')), findsOneWidget);
    expect(find.byKey(const Key('photo-preview')), findsNothing);
  });

  testWidgets('camera selection can replace a gallery photo', (tester) async {
    final picker = QueueMediaPicker([
      _selectedMedia('first.png'),
      _selectedMedia('second.png'),
    ]);
    final api = FakeMediaApi();
    await tester.pumpWidget(_app(picker: picker, api: api));

    await tester.tap(find.byKey(const Key('photo-gallery')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-camera')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-upload')));
    await tester.pumpAndSettle();

    expect(picker.sources, [MediaPickSource.gallery, MediaPickSource.camera]);
    expect(api.lastMedia?.filename, 'second.png');
  });

  testWidgets('upload displays progress then success', (tester) async {
    final api = LoadingMediaApi();
    await tester.pumpWidget(
      _app(picker: QueueMediaPicker([_selectedMedia('leaf.png')]), api: api),
    );
    await tester.tap(find.byKey(const Key('photo-gallery')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('photo-upload')));
    await tester.pump();
    expect(find.text('Envoi en cours...'), findsOneWidget);

    api.complete(_uploadedMedia());
    await tester.pumpAndSettle();
    expect(find.text('Photo envoyée avec succès.'), findsOneWidget);
    expect(find.textContaining('Référence média'), findsOneWidget);
  });

  testWidgets('permission errors are understandable', (tester) async {
    await tester.pumpWidget(
      _app(picker: ErrorMediaPicker(MediaPickerErrorKind.permissionDenied)),
    );

    await tester.tap(find.byKey(const Key('photo-camera')));
    await tester.pumpAndSettle();

    expect(
      find.text('Autorisez l’accès à la caméra pour prendre une photo.'),
      findsOneWidget,
    );
  });

  testWidgets('network and validation errors are displayed', (tester) async {
    for (final entry in {
      MediaApiErrorKind.network: 'Impossible d’envoyer la photo.',
      MediaApiErrorKind.validation: 'La photo est trop volumineuse.',
    }.entries) {
      await tester.pumpWidget(
        _app(
          picker: QueueMediaPicker([_selectedMedia('leaf.png')]),
          api: ErrorMediaApi(entry.key, entry.value),
        ),
      );
      await tester.tap(find.byKey(const Key('photo-gallery')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('photo-upload')));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('discovery limit disables another upload', (tester) async {
    await tester.pumpWidget(
      _app(
        picker: QueueMediaPicker([_selectedMedia('leaf.png')]),
        api: ErrorMediaApi(
          MediaApiErrorKind.discoveryLimit,
          'Vous avez atteint la limite du mode découverte.',
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('photo-gallery')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-upload')));
    await tester.pumpAndSettle();

    expect(
      find.text('Vous avez atteint la limite du mode découverte.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('photo-upload')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('agricultural context and discovery session are sent', (
    tester,
  ) async {
    final api = FakeMediaApi();
    await tester.pumpWidget(
      MaterialApp(
        home: PhotoUploadScreen(
          mediaApi: api,
          mediaPicker: QueueMediaPicker([_selectedMedia('leaf.png')]),
          discoverySessionId: 'session-1',
          context: const MediaUploadContext(
            farmId: 'farm-1',
            fieldId: 'field-1',
            cropId: 'crop-1',
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('photo-gallery')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-upload')));
    await tester.pumpAndSettle();

    expect(api.lastContext?.discoverySessionId, 'session-1');
    expect(api.lastContext?.farmId, 'farm-1');
    expect(api.lastContext?.fieldId, 'field-1');
    expect(api.lastContext?.cropId, 'crop-1');
    await tester.scrollUntilVisible(
      find.text('Contexte agricole associé'),
      300,
    );
    expect(find.text('Contexte agricole associé'), findsOneWidget);
  });
}

Widget _app({required MediaPicker picker, MediaApi? api}) => MaterialApp(
  home: PhotoUploadScreen(
    mediaApi: api ?? FakeMediaApi(),
    mediaPicker: picker,
    discoverySessionId: 'test-session',
  ),
);

SelectedMedia _selectedMedia(String filename) => SelectedMedia(
  bytes: Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  ),
  filename: filename,
  contentType: 'image/png',
);

MediaData _uploadedMedia() => MediaData(
  id: 'media-1',
  originalFilename: 'leaf.png',
  contentType: 'image/png',
  sizeBytes: 68,
  storageProvider: 'local',
  status: 'uploaded',
  createdAt: DateTime.utc(2026, 7, 14),
);

class QueueMediaPicker implements MediaPicker {
  QueueMediaPicker(this.items);

  final List<SelectedMedia?> items;
  final List<MediaPickSource> sources = [];

  @override
  Future<SelectedMedia?> pick(MediaPickSource source) async {
    sources.add(source);
    return items.removeAt(0);
  }
}

class ErrorMediaPicker implements MediaPicker {
  ErrorMediaPicker(this.kind);

  final MediaPickerErrorKind kind;

  @override
  Future<SelectedMedia?> pick(MediaPickSource source) async {
    throw MediaPickerException(kind);
  }
}

class FakeMediaApi implements MediaApi {
  SelectedMedia? lastMedia;
  MediaUploadContext? lastContext;

  @override
  Future<MediaData> upload({
    required SelectedMedia media,
    MediaUploadContext context = const MediaUploadContext(),
  }) async {
    lastMedia = media;
    lastContext = context;
    return _uploadedMedia();
  }
}

class LoadingMediaApi extends FakeMediaApi {
  final Completer<MediaData> _completer = Completer<MediaData>();

  void complete(MediaData media) => _completer.complete(media);

  @override
  Future<MediaData> upload({
    required SelectedMedia media,
    MediaUploadContext context = const MediaUploadContext(),
  }) => _completer.future;
}

class ErrorMediaApi extends FakeMediaApi {
  ErrorMediaApi(this.kind, this.message);

  final MediaApiErrorKind kind;
  final String message;

  @override
  Future<MediaData> upload({
    required SelectedMedia media,
    MediaUploadContext context = const MediaUploadContext(),
  }) async {
    throw MediaApiException(message, kind: kind);
  }
}

class EmptyAgricultureApi implements AgricultureApi {
  @override
  Future<FieldCropData> associateCrop(String fieldId, String cropId) =>
      throw UnimplementedError();

  @override
  Future<CropData> createCrop(CropData crop) => throw UnimplementedError();

  @override
  Future<FarmData> createFarm(FarmData farm) => throw UnimplementedError();

  @override
  Future<FarmerProfileData> createFarmerProfile(FarmerProfileData profile) =>
      throw UnimplementedError();

  @override
  Future<FieldData> createField(String farmId, FieldData field) =>
      throw UnimplementedError();

  @override
  Future<List<CropData>> getCrops() async => [];

  @override
  Future<List<FarmData>> getFarms() async => [];

  @override
  Future<FarmerProfileData?> getFarmerProfile() async => null;

  @override
  Future<FieldCropData?> getFieldCrop(String fieldId) async => null;

  @override
  Future<List<FieldData>> getFields(String farmId) async => [];
}
