class AchievementModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String? iconUrl;
  final String criteriaType;
  final int criteriaValue;
  final bool isUnlocked;
  final DateTime? achievedAt;

  const AchievementModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.criteriaType,
    required this.criteriaValue,
    this.isUnlocked = false,
    this.achievedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      criteriaType: json['criteria_type'] as String,
      criteriaValue: (json['criteria_value'] as num).toInt(),
    );
  }

  AchievementModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? iconUrl,
    String? criteriaType,
    int? criteriaValue,
    bool? isUnlocked,
    DateTime? achievedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      criteriaType: criteriaType ?? this.criteriaType,
      criteriaValue: criteriaValue ?? this.criteriaValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}
