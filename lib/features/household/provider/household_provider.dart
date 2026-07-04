import 'package:flutter/material.dart';
import 'package:homesikil/features/household/models/household_member_model.dart';
import 'package:homesikil/features/household/models/household_invitation_model.dart';
import 'package:homesikil/features/household/repository/household_repository.dart';

enum HouseholdStatus { initial, loading, success, error }

class HouseholdProvider extends ChangeNotifier {
  final HouseholdRepository _repository;

  HouseholdStatus _status = HouseholdStatus.initial;
  List<HouseholdMemberModel> _members = [];
  List<HouseholdInvitationModel> _pendingInvitations = [];
  String? _errorMessage;
  String _adminName = 'Household Admin';
  String? _adminId;

  HouseholdProvider(this._repository);

  HouseholdStatus get status => _status;
  List<HouseholdMemberModel> get members => _members;
  List<HouseholdInvitationModel> get pendingInvitations => _pendingInvitations;
  String? get errorMessage => _errorMessage;
  String get adminName => _adminName;
  String? get adminId => _adminId;
  bool get isLoading => _status == HouseholdStatus.loading;

  Future<void> loadMembers() async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getHouseholdMembers(),
        _repository.getPendingInvitations(),
      ]);

      final householdData = results[0] as Map<String, dynamic>;
      _members = householdData['members'] as List<HouseholdMemberModel>;
      _adminName = householdData['adminName'] as String;
      _adminId = householdData['adminId'] as String;

      _pendingInvitations = results[1] as List<HouseholdInvitationModel>;
      _status = HouseholdStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
    }
    notifyListeners();
  }

  Future<bool> inviteMember(String username) async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.inviteMember(username);
      _status = HouseholdStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptInvite(String inviteId) async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.acceptInvite(inviteId);
      await loadMembers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineInvite(String inviteId) async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.declineInvite(inviteId);
      _pendingInvitations = _pendingInvitations
          .where((i) => i.id != inviteId)
          .toList();
      _status = HouseholdStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMember(String id) async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.removeMember(id);
      _members = _members.where((m) => m.id != id).toList();
      _status = HouseholdStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveHousehold() async {
    _status = HouseholdStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.leaveHousehold();
      _members = [];
      _adminName = 'Household Admin';
      _adminId = null;
      _status = HouseholdStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HouseholdStatus.error;
      notifyListeners();
      return false;
    }
  }
}
