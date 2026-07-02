import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/dashboard/models/impact_stats_model.dart';

class DashboardRepository {
  final _client = SupabaseService.client;
  static const _view = 'user_impact_stats';

  Future<ImpactStatsModel> getImpactStats() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from(_view)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return ImpactStatsModel.empty();
      }

      return ImpactStatsModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
