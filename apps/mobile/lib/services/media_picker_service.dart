import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/media_models.dart';

enum MediaPickSource { camera, gallery }

enum MediaPickerErrorKind {
  permissionDenied,
  permissionPermanentlyDenied,
  cameraUnavailable,
  invalidFormat,
  unavailable,
}

class MediaPickerException implements Exception {
  const MediaPickerException(this.kind);

  final MediaPickerErrorKind kind;
}

abstract interface class MediaPicker {
  Future<SelectedMedia?> pick(MediaPickSource source);
}

class ImagePickerMediaPicker implements MediaPicker {
  ImagePickerMediaPicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<SelectedMedia?> pick(MediaPickSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == MediaPickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (file == null) return null;
      final contentType = file.mimeType ?? _mimeTypeForName(file.name);
      if (contentType == null) {
        throw const MediaPickerException(MediaPickerErrorKind.invalidFormat);
      }
      final Uint8List bytes = await file.readAsBytes();
      return SelectedMedia(
        bytes: bytes,
        filename: file.name,
        contentType: contentType,
      );
    } on MediaPickerException {
      rethrow;
    } on PlatformException catch (error) {
      throw MediaPickerException(_kindForPlatformCode(error.code));
    } catch (_) {
      throw const MediaPickerException(MediaPickerErrorKind.unavailable);
    }
  }

  static String? _mimeTypeForName(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return null;
  }

  static MediaPickerErrorKind _kindForPlatformCode(String code) {
    switch (code) {
      case 'camera_access_denied':
      case 'photo_access_denied':
        return MediaPickerErrorKind.permissionDenied;
      case 'camera_access_restricted':
      case 'photo_access_restricted':
        return MediaPickerErrorKind.permissionPermanentlyDenied;
      case 'camera_unavailable':
        return MediaPickerErrorKind.cameraUnavailable;
      default:
        return MediaPickerErrorKind.unavailable;
    }
  }
}
