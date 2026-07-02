class ConsumptionLogModel {
  final String id;
  final String userId;
  final String foodItemId;
  final String categoryId;
  final String action;
  final double quantity;
  final double co2SavedKg;
  final double moneySaved;
  final String? reason;
  final DateTime loggedAt;

  const ConsumptionLogModel({
    required this.id,
    required this.userId,
    required this.foodItemId,
    required this.categoryId,
    required this.action,
    required this.quantity,
    required this.co2SavedKg,
    required this.moneySaved,
    this.reason,
    required this.loggedAt,
  });

  factory ConsumptionLogModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodItemId: json['food_item_id'] as String,
      categoryId: json['category_id'] as String,
      action: json['action'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      co2SavedKg: (json['co2_saved_kg'] as num).toDouble(),
      moneySaved: (json['money_saved'] as num).toDouble(),
      reason: json['reason'] as String?,
      loggedAt: DateTime.parse(json['logged_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'food_item_id': foodItemId,
      'category_id': categoryId,
      'action': action,
      'quantity': quantity,
      'co2_saved_kg': co2SavedKg,
      'money_saved': moneySaved,
      if (reason != null) 'reason': reason,
    };
  }
}
