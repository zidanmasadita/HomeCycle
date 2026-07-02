import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/consumption/models/consumption_log_model.dart';

class ConsumptionRepository {
  final _client = SupabaseService.client;
  static const _table = 'consumption_log';

  Future<void> logConsumption(ConsumptionLogModel log) async {
    try {
      await _client.from(_table).insert(log.toInsertJson());
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<ConsumptionLogModel>> getLogsByUser({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      var query = _client
          .from(_table)
          .select()
          .eq('user_id', userId);
      
      if (from != null) {
        query = query.gte('logged_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('logged_at', to.toIso8601String());
      }
      
      final response = await query.order('logged_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => ConsumptionLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<int> getCurrentStreakWeeks() async {
    try {
      final logs = await getLogsByUser();
      if (logs.isEmpty) return 0;
      
      int streak = 0;
      DateTime now = DateTime.now();
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      currentWeekStart = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);

      Map<int, bool> weekHasWaste = {};
      
      for (var log in logs) {
        final logDate = log.loggedAt;
        final difference = currentWeekStart.difference(DateTime(logDate.year, logDate.month, logDate.day)).inDays;
        
        int weekIndex = difference <= 0 ? 0 : (difference / 7).ceil();
        
        if (log.action == 'wasted') {
          weekHasWaste[weekIndex] = true;
        } else {
          weekHasWaste.putIfAbsent(weekIndex, () => false);
        }
      }

      for (int i = 0; i < 520; i++) {
        if (weekHasWaste.containsKey(i)) {
          if (weekHasWaste[i] == true) {
            break;
          } else {
            streak++;
          }
        } else {
          if (i == 0) continue;
          break;
        }
      }
      return streak;
    } catch (e) {
      return 0;
    }
  }
}
