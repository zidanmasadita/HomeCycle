import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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
  }) : _repository = repository,
       _tfLiteService = tfLiteService,
       _categoryProvider = categoryProvider,
       _inventoryProvider = inventoryProvider;

  ScanStatus _status = ScanStatus.initial;
  ScanResultModel? _lastResult;
  ScanResultModel? _liveResult;
  String? _errorMessage;
  bool _isProcessingFrame = false;

  ScanStatus get status => _status;
  ScanResultModel? get lastResult => _lastResult;
  ScanResultModel? get liveResult => _liveResult;
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

  Future<void> processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _status != ScanStatus.success) return;

    _isProcessingFrame = true;
    try {
      final result = await _tfLiteService.runInferenceFromCameraImage(image);
      final category = _categoryProvider.categories
          .where(
            (c) => c.name.toLowerCase() == result.detectedLabel.toLowerCase(),
          )
          .firstOrNull;

      _liveResult = result.copyWith(categoryId: category?.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Live scan error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  void captureLiveResult() {
    if (_liveResult != null) {
      _lastResult = _liveResult;
      notifyListeners();
    }
  }

  Future<void> captureAndScan(Uint8List imageBytes) async {
    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _tfLiteService.runInference(imageBytes);

      final category = _categoryProvider.categories
          .where(
            (c) => c.name.toLowerCase() == result.detectedLabel.toLowerCase(),
          )
          .firstOrNull;

      _lastResult = result.copyWith(categoryId: category?.id);
      _status = ScanStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  Future<bool> confirmAndSave({
    required FoodItemModel item,
    required String adminId,
  }) async {
    if (_lastResult?.imageBytes == null) return false;

    _status = ScanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await _repository.uploadScanPhoto(
        imageBytes: _lastResult!.imageBytes!,
        fileName: fileName,
        adminId: adminId,
      );

      final itemWithImage = item.copyWith(imageUrl: imageUrl);

      final itemSaved = await _inventoryProvider.addItem(itemWithImage);

      if (itemSaved == null) {
        throw Exception(
          _inventoryProvider.errorMessage ?? 'Gagal menyimpan item',
        );
      }

      await _repository.logScanHistory(
        result: _lastResult!,
        foodItemId: itemSaved.id,
        savedToInventory: true,
        adminId: adminId,
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

  Future<void> cancelScan(String adminId) async {
    if (_lastResult != null) {
      try {
        await _repository.logScanHistory(
          result: _lastResult!,
          foodItemId: null,
          savedToInventory: false,
          adminId: adminId,
        );
      } catch (_) {}
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
