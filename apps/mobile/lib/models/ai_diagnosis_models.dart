class AIDiagnosisContext {
  const AIDiagnosisContext({this.farmId, this.fieldId, this.cropId});

  final String? farmId;
  final String? fieldId;
  final String? cropId;

  Map<String, dynamic> toJson() => {
    if (farmId != null) 'farm_id': farmId,
    if (fieldId != null) 'field_id': fieldId,
    if (cropId != null) 'crop_id': cropId,
  };
}

class AIDiagnosisResponseData {
  const AIDiagnosisResponseData({
    required this.diagnosis,
    required this.contextUsed,
    required this.usage,
  });

  factory AIDiagnosisResponseData.fromJson(Map<String, dynamic> json) {
    return AIDiagnosisResponseData(
      diagnosis: DiagnosisData.fromJson(
        json['diagnosis'] as Map<String, dynamic>,
      ),
      contextUsed: DiagnosisContextUsedData.fromJson(
        json['context_used'] as Map<String, dynamic>,
      ),
      usage: DiagnosisUsageData.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  final DiagnosisData diagnosis;
  final DiagnosisContextUsedData contextUsed;
  final DiagnosisUsageData usage;
}

class DiagnosisData {
  const DiagnosisData({
    required this.summary,
    required this.observations,
    required this.hypotheses,
    required this.recommendations,
    required this.followUpQuestions,
    required this.precautions,
    required this.trustScore,
    required this.responseMode,
    required this.language,
  });

  factory DiagnosisData.fromJson(Map<String, dynamic> json) {
    return DiagnosisData(
      summary: json['summary'] as String,
      observations: _stringList(json['observations']),
      hypotheses: (json['hypotheses'] as List<dynamic>)
          .map(
            (item) =>
                DiagnosisHypothesisData.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      recommendations: _stringList(json['recommendations']),
      followUpQuestions: _stringList(json['follow_up_questions']),
      precautions: _stringList(json['precautions']),
      trustScore: DiagnosisTrustScoreData.fromJson(
        json['trust_score'] as Map<String, dynamic>,
      ),
      responseMode: json['response_mode'] as String,
      language: json['language'] as String,
    );
  }

  final String summary;
  final List<String> observations;
  final List<DiagnosisHypothesisData> hypotheses;
  final List<String> recommendations;
  final List<String> followUpQuestions;
  final List<String> precautions;
  final DiagnosisTrustScoreData trustScore;
  final String responseMode;
  final String language;
}

class DiagnosisHypothesisData {
  const DiagnosisHypothesisData({
    required this.label,
    required this.explanation,
  });

  factory DiagnosisHypothesisData.fromJson(Map<String, dynamic> json) {
    return DiagnosisHypothesisData(
      label: json['label'] as String,
      explanation: json['explanation'] as String,
    );
  }

  final String label;
  final String explanation;
}

class DiagnosisTrustScoreData {
  const DiagnosisTrustScoreData({
    required this.score,
    required this.level,
    required this.explanation,
  });

  factory DiagnosisTrustScoreData.fromJson(Map<String, dynamic> json) {
    return DiagnosisTrustScoreData(
      score: json['score'] as int,
      level: json['level'] as String,
      explanation: json['explanation'] as String,
    );
  }

  final int score;
  final String level;
  final String explanation;
}

class DiagnosisContextUsedData {
  const DiagnosisContextUsedData({
    required this.farmerProfile,
    required this.farm,
    required this.field,
    required this.crop,
  });

  factory DiagnosisContextUsedData.fromJson(Map<String, dynamic> json) {
    return DiagnosisContextUsedData(
      farmerProfile: json['farmer_profile'] as bool,
      farm: json['farm'] as bool,
      field: json['field'] as bool,
      crop: json['crop'] as bool,
    );
  }

  final bool farmerProfile;
  final bool farm;
  final bool field;
  final bool crop;
}

class DiagnosisUsageData {
  const DiagnosisUsageData({
    required this.mode,
    this.questionsUsed,
    this.questionsLimit,
    this.remaining,
  });

  factory DiagnosisUsageData.fromJson(Map<String, dynamic> json) {
    return DiagnosisUsageData(
      mode: json['mode'] as String,
      questionsUsed: json['questions_used'] as int?,
      questionsLimit: json['questions_limit'] as int?,
      remaining: json['remaining'] as int?,
    );
  }

  final String mode;
  final int? questionsUsed;
  final int? questionsLimit;
  final int? remaining;
}

List<String> _stringList(Object? value) {
  return (value as List<dynamic>).cast<String>();
}
