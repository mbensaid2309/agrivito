class FarmerProfileData {
  const FarmerProfileData({
    required this.displayName,
    required this.userType,
    required this.country,
    required this.region,
    required this.preferredLanguage,
  });

  final String displayName;
  final String userType;
  final String country;
  final String region;
  final String preferredLanguage;
}

class FarmData {
  const FarmData({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.locality,
    required this.totalArea,
  });

  final String id;
  final String name;
  final String country;
  final String region;
  final String locality;
  final double? totalArea;
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
  });

  final String id;
  final String farmId;
  final String name;
  final double area;
  final String soilType;
  final String waterAccess;
  final String irrigationType;
}

class CropData {
  const CropData({
    required this.id,
    required this.name,
    required this.category,
    required this.variety,
    required this.growthStage,
  });

  final String id;
  final String name;
  final String category;
  final String variety;
  final String growthStage;
}

class AgricultureStore {
  AgricultureStore._();

  static final AgricultureStore instance = AgricultureStore._();

  FarmerProfileData? profile;
  final List<FarmData> farms = [];
  final List<FieldData> fields = [];
  final List<CropData> crops = [];
  final Map<String, String> cropByField = {};
  int _nextId = 1;

  String nextId() => (_nextId++).toString();

  List<FieldData> fieldsForFarm(String farmId) =>
      fields.where((field) => field.farmId == farmId).toList();

  CropData? cropForField(String fieldId) {
    final cropId = cropByField[fieldId];
    for (final crop in crops) {
      if (crop.id == cropId) {
        return crop;
      }
    }
    return null;
  }
}
