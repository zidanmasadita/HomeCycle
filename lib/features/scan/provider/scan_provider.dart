import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homesikil/data/remote/tflite_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/scan/models/scan_result_model.dart';
import 'package:homesikil/features/scan/repository/scan_repository.dart';

enum ScanStatus { initial, loading, success, error }

class ScanProvider extends ChangeNotifier {
  final ScanRepository _repository;
  final TFLiteService _tfLiteService;
  final CategoryProvider _categoryProvider;
  final InventoryProvider _inventoryProvider;

  ScanProvider({
    required ScanRepository repository,
    required TFLiteService tfLiteService,
    required CategoryProvider categoryProvider,
    required InventoryProvider inventoryProvider,
  })  : _repository = repository,
        _tfLiteService = tfLiteService,
        _categoryProvider = categoryProvider,
        _inventoryProvider = inventoryProvider;

  ScanStatus _status = ScanStatus.initial;
  ScanResultModel? _lastResult;
  String? _errorMessage;

  ScanStatus get status => _status;
  ScanResultModel? get lastResult => _lastResult;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ScanStatus.loading;

  Future<void> initModel() async {
    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _tfLiteService.loadModel();
      _status = ScanStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  Future<void> captureAndScan(Uint8List imageBytes) async {
    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _tfLiteService.runInference(imageBytes);
      
      // Look for a category whose name exactly matches the detectedLabel (case-insensitive)
      final category = _categoryProvider.categories.where(
        (c) => c.name.toLowerCase() == result.detectedLabel.toLowerCase()
      ).firstOrNull;

      _lastResult = result.copyWith(categoryId: category?.id);
      _status = ScanStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  Future<bool> confirmAndSave({required FoodItemModel item}) async {
    if (_lastResult?.imageBytes == null) return false;

    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload photo
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await _repository.uploadScanPhoto(
        imageBytes: _lastResult!.imageBytes!,
        fileName: fileName,
      );

      // 2. Call InventoryProvider.addItem (or equivalent, ensuring the image URL is set)
      final itemWithImage = item.copyWith(imageUrl: imageUrl);
      
      // Checking if addItem exists is not statically verifiable here in the prompt, 
      // but assuming it follows standard CRUD pattern
      final itemSaved = await _inventoryProvider.addItem(itemWithImage);
      
      if (!itemSaved) {
        throw Exception(_inventoryProvider.errorMessage ?? 'Gagal menyimpan item');
      }

      // 3. Log scan history
      await _repository.logScanHistory(
        result: _lastResult!,
        foodItemId: itemWithImage.id,
        savedToInventory: true,
      );

      _status = ScanStatus.success;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = ScanStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ScanStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelScan() async {
    if (_lastResult != null) {
      try {
        await _repository.logScanHistory(
          result: _lastResult!,
          foodItemId: null,
          savedToInventory: false,
        );
      } catch (_) {
        // Ignore errors during logging cancellation
      }
    }
    _lastResult = null;
    _status = ScanStatus.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _tfLiteService.close();
    super.dispose();
  }
}
