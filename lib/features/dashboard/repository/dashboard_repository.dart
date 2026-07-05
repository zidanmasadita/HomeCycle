import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/dashboard/models/impact_stats_model.dart';

class DashboardRepository {
  final _client = SupabaseService.client;
  Future<ImpactStatsModel> getImpactStats(String adminId) async {
    try {
      final response = await _client
          .from('consumption_log')
          .select()
          .eq('user_id', adminId);

      double totalMoneySaved = 0;
      double totalCo2Saved = 0;
      int itemsSaved = 0;
      int itemsWasted = 0;

      for (final row in response) {
        final action = row['action'] as String;
        final quantity = (row['quantity'] as num?)?.toDouble() ?? 1.0;
        final money = (row['money_saved'] as num?)?.toDouble() ?? 0.0;
        final co2 = (row['co2_saved_kg'] as num?)?.toDouble() ?? 0.0;

        if (action == 'consumed') {
          itemsSaved += quantity.toInt();
          totalMoneySaved += money;
          totalCo2Saved += co2;
        } else if (action == 'wasted') {
          itemsWasted += quantity.toInt();
        }
      }

      return ImpactStatsModel(
        totalMoneySaved: totalMoneySaved,
        totalCo2Saved: totalCo2Saved,
        itemsSaved: itemsSaved,
        itemsWasted: itemsWasted,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
