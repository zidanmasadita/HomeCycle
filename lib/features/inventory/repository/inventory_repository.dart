import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';

class InventoryRepository {
  final _client = SupabaseService.client;
  static const _table = 'food_items';

  Future<List<FoodItemModel>> getInventory({
    String? status,
    required String adminId,
  }) async {
    try {
      var query = _client.from(_table).select().eq('user_id', adminId);

      if (status != null) {
        query = query.eq('actual_status', status);
      }

      final response = await query.order('estimated_expired_date');
      return (response as List)
          .map((json) => FoodItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FoodItemModel> getById(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();
      return FoodItemModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FoodItemModel> addItem(FoodItemModel item) async {
    try {
      final response = await _client
          .from(_table)
          .insert(item.toInsertJson())
          .select()
          .single();
      return FoodItemModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FoodItemModel> updateItem(FoodItemModel item) async {
    try {
      final response = await _client
          .from(_table)
          .update(item.toInsertJson())
          .eq('id', item.id)
          .select()
          .single();
      return FoodItemModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> updateQuantity(String id, double quantity) async {
    try {
      await _client.from(_table).update({'quantity': quantity}).eq('id', id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _client.from(_table).update({'actual_status': status}).eq('id', id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
