class CategoryModel {
  final String id;
  final String name;
  final String type;
  final int defaultShelfLifeDays;
  final int? fridgeShelfLifeDays;
  final String? storageTip;
  final String? iconUrl;
  final double? co2FactorKg;
  final double? avgPricePerUnit;
  final double? avgWeightPerUnitGram;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.defaultShelfLifeDays,
    this.fridgeShelfLifeDays,
    this.storageTip,
    this.iconUrl,
    this.co2FactorKg,
    this.avgPricePerUnit,
    this.avgWeightPerUnitGram,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      defaultShelfLifeDays: json['default_shelf_life_days'] as int,
      fridgeShelfLifeDays: json['fridge_shelf_life_days'] as int?,
      storageTip: json['storage_tip'] as String?,
      iconUrl: json['icon_url'] as String?,
      co2FactorKg: (json['co2_factor_kg'] as num?)?.toDouble(),
      avgPricePerUnit: (json['avg_price_per_unit'] as num?)?.toDouble(),
      avgWeightPerUnitGram: (json['avg_weight_per_unit_gram'] as num?)
          ?.toDouble(),
    );
  }

  bool get isFruit => type == 'fruit';
  bool get isVegetable => type == 'vegetable';
}
