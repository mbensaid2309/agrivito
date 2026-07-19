import 'dart:typed_data';

enum PhotoUploadState {
  idle,
  selecting,
  preview,
  uploading,
  success,
  validationError,
  permissionError,
  networkError,
  backendError,
  discoveryLimitReached,
}

class SelectedMedia {
  const SelectedMedia({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;
  final String contentType;
}

class MediaUploadContext {
  const MediaUploadContext({
    this.discoverySessionId,
    this.farmId,
    this.fieldId,
    this.cropId,
  });

  final String? discoverySessionId;
  final String? farmId;
  final String? fieldId;
  final String? cropId;

  Map<String, String> toFields() => {
    if (_present(discoverySessionId))
      'discovery_session_id': discoverySessionId!.trim(),
    if (_present(farmId)) 'farm_id': farmId!.trim(),
    if (_present(fieldId)) 'field_id': fieldId!.trim(),
    if (_present(cropId)) 'crop_id': cropId!.trim(),
  };

  static bool _present(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class MediaData {
  const MediaData({
    required this.id,
    required this.originalFilename,
    required this.contentType,
    required this.sizeBytes,
    required this.storageProvider,
    required this.status,
    required this.createdAt,
    this.farmId,
    this.fieldId,
    this.cropId,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) => MediaData(
    id: json['id'] as String,
    originalFilename: json['original_filename'] as String,
    contentType: json['content_type'] as String,
    sizeBytes: json['size_bytes'] as int,
    storageProvider: json['storage_provider'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    farmId: json['farm_id'] as String?,
    fieldId: json['field_id'] as String?,
    cropId: json['crop_id'] as String?,
  );

  final String id;
  final String originalFilename;
  final String contentType;
  final int sizeBytes;
  final String storageProvider;
  final String status;
  final DateTime createdAt;
  final String? farmId;
  final String? fieldId;
  final String? cropId;
}
