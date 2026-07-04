class NotificationModel {
  final String id;
  final String userId;
  final String? foodItemId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.foodItemId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodItemId: json['food_item_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? foodItemId,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodItemId: foodItemId ?? this.foodItemId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
