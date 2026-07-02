import 'package:flutter/material.dart';
import 'package:homesikil/features/profile/models/user_preference_model.dart';
import 'package:homesikil/features/profile/repository/profile_repository.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileStatus _status = ProfileStatus.initial;
  UserPreferenceModel? _preferences;
  String? _errorMessage;

  ProfileProvider(this._repository);

  ProfileStatus get status => _status;
  UserPreferenceModel? get preferences => _preferences;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProfileStatus.loading;

  Future<void> loadPreferences() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await _repository.getPreferences();
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  Future<bool> updateLanguage(String languageCode) async {
    return _updateField((prefs) => prefs.copyWith(
      preferredLanguage: languageCode,
      updatedAt: DateTime.now(),
    ));
  }

  Future<bool> updateNotifyDaysBeforeExpiry(int days) async {
    return _updateField((prefs) => prefs.copyWith(
      notifyDaysBeforeExpiry: days,
      updatedAt: DateTime.now(),
    ));
  }

  Future<bool> updateHouseholdSize(int size) async {
    return _updateField((prefs) => prefs.copyWith(
      householdSize: size,
      updatedAt: DateTime.now(),
    ));
  }
  
  Future<bool> updatePreferredUnits(String units) async {
    return _updateField((prefs) => prefs.copyWith(
      preferredUnits: units,
      updatedAt: DateTime.now(),
    ));
  }

  Future<bool> _updateField(UserPreferenceModel Function(UserPreferenceModel) updater) async {
    if (_preferences == null) return false;

    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPrefs = updater(_preferences!);
      _preferences = await _repository.updatePreferences(updatedPrefs);
      _status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }
}
