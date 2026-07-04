import 'package:flutter/material.dart';
import 'package:homesikil/features/gamification/models/achievement_model.dart';
import 'package:homesikil/features/gamification/models/impact_stats_model.dart';
import 'package:homesikil/features/gamification/repository/gamification_repository.dart';
import 'package:homesikil/features/consumption/repository/consumption_repository.dart';

enum GamificationStatus { initial, loading, success, error }

class GamificationProvider extends ChangeNotifier {
  final GamificationRepository _repository;

  GamificationStatus _status = GamificationStatus.initial;
  List<AchievementModel> _achievements = [];
  final List<AchievementModel> _newlyUnlocked = [];
  ImpactStatsModel _impactStats = ImpactStatsModel.empty;
  String? _errorMessage;
  int _currentStreakWeeks = 0;
  int _filledDaysThisWeek = 0;

  GamificationProvider(this._repository);

  GamificationStatus get status => _status;
  List<AchievementModel> get achievements => _achievements;
  List<AchievementModel> get newlyUnlocked => _newlyUnlocked;
  ImpactStatsModel get impactStats => _impactStats;
  String? get errorMessage => _errorMessage;
  int get currentStreakWeeks => _currentStreakWeeks;
  int get filledDaysThisWeek => _filledDaysThisWeek;

  Future<void> loadAchievements() async {
    _status = GamificationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final allAchievements = await _repository.getAllAchievements();
      final unlockedIds = await _repository.getUnlockedAchievementIds();

      _achievements = allAchievements.map((a) {
        return a.copyWith(isUnlocked: unlockedIds.contains(a.id));
      }).toList();

      _status = GamificationStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GamificationStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadImpactStats() async {
    try {
      _impactStats = await _repository.getImpactStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStreakData() async {
    try {
      final consumptionRepo = ConsumptionRepository();
      _currentStreakWeeks = await consumptionRepo.getCurrentStreakWeeks();
      _filledDaysThisWeek = await consumptionRepo.getFilledDaysThisWeek();
      notifyListeners();
    } catch (e) {
      _currentStreakWeeks = 0;
      _filledDaysThisWeek = 0;
      notifyListeners();
    }
  }

  Future<void> checkAndUnlockAchievements({
    required int itemsSavedCount,
    required int currentStreakWeeks,
    double totalCo2Saved = 0.0,
    double totalMoneySaved = 0.0,
  }) async {
    bool hasNewUnlocks = false;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      bool meetsCriteria = false;

      if (achievement.criteriaType == 'items_count' &&
          itemsSavedCount >= achievement.criteriaValue) {
        meetsCriteria = true;
      } else if (achievement.criteriaType == 'streak_weeks' &&
          currentStreakWeeks >= achievement.criteriaValue) {
        meetsCriteria = true;
      } else if (achievement.criteriaType == 'co2_threshold' &&
          totalCo2Saved >= achievement.criteriaValue) {
        meetsCriteria = true;
      } else if (achievement.criteriaType == 'money_threshold' &&
          totalMoneySaved >= achievement.criteriaValue) {
        meetsCriteria = true;
      }

      if (meetsCriteria) {
        try {
          await _repository.unlockAchievement(achievement.id);
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            achievedAt: DateTime.now(),
          );
          _newlyUnlocked.add(_achievements[i]);
          hasNewUnlocks = true;
        } catch (_) {}
      }
    }

    if (hasNewUnlocks) {
      notifyListeners();
    }
  }

  void clearNewlyUnlocked() {
    if (_newlyUnlocked.isNotEmpty) {
      _newlyUnlocked.clear();
      notifyListeners();
    }
  }
}
