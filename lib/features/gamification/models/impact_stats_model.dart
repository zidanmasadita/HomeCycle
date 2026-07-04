class ImpactStatsModel {
  final String userId;
  final double totalMoneySaved;
  final double totalCo2Saved;
  final int itemsSaved;
  final int itemsWasted;

  const ImpactStatsModel({
    required this.userId,
    required this.totalMoneySaved,
    required this.totalCo2Saved,
    required this.itemsSaved,
    required this.itemsWasted,
  });

  factory ImpactStatsModel.fromJson(Map<String, dynamic> json) {
    return ImpactStatsModel(
      userId: json['user_id'] as String? ?? '',
      totalMoneySaved: (json['total_money_saved'] as num?)?.toDouble() ?? 0.0,
      totalCo2Saved: (json['total_co2_saved'] as num?)?.toDouble() ?? 0.0,
      itemsSaved: (json['items_saved'] as num?)?.toInt() ?? 0,
      itemsWasted: (json['items_wasted'] as num?)?.toInt() ?? 0,
    );
  }

  static const ImpactStatsModel empty = ImpactStatsModel(
    userId: '',
    totalMoneySaved: 0.0,
    totalCo2Saved: 0.0,
    itemsSaved: 0,
    itemsWasted: 0,
  );
}
