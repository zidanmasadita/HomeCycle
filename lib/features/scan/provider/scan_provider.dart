import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homecycle/data/remote/tflite_service.dart';
import 'package:homecycle/errors/failure.dart';
import 'package:homecycle/features/category/provider/category_provider.dart';
import 'package:homecycle/features/inventory/models/food_item_model.dart';
import 'package:homecycle/features/inventory/provider/inventory_provider.dart';
import 'package:homecycle/features/scan/models/scan_quality.dart';
import 'package:homecycle/features/scan/models/scan_result_model.dart';
import 'package:homecycle/features/scan/repository/scan_repository.dart';

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
      _tfLiteService.resetLiveSmoothing();
      _liveResult = null;
      _status = ScanStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ScanStatus.error;
    }
    notifyListeners();
  }

  Future<void> processCameraFrame(
    CameraImage image, {
    int rotationDegrees = 0,
  }) async {
    if (_isProcessingFrame || _status != ScanStatus.success) return;

    _isProcessingFrame = true;
    try {
      final result = await _tfLiteService.runInferenceFromCameraImage(
        image,
        rotationDegrees: rotationDegrees,
      );
      final category = _categoryProvider.categories
          .where(
            (c) => c.name.toLowerCase() == result.detectedLabel.toLowerCase(),
          )
          .firstOrNull;

      final updated = result.copyWith(categoryId: category?.id);
      final previous = _liveResult;
      final hadError = _errorMessage != null;
      _liveResult = updated;
      _errorMessage = null;

      // Beri tahu UI hanya bila yang tampil benar-benar berubah: label
      // berganti, keyakinan bergerak cukup besar, atau status kecerahan
      // menyeberang ambang. Rebuild di setiap frame adalah salah satu
      // sumber tersendatnya layar pindai.
      final labelChanged = previous?.detectedLabel != updated.detectedLabel;
      final confidenceChanged =
          previous == null ||
          (previous.confidenceScore - updated.confidenceScore).abs() >= 0.02;
      final brightnessChanged =
          _brightnessBand(previous?.meanLuminance) !=
          _brightnessBand(updated.meanLuminance);
      if (hadError || labelChanged || confidenceChanged || brightnessChanged) {
        notifyListeners();
      }
    } catch (e, stacktrace) {
      debugPrint('Live scan error: $e\n$stacktrace');
      final message = 'Error: $e';
      if (_errorMessage != message) {
        _errorMessage = message;
        notifyListeners();
      }
    } finally {
      // Add a cool-down delay to reduce CPU usage and fix lag
      await Future.delayed(const Duration(milliseconds: 300));
      _isProcessingFrame = false;
    }
  }

  /// Pita kecerahan kasar dari luminansi: null (belum ada data), 0 =
  /// terlalu gelap, 1 = normal, 2 = terlalu terang. Dipakai untuk
  /// mendeteksi penyeberangan ambang gerbang kecerahan antar-frame.
  static int? _brightnessBand(double? meanLuminance) {
    if (meanLuminance == null) return null;
    if (meanLuminance < ScanQuality.minLuminance) return 0;
    if (meanLuminance > ScanQuality.maxLuminance) return 2;
    return 1;
  }

  /// Membekukan hasil live sebagai hasil akhir. Label mentahnya diganti
  /// penilaian multi-crop atas foto beresolusi penuh (lihat
  /// ScanCrop.multiFractions), karena hasil inilah yang disimpan dan
  /// cara itu terukur lebih tepat, terutama bila objek tidak memenuhi
  /// frame. Bila penilaian foto gagal, perilaku lama dipakai: bekukan
  /// hasil live dan lengkapi dengan foto + luminansinya.
  Future<void> captureWithQuality(Uint8List imageBytes) async {
    try {
      final refined = await _tfLiteService.runInferenceMultiCrop(imageBytes);
      final category = _categoryProvider.categories
          .where(
            (c) => c.name.toLowerCase() == refined.detectedLabel.toLowerCase(),
          )
          .firstOrNull;
      _liveResult = refined.copyWith(categoryId: category?.id);
    } catch (e) {
      debugPrint('Penilaian multi-crop gagal, pakai hasil live: $e');
      if (_liveResult != null) {
        final luminance = _tfLiteService.estimateMeanLuminance(imageBytes);
        _liveResult = _liveResult!.copyWith(
          imageBytes: imageBytes,
          meanLuminance: luminance,
        );
      }
    }
    captureLiveResult();
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
      final result = await _tfLiteService.runInferenceMultiCrop(imageBytes);

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
