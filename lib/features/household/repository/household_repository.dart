import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/household/models/household_member_model.dart';
import 'package:homesikil/features/household/models/household_invitation_model.dart';

class HouseholdRepository {
  final _client = SupabaseService.client;
  static const _membersTable = 'household_members';
  static const _invitesTable = 'household_invitations';

  Future<Map<String, dynamic>> getHouseholdMembers() async {
    try {
      final userId = SupabaseService.currentUserId;
      final myMembership = await _client
          .from(_membersTable)
          .select('admin_id')
          .eq('member_id', userId)
          .maybeSingle();

      final adminId = myMembership != null
          ? myMembership['admin_id'] as String
          : userId;

      final adminNameResponse = await _client.rpc(
        'get_user_name',
        params: {'p_user_id': adminId},
      );
      final adminName = (adminNameResponse as String?) ?? 'Household Admin';

      final response = await _client
          .from(_membersTable)
          .select()
          .eq('admin_id', adminId)
          .order('created_at', ascending: true);

      return {
        'members': (response as List)
            .map((json) => HouseholdMemberModel.fromJson(json))
            .toList(),
        'adminName': adminName,
        'adminId': adminId,
      };
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<HouseholdInvitationModel>> getPendingInvitations() async {
    try {
      final userId = SupabaseService.currentUserId;
      final response = await _client
          .from(_invitesTable)
          .select()
          .eq('invitee_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HouseholdInvitationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> inviteMember(String username) async {
    try {
      final response = await _client.rpc(
        'invite_household_member',
        params: {'p_username': username},
      );

      if (response != null && response['success'] == false) {
        throw Failure(response['error'] ?? 'Failed to invite user');
      }
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> acceptInvite(String inviteId) async {
    try {
      final response = await _client.rpc(
        'accept_household_invite',
        params: {'p_invite_id': inviteId},
      );

      if (response != null && response['success'] == false) {
        throw Failure(response['error'] ?? 'Failed to accept invite');
      }
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> declineInvite(String inviteId) async {
    try {
      final response = await _client.rpc(
        'decline_household_invite',
        params: {'p_invite_id': inviteId},
      );

      if (response != null && response['success'] == false) {
        throw Failure(response['error'] ?? 'Failed to decline invite');
      }
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> removeMember(String id) async {
    try {
      await _client.from(_membersTable).delete().eq('id', id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> leaveHousehold() async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client.from(_membersTable).delete().eq('member_id', userId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
