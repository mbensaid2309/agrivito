import 'package:flutter/material.dart';

import '../models/media_models.dart';
import '../services/media_api_service.dart';
import '../services/media_picker_service.dart';

class PhotoUploadScreen extends StatefulWidget {
  static const routeName = '/photo-upload';

  const PhotoUploadScreen({
    super.key,
    required this.mediaApi,
    required this.mediaPicker,
    this.context = const MediaUploadContext(),
    this.discoverySessionId,
  });

  final MediaApi mediaApi;
  final MediaPicker mediaPicker;
  final MediaUploadContext context;
  final String? discoverySessionId;

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  PhotoUploadState _state = PhotoUploadState.idle;
  SelectedMedia? _selection;
  MediaData? _uploadedMedia;
  String _message = 'Choisissez ou prenez une photo.';
  late final String _discoverySessionId;

  @override
  void initState() {
    super.initState();
    _discoverySessionId = widget.discoverySessionId ??
        'photo-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _pick(MediaPickSource source) async {
    final previous = _selection;
    setState(() {
      _state = PhotoUploadState.selecting;
      _message = 'Sélection en cours...';
    });
    try {
      final selected = await widget.mediaPicker.pick(source);
      if (!mounted) return;
      if (selected == null) {
        setState(() {
          _selection = previous;
          _state = previous == null
              ? PhotoUploadState.idle
              : PhotoUploadState.preview;
          _message = previous == null
              ? 'Choisissez ou prenez une photo.'
              : 'Photo prête à être envoyée.';
        });
        return;
      }
      setState(() {
        _selection = selected;
        _uploadedMedia = null;
        _state = PhotoUploadState.preview;
        _message = 'Photo prête à être envoyée.';
      });
    } on MediaPickerException catch (error) {
      if (!mounted) return;
      setState(() {
        _selection = previous;
        _state = error.kind == MediaPickerErrorKind.invalidFormat
            ? PhotoUploadState.validationError
            : PhotoUploadState.permissionError;
        _message = _pickerErrorMessage(error.kind, source);
      });
    }
  }

  Future<void> _upload() async {
    final selection = _selection;
    if (selection == null) return;
    setState(() {
      _state = PhotoUploadState.uploading;
      _message = 'Envoi en cours...';
    });
    try {
      final contextFields = widget.context.toFields();
      final result = await widget.mediaApi.upload(
        media: selection,
        context: MediaUploadContext(
          userId: contextFields['user_id'],
          discoverySessionId: contextFields['user_id'] == null
              ? widget.context.discoverySessionId ?? _discoverySessionId
              : widget.context.discoverySessionId,
          farmId: widget.context.farmId,
          fieldId: widget.context.fieldId,
          cropId: widget.context.cropId,
        ),
      );
      if (!mounted) return;
      setState(() {
        _uploadedMedia = result;
        _state = PhotoUploadState.success;
        _message = 'Photo envoyée avec succès.';
      });
    } on MediaApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _state = switch (error.kind) {
          MediaApiErrorKind.validation => PhotoUploadState.validationError,
          MediaApiErrorKind.network => PhotoUploadState.networkError,
          MediaApiErrorKind.backend => PhotoUploadState.backendError,
          MediaApiErrorKind.discoveryLimit =>
            PhotoUploadState.discoveryLimitReached,
        };
        _message = error.message;
      });
    }
  }

  void _cancelSelection() {
    setState(() {
      _selection = null;
      _uploadedMedia = null;
      _state = PhotoUploadState.idle;
      _message = 'Choisissez ou prenez une photo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _state == PhotoUploadState.selecting ||
        _state == PhotoUploadState.uploading;
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer une photo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Photo agricole',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'La photo sera enregistrée. L’analyse visuelle sera disponible '
              'dans une prochaine version.',
            ),
            const SizedBox(height: 16),
            if (_selection == null)
              _EmptyPreview(isSelecting: _state == PhotoUploadState.selecting)
            else
              _PhotoPreview(selection: _selection!),
            const SizedBox(height: 16),
            Text(
              _message,
              key: const Key('photo-status-message'),
              style: TextStyle(
                color: _isErrorState(_state)
                    ? Theme.of(context).colorScheme.error
                    : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_uploadedMedia != null) ...[
              const SizedBox(height: 8),
              Text('Référence média : ${_uploadedMedia!.id}'),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('photo-camera'),
                    onPressed:
                        isBusy ? null : () => _pick(MediaPickSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(_selection == null ? 'Caméra' : 'Remplacer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('photo-gallery'),
                    onPressed:
                        isBusy ? null : () => _pick(MediaPickSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                  ),
                ),
              ],
            ),
            if (_selection != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('photo-upload'),
                onPressed:
                    isBusy || _state == PhotoUploadState.discoveryLimitReached
                        ? null
                        : _upload,
                icon: _state == PhotoUploadState.uploading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text('Envoyer la photo'),
              ),
              TextButton(
                key: const Key('photo-cancel'),
                onPressed: isBusy ? null : _cancelSelection,
                child: const Text('Annuler'),
              ),
            ],
            if (widget.context.farmId != null ||
                widget.context.fieldId != null ||
                widget.context.cropId != null) ...[
              const Divider(height: 32),
              Text(
                'Contexte agricole associé',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.context.farmId != null)
                Text('Exploitation : ${widget.context.farmId}'),
              if (widget.context.fieldId != null)
                Text('Parcelle : ${widget.context.fieldId}'),
              if (widget.context.cropId != null)
                Text('Culture : ${widget.context.cropId}'),
            ],
          ],
        ),
      ),
    );
  }

  static String _pickerErrorMessage(
    MediaPickerErrorKind kind,
    MediaPickSource source,
  ) {
    if (kind == MediaPickerErrorKind.invalidFormat) {
      return 'Ce format n’est pas supporté.';
    }
    if (kind == MediaPickerErrorKind.cameraUnavailable) {
      return 'La caméra n’est pas disponible sur cet appareil.';
    }
    if (source == MediaPickSource.camera) {
      return 'Autorisez l’accès à la caméra pour prendre une photo.';
    }
    return 'Autorisez l’accès aux photos pour choisir une image.';
  }

  static bool _isErrorState(PhotoUploadState state) => {
        PhotoUploadState.validationError,
        PhotoUploadState.permissionError,
        PhotoUploadState.networkError,
        PhotoUploadState.backendError,
        PhotoUploadState.discoveryLimitReached,
      }.contains(state);
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.isSelecting});

  final bool isSelecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('photo-empty-preview'),
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isSelecting
          ? const CircularProgressIndicator()
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo_outlined, size: 48),
                SizedBox(height: 8),
                Text('Aucune photo sélectionnée'),
              ],
            ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.selection});

  final SelectedMedia selection;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: const Key('photo-preview'),
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        selection.bytes,
        height: 260,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: 260,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 56),
        ),
      ),
    );
  }
}
