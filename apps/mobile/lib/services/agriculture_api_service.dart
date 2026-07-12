import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/agriculture_models.dart';

abstract class AgricultureApi {
  Future<FarmerProfileData?> getFarmerProfile();
  Future<FarmerProfileData> createFarmerProfile(FarmerProfileData profile);
  Future<List<FarmData>> getFarms();
  Future<FarmData> createFarm(FarmData farm);
  Future<List<FieldData>> getFields(String farmId);
  Future<FieldData> createField(String farmId, FieldData field);
  Future<List<CropData>> getCrops();
  Future<CropData> createCrop(CropData crop);
  Future<FieldCropData> associateCrop(String fieldId, String cropId);
  Future<FieldCropData?> getFieldCrop(String fieldId);
}

class AgricultureApiService implements AgricultureApi {
  const AgricultureApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<FarmerProfileData?> getFarmerProfile() async {
    final response = await _request('GET', '/farmer/profile', allowNotFound: true);
    if (response == null) {
      return null;
    }
    return FarmerProfileData.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<FarmerProfileData> createFarmerProfile(
    FarmerProfileData profile,
  ) async {
    final response = await _request(
      'POST',
      '/farmer/profile',
      body: profile.toJson(),
    );
    return FarmerProfileData.fromJson(response! as Map<String, dynamic>);
  }

  @override
  Future<List<FarmData>> getFarms() async {
    final response = await _request('GET', '/farms') as List<dynamic>;
    return response
        .map((item) => FarmData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FarmData> createFarm(FarmData farm) async {
    final response = await _request('POST', '/farms', body: farm.toJson());
    return FarmData.fromJson(response! as Map<String, dynamic>);
  }

  @override
  Future<List<FieldData>> getFields(String farmId) async {
    final response =
        await _request('GET', '/farms/$farmId/fields') as List<dynamic>;
    return response
        .map((item) => FieldData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FieldData> createField(String farmId, FieldData field) async {
    final response = await _request(
      'POST',
      '/farms/$farmId/fields',
      body: field.toJson(),
    );
    return FieldData.fromJson(response! as Map<String, dynamic>);
  }

  @override
  Future<List<CropData>> getCrops() async {
    final response = await _request('GET', '/crops') as List<dynamic>;
    return response
        .map((item) => CropData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CropData> createCrop(CropData crop) async {
    final response = await _request('POST', '/crops', body: crop.toJson());
    return CropData.fromJson(response! as Map<String, dynamic>);
  }

  @override
  Future<FieldCropData> associateCrop(String fieldId, String cropId) async {
    final response = await _request(
      'POST',
      '/fields/$fieldId/crop',
      body: {'crop_id': cropId, 'status': 'active'},
    );
    return FieldCropData.fromJson(response! as Map<String, dynamic>);
  }

  @override
  Future<FieldCropData?> getFieldCrop(String fieldId) async {
    final response = await _request(
      'GET',
      '/fields/$fieldId/crop',
      allowNotFound: true,
    );
    if (response == null) {
      return null;
    }
    return FieldCropData.fromJson(response as Map<String, dynamic>);
  }

  Future<Object?> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowNotFound = false,
  }) async {
    final client = _client ?? http.Client();
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}$path');
      late final http.Response response;
      if (method == 'POST') {
        response = await client
            .post(
              uri,
              headers: {'content-type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 8));
      } else {
        response = await client.get(uri).timeout(const Duration(seconds: 8));
      }
      if (allowNotFound && response.statusCode == 404) {
        return null;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AgricultureApiException(
          response.statusCode == 409
              ? 'Ces informations existent déjà.'
              : 'Le serveur ne peut pas traiter cette demande.',
          kind: AgricultureApiErrorKind.backend,
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(response.body);
    } on AgricultureApiException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const AgricultureApiException(
        'Impossible de contacter le serveur.',
        kind: AgricultureApiErrorKind.network,
      );
    } on http.ClientException catch (_) {
      throw const AgricultureApiException(
        'Impossible de contacter le serveur.',
        kind: AgricultureApiErrorKind.network,
      );
    } catch (_) {
      throw const AgricultureApiException(
        'Une erreur est survenue.',
        kind: AgricultureApiErrorKind.backend,
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

enum AgricultureApiErrorKind { network, backend }

class AgricultureApiException implements Exception {
  const AgricultureApiException(
    this.message, {
    required this.kind,
    this.statusCode,
  });

  final String message;
  final AgricultureApiErrorKind kind;
  final int? statusCode;
}
