import 'package:flutter/material.dart';
import 'package:homesikil/features/dashboard/models/impact_stats_model.dart';
import 'package:homesikil/features/dashboard/repository/dashboard_repository.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardStatus _status = DashboardStatus.initial;
  ImpactStatsModel _impactStats = ImpactStatsModel.empty();
  String? _errorMessage;
  String? _adminId;

  void updateAdminId(String? adminId) {
    if (_adminId != adminId) {
      _adminId = adminId;
      if (_adminId != null) {
        loadDashboard();
      }
    }
  }

  DashboardProvider(this._repository);

  DashboardStatus get status => _status;
  ImpactStatsModel get impactStats => _impactStats;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_adminId == null) {
        _impactStats = ImpactStatsModel.empty();
      } else {
        _impactStats = await _repository.getImpactStats(_adminId!);
      }
      _status = DashboardStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }
}
