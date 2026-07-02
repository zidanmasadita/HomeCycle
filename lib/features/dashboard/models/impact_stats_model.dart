class ImpactStatsModel {
  final double totalMoneySaved;
  final double totalCo2Saved;
  final int itemsSaved;
  final int itemsWasted;

  const ImpactStatsModel({
    required this.totalMoneySaved,
    required this.totalCo2Saved,
    required this.itemsSaved,
    required this.itemsWasted,
  });

  factory ImpactStatsModel.fromJson(Map<String, dynamic> json) {
    return ImpactStatsModel(
      totalMoneySaved: (json['total_money_saved'] as num?)?.toDouble() ?? 0.0,
      totalCo2Saved: (json['total_co2_saved'] as num?)?.toDouble() ?? 0.0,
      itemsSaved: (json['items_saved'] as num?)?.toInt() ?? 0,
      itemsWasted: (json['items_wasted'] as num?)?.toInt() ?? 0,
    );
  }

  factory ImpactStatsModel.empty() {
    return const ImpactStatsModel(
      totalMoneySaved: 0.0,
      totalCo2Saved: 0.0,
      itemsSaved: 0,
      itemsWasted: 0,
    );
  }
}
