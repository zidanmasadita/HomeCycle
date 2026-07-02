import 'package:flutter/material.dart';
import 'package:homesikil/core/utils/impact_calculator.dart';
import 'package:homesikil/core/utils/unit_converter.dart';
import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/category/models/category_model.dart';
import 'package:homesikil/features/consumption/models/consumption_log_model.dart';
import 'package:homesikil/features/consumption/repository/consumption_repository.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';

enum ConsumptionStatus { initial, loading, success, error }

class ConsumptionProvider extends ChangeNotifier {
  final ConsumptionRepository _repository;

  ConsumptionProvider(this._repository);

  ConsumptionStatus _status = ConsumptionStatus.initial;
  String? _errorMessage;

  ConsumptionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ConsumptionStatus.loading;

  Future<bool> recordConsumption({
    required FoodItemModel item,
    required CategoryModel category,
    required String action,
    String? reason,
  }) async {
    _status = ConsumptionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = SupabaseService.currentUserId;
      
      final quantityKg = UnitConverter.toKg(
        quantity: item.quantity,
        unit: item.unit,
        avgWeightPerUnitGram: category.avgWeightPerUnitGram,
      );

      double co2Saved = 0.0;
      double moneySaved = 0.0;

      if (action == 'consumed') {
        co2Saved = ImpactCalculator.calculateCo2Saved(
          quantityKg: quantityKg,
          co2FactorPerKg: category.co2FactorKg ?? 0.0,
        );
        moneySaved = ImpactCalculator.calculateMoneySaved(
          quantity: item.quantity,
          avgPricePerUnit: category.avgPricePerUnit ?? 0.0,
        );
      }

      final log = ConsumptionLogModel(
        id: '',
        userId: userId,
        foodItemId: item.id,
        categoryId: category.id,
        action: action,
        quantity: item.quantity,
        co2SavedKg: co2Saved,
        moneySaved: moneySaved,
        reason: reason,
        loggedAt: DateTime.now(),
      );

      await _repository.logConsumption(log);

      _status = ConsumptionStatus.success;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = ConsumptionStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ConsumptionStatus.error;
      notifyListeners();
      return false;
    }
  }
}
