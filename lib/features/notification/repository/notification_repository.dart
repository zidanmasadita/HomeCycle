import 'package:homecycle/data/remote/supabase_service.dart';
import 'package:homecycle/errors/failure.dart';
import 'package:homecycle/features/notification/models/notification_model.dart';

class NotificationRepository {
  final _client = SupabaseService.client;
  static const _table = 'notifications';

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
