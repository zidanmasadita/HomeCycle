import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/profile/models/user_preference_model.dart';

class ProfileRepository {
  final _client = SupabaseService.client;
  static const _table = 'user_preferences';

  Future<UserPreferenceModel> getPreferences() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .single();

      return UserPreferenceModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<UserPreferenceModel> updatePreferences(UserPreferenceModel prefs) async {
    try {
      final response = await _client
          .from(_table)
          .update(prefs.toJson())
          .eq('user_id', prefs.userId)
          .select()
          .single();
          
      return UserPreferenceModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
