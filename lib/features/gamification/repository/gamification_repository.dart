import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/gamification/models/achievement_model.dart';
import 'package:homesikil/features/gamification/models/impact_stats_model.dart';

class GamificationRepository {
  final _client = SupabaseService.client;
  
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final response = await _client.from('achievements').select().order('criteria_value', ascending: true);
      return (response as List<dynamic>)
          .map((json) => AchievementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<String>> getUnlockedAchievementIds() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);
          
      return (response as List<dynamic>)
          .map((json) => json['achievement_id'] as String)
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      final userId = SupabaseService.currentUserId;

      await _client.from('user_achievements').upsert({
        'user_id': userId,
        'achievement_id': achievementId,
        'achieved_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<ImpactStatsModel> getImpactStats() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from('user_impact_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        return ImpactStatsModel.empty;
      }
      return ImpactStatsModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
