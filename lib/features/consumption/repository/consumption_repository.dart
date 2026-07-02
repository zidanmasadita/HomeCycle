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
          .eq('user_id', userId)
          .order('logged_at', ascending: false);
      
      if (from != null) {
        query = query.gte('logged_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('logged_at', to.toIso8601String());
      }
      
      final response = await query;
      return (response as List<dynamic>)
          .map((json) => ConsumptionLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
