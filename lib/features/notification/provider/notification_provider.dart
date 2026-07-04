import 'package:flutter/material.dart';
import 'package:homesikil/features/notification/models/notification_model.dart';
import 'package:homesikil/features/notification/repository/notification_repository.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationStatus _status = NotificationStatus.initial;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;

  NotificationProvider(this._repository);

  NotificationStatus get status => _status;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      return n.createdAt.year == now.year &&
             n.createdAt.month == now.month &&
             n.createdAt.day == now.day;
    }).toList();
  }

  List<NotificationModel> get earlierNotifications {
    final now = DateTime.now();
    return _notifications.where((n) {
      return n.createdAt.year != now.year ||
             n.createdAt.month != now.month ||
             n.createdAt.day != now.day;
    }).toList();
  }

  Future<void> loadNotifications() async {
    _status = NotificationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _status = NotificationStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = NotificationStatus.error;
    }
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
