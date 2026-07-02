class FoodItemModel {
  final String id;
  final String userId;
  final String categoryId;
  final String? customName;
  final String? condition; // fresh | ripe | overripe | rotten
  final double? confidenceScore;
  final double quantity;
  final String unit; // pcs | kg | gram | ikat
  final String? storageLocation; // fridge | room_temp | freezer
  final DateTime scannedAt;
  final DateTime estimatedExpiredDate;
  final String actualStatus; // active | consumed | wasted | expired
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodItemModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.customName,
    this.condition,
    this.confidenceScore,
    required this.quantity,
    required this.unit,
    this.storageLocation,
    required this.scannedAt,
    required this.estimatedExpiredDate,
    required this.actualStatus,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      customName: json['custom_name'] as String?,
      condition: json['condition'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      storageLocation: json['storage_location'] as String?,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      estimatedExpiredDate: DateTime.parse(
        json['estimated_expired_date'] as String,
      ),
      actualStatus: json['actual_status'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'custom_name': customName,
      'condition': condition,
      'confidence_score': confidenceScore,
      'quantity': quantity,
      'unit': unit,
      'storage_location': storageLocation,
      'estimated_expired_date': estimatedExpiredDate
          .toIso8601String()
          .split('T')
          .first,
      'actual_status': actualStatus,
      'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'custom_name': customName,
      'quantity': quantity,
      'unit': unit,
      'storage_location': storageLocation,
      'estimated_expired_date': estimatedExpiredDate
          .toIso8601String()
          .split('T')
          .first,
      'actual_status': actualStatus,
    };
  }

  FoodItemModel copyWith({
    String? customName,
    String? condition,
    double? quantity,
    String? unit,
    String? storageLocation,
    DateTime? estimatedExpiredDate,
    String? actualStatus,
    String? imageUrl,
  }) {
    return FoodItemModel(
      id: id,
      userId: userId,
      categoryId: categoryId,
      customName: customName ?? this.customName,
      condition: condition ?? this.condition,
      confidenceScore: confidenceScore,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storageLocation: storageLocation ?? this.storageLocation,
      scannedAt: scannedAt,
      estimatedExpiredDate: estimatedExpiredDate ?? this.estimatedExpiredDate,
      actualStatus: actualStatus ?? this.actualStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  int get daysUntilExpiration =>
      estimatedExpiredDate.difference(DateTime.now()).inDays;

  bool get isExpiringSoon =>
      daysUntilExpiration <= 2 && daysUntilExpiration >= 0;
  bool get isExpired => daysUntilExpiration < 0;
  bool get isActive => actualStatus == 'active';
}
