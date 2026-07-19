import 'ai_diagnosis_models.dart';

enum PhotoDiagnosisState {
  idle,
  loading,
  success,
  poorPhoto,
  retakeRequired,
  insufficientInformation,
  networkError,
  providerError,
  mediaNotFound,
  discoveryLimitReached,
}

class PhotoDiagnosisContext {
  const PhotoDiagnosisContext({
    this.userId,
    this.farmId,
    this.fieldId,
    this.cropId,
  });

  final String? userId;
  final String? farmId;
  final String? fieldId;
  final String? cropId;

  Map<String, dynamic> toJson() => {
        if (_present(userId)) 'user_id': userId!.trim(),
        if (_present(farmId)) 'farm_id': farmId!.trim(),
        if (_present(fieldId)) 'field_id': fieldId!.trim(),
        if (_present(cropId)) 'crop_id': cropId!.trim(),
      };

  static bool _present(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class PhotoDiagnosisResponseData {
  const PhotoDiagnosisResponseData({
    required this.diagnosis,
    required this.contextUsed,
    required this.usage,
  });

  factory PhotoDiagnosisResponseData.fromJson(Map<String, dynamic> json) =>
      PhotoDiagnosisResponseData(
        diagnosis: PhotoDiagnosisData.fromJson(
          json['diagnosis'] as Map<String, dynamic>,
        ),
        contextUsed: DiagnosisContextUsedData.fromJson(
          json['context_used'] as Map<String, dynamic>,
        ),
        usage: PhotoDiagnosisUsageData.fromJson(
          json['usage'] as Map<String, dynamic>,
        ),
      );

  final PhotoDiagnosisData diagnosis;
  final DiagnosisContextUsedData contextUsed;
  final PhotoDiagnosisUsageData usage;
}

class PhotoDiagnosisData {
  const PhotoDiagnosisData({
    required this.id,
    required this.mediaId,
    required this.summary,
    required this.photoQuality,
    required this.observations,
    required this.hypotheses,
    required this.recommendations,
    required this.followUpQuestions,
    required this.precautions,
    required this.trustScore,
    required this.responseMode,
    required this.language,
    required this.status,
  });

  factory PhotoDiagnosisData.fromJson(Map<String, dynamic> json) =>
      PhotoDiagnosisData(
        id: json['id'] as String,
        mediaId: json['media_id'] as String,
        summary: json['summary'] as String,
        photoQuality: PhotoQualityData.fromJson(
          json['photo_quality'] as Map<String, dynamic>,
        ),
        observations: _strings(json['observations']),
        hypotheses: (json['hypotheses'] as List<dynamic>)
            .map(
              (item) => DiagnosisHypothesisData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
        recommendations: _strings(json['recommendations']),
        followUpQuestions: _strings(json['follow_up_questions']),
        precautions: _strings(json['precautions']),
        trustScore: DiagnosisTrustScoreData.fromJson(
          json['trust_score'] as Map<String, dynamic>,
        ),
        responseMode: json['response_mode'] as String,
        language: json['language'] as String,
        status: json['status'] as String,
      );

  final String id;
  final String mediaId;
  final String summary;
  final PhotoQualityData photoQuality;
  final List<String> observations;
  final List<DiagnosisHypothesisData> hypotheses;
  final List<String> recommendations;
  final List<String> followUpQuestions;
  final List<String> precautions;
  final DiagnosisTrustScoreData trustScore;
  final String responseMode;
  final String language;
  final String status;
}

class PhotoQualityData {
  const PhotoQualityData({
    required this.score,
    required this.level,
    required this.issues,
    required this.retakeRequired,
    required this.retakeInstructions,
  });

  factory PhotoQualityData.fromJson(Map<String, dynamic> json) =>
      PhotoQualityData(
        score: json['score'] as int,
        level: json['level'] as String,
        issues: _strings(json['issues']),
        retakeRequired: json['retake_required'] as bool,
        retakeInstructions: _strings(json['retake_instructions']),
      );

  final int score;
  final String level;
  final List<String> issues;
  final bool retakeRequired;
  final List<String> retakeInstructions;
}

class PhotoDiagnosisUsageData {
  const PhotoDiagnosisUsageData({
    required this.mode,
    this.diagnosesUsed,
    this.diagnosesLimit,
    this.remaining,
  });

  factory PhotoDiagnosisUsageData.fromJson(Map<String, dynamic> json) =>
      PhotoDiagnosisUsageData(
        mode: json['mode'] as String,
        diagnosesUsed: json['diagnoses_used'] as int?,
        diagnosesLimit: json['diagnoses_limit'] as int?,
        remaining: json['remaining'] as int?,
      );

  final String mode;
  final int? diagnosesUsed;
  final int? diagnosesLimit;
  final int? remaining;
}

List<String> _strings(Object? value) => (value as List<dynamic>).cast<String>();
