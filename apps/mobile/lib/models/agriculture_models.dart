class FarmerProfileData {
  const FarmerProfileData({
    required this.userId,
    required this.displayName,
    required this.userType,
    required this.country,
    required this.region,
    required this.preferredLanguage,
    this.isDiscoveryMode = false,
  });

  factory FarmerProfileData.fromJson(Map<String, dynamic> json) =>
      FarmerProfileData(
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String,
        userType: json['user_type'] as String,
        country: json['country'] as String,
        region: json['region'] as String,
        preferredLanguage: json['preferred_language'] as String,
        isDiscoveryMode: json['is_discovery_mode'] as bool? ?? false,
      );

  final String userId;
  final String displayName;
  final String userType;
  final String country;
  final String region;
  final String preferredLanguage;
  final bool isDiscoveryMode;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'display_name': displayName,
        'user_type': userType,
        'country': country,
        'region': region,
        'preferred_language': preferredLanguage,
        'is_discovery_mode': isDiscoveryMode,
      };
}

class FarmData {
  const FarmData({
    required this.id,
    required this.userId,
    required this.name,
    required this.country,
    required this.region,
    required this.locality,
    required this.totalArea,
    this.areaUnit = 'hectare',
  });

  factory FarmData.fromJson(Map<String, dynamic> json) => FarmData(
        id: json['farm_id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        country: json['country'] as String,
        region: json['region'] as String,
        locality: json['locality'] as String,
        totalArea: (json['total_area'] as num?)?.toDouble(),
        areaUnit: json['area_unit'] as String? ?? 'unknown',
      );

  final String id;
  final String userId;
  final String name;
  final String country;
  final String region;
  final String locality;
  final double? totalArea;
  final String areaUnit;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'country': country,
        'region': region,
        'locality': locality,
        'total_area': totalArea,
        'area_unit': areaUnit,
      };
}

class FieldData {
  const FieldData({
    required this.id,
    required this.farmId,
    required this.name,
    required this.area,
    required this.soilType,
    required this.waterAccess,
    required this.irrigationType,
    this.areaUnit = 'hectare',
    this.notes = '',
  });

  factory FieldData.fromJson(Map<String, dynamic> json) => FieldData(
        id: json['field_id'] as String,
        farmId: json['farm_id'] as String,
        name: json['name'] as String,
        area: (json['area'] as num).toDouble(),
        areaUnit: json['area_unit'] as String? ?? 'unknown',
        soilType: json['soil_type'] as String? ?? '',
        waterAccess: json['water_access'] as String? ?? 'unknown',
        irrigationType: json['irrigation_type'] as String? ?? 'unknown',
        notes: json['notes'] as String? ?? '',
      );

  final String id;
  final String farmId;
  final String name;
  final double area;
  final String areaUnit;
  final String soilType;
  final String waterAccess;
  final String irrigationType;
  final String notes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'area': area,
        'area_unit': areaUnit,
        'soil_type': soilType.isEmpty ? null : soilType,
        'water_access': waterAccess,
        'irrigation_type': irrigationType,
        'notes': notes.isEmpty ? null : notes,
      };
}

class CropData {
  const CropData({
    required this.id,
    required this.name,
    required this.category,
    required this.variety,
    required this.growthStage,
    this.season = '',
    this.notes = '',
  });

  factory CropData.fromJson(Map<String, dynamic> json) => CropData(
        id: json['crop_id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        variety: json['variety'] as String? ?? '',
        growthStage: json['growth_stage'] as String? ?? 'unknown',
        season: json['season'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );

  final String id;
  final String name;
  final String category;
  final String variety;
  final String growthStage;
  final String season;
  final String notes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'variety': variety.isEmpty ? null : variety,
        'season': season.isEmpty ? null : season,
        'growth_stage': growthStage,
        'notes': notes.isEmpty ? null : notes,
      };
}

class FieldCropData {
  const FieldCropData({
    required this.id,
    required this.fieldId,
    required this.cropId,
    required this.status,
  });

  factory FieldCropData.fromJson(Map<String, dynamic> json) => FieldCropData(
        id: json['field_crop_id'] as String,
        fieldId: json['field_id'] as String,
        cropId: json['crop_id'] as String,
        status: json['status'] as String,
      );

  final String id;
  final String fieldId;
  final String cropId;
  final String status;
}
