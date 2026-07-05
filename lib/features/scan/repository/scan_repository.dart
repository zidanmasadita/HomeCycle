import 'dart:typed_data';
import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/scan/models/scan_result_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanRepository {
  final _client = SupabaseService.client;
  static const _bucket = 'scan-photos';
  static const _table = 'scan_history';

  Future<String> uploadScanPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String adminId,
  }) async {
    try {
      final path = '$adminId/$fileName';
      
      await _client.storage.from(_bucket).uploadBinary(
        path,
        imageBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      return _client.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> logScanHistory({
    required ScanResultModel result,
    String? foodItemId,
    required bool savedToInventory,
    required String adminId,
  }) async {
    try {
      await _client.from(_table).insert({
        'user_id': adminId,
        'detected_label': result.detectedLabel,
        'confidence_score': result.confidenceScore,
        'category_id': result.categoryId,
        'food_item_id': foodItemId,
        'was_saved_to_inventory': savedToInventory,
      });
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
