class UserPreferenceModel {
  final String userId;
  final int notifyDaysBeforeExpiry;
  final int householdSize;
  final String preferredUnits;
  final String preferredLanguage;
  final DateTime updatedAt;

  const UserPreferenceModel({
    required this.userId,
    required this.notifyDaysBeforeExpiry,
    required this.householdSize,
    required this.preferredUnits,
    required this.preferredLanguage,
    required this.updatedAt,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      userId: json['user_id'] as String,
      notifyDaysBeforeExpiry: json['notify_days_before_expiry'] as int? ?? 3,
      householdSize: json['household_size'] as int? ?? 1,
      preferredUnits: json['preferred_units'] as String? ?? 'metric',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notify_days_before_expiry': notifyDaysBeforeExpiry,
      'household_size': householdSize,
      'preferred_units': preferredUnits,
      'preferred_language': preferredLanguage,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserPreferenceModel copyWith({
    String? userId,
    int? notifyDaysBeforeExpiry,
    int? householdSize,
    String? preferredUnits,
    String? preferredLanguage,
    DateTime? updatedAt,
  }) {
    return UserPreferenceModel(
      userId: userId ?? this.userId,
      notifyDaysBeforeExpiry: notifyDaysBeforeExpiry ?? this.notifyDaysBeforeExpiry,
      householdSize: householdSize ?? this.householdSize,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
