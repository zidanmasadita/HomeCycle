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
    required String adminId,
  }) async {
    try {
      var query = _client.from(_table).select().eq('user_id', adminId);

      if (from != null) {
        query = query.gte('logged_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('logged_at', to.toIso8601String());
      }

      final response = await query.order('logged_at', ascending: false);
      return (response as List<dynamic>)
          .map(
            (json) =>
                ConsumptionLogModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<int> getCurrentStreakWeeks(String adminId) async {
    try {
      final logs = await getLogsByUser(adminId: adminId);
      if (logs.isEmpty) return 0;

      int streak = 0;
      DateTime now = DateTime.now();
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      currentWeekStart = DateTime(
        currentWeekStart.year,
        currentWeekStart.month,
        currentWeekStart.day,
      );

      Map<int, bool> weekHasWaste = {};
      int maxWeekIndex = 0;

      for (var log in logs) {
        final logDate = log.loggedAt;
        final difference = currentWeekStart
            .difference(DateTime(logDate.year, logDate.month, logDate.day))
            .inDays;

        int weekIndex = difference <= 0 ? 0 : (difference / 7).ceil();
        if (weekIndex > maxWeekIndex) maxWeekIndex = weekIndex;

        if (log.action == 'wasted') {
          weekHasWaste[weekIndex] = true;
        } else {
          weekHasWaste.putIfAbsent(weekIndex, () => false);
        }
      }

      for (int i = 0; i <= maxWeekIndex; i++) {
        if (weekHasWaste[i] == true) {
          break;
        } else if (weekHasWaste[i] == false) {
          streak++;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getFilledDaysThisWeek(String adminId) async {
    try {
      DateTime now = DateTime.now();
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      currentWeekStart = DateTime(
        currentWeekStart.year,
        currentWeekStart.month,
        currentWeekStart.day,
      );

      final logs = await getLogsByUser(
        from: currentWeekStart,
        adminId: adminId,
      );
      if (logs.isEmpty) return 0;

      Map<int, bool> dayHasWaste = {};
      Map<int, bool> dayHasConsumption = {};

      for (var log in logs) {
        final logDate = log.loggedAt;
        final logDay = DateTime(logDate.year, logDate.month, logDate.day);

        int dayIndex = logDay.weekday;

        if (log.action == 'wasted') {
          dayHasWaste[dayIndex] = true;
        } else if (log.action == 'consumed') {
          dayHasConsumption[dayIndex] = true;
        }
      }

      int filledDays = 0;
      for (int i = 1; i <= 7; i++) {
        if (dayHasConsumption[i] == true && dayHasWaste[i] != true) {
          filledDays++;
        }
      }

      return filledDays;
    } catch (e) {
      return 0;
    }
  }
}
