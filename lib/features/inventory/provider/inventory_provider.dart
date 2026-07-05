import 'package:flutter/material.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/inventory/repository/inventory_repository.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repository;

  InventoryProvider(this._repository);

  InventoryStatus _status = InventoryStatus.initial;
  List<FoodItemModel> _items = [];
  String? _errorMessage;
  String? _adminId;

  void updateAdminId(String? adminId) {
    if (_adminId != adminId) {
      _adminId = adminId;
      if (_adminId != null) {
        loadInventory();
      }
    }
  }

  InventoryStatus get status => _status;
  List<FoodItemModel> get inventory => _items;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == InventoryStatus.loading;

  List<FoodItemModel> get activeItems =>
      _items.where((item) => item.isActive).toList();
  List<FoodItemModel> get expiringSoonItems =>
      _items.where((item) => item.isExpiringSoon).toList();
  List<FoodItemModel> get expiredItems =>
      _items.where((item) => item.isExpired).toList();

  Future<void> loadInventory() async {
    _status = InventoryStatus.loading;
    notifyListeners();

    try {
      if (_adminId == null) {
        _items = [];
      } else {
        _items = await _repository.getInventory(
          status: 'active',
          adminId: _adminId!,
        );
      }
      _status = InventoryStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = InventoryStatus.error;
    }
    notifyListeners();
  }

  Future<FoodItemModel?> addItem(FoodItemModel item) async {
    try {
      final newItem = await _repository.addItem(item);
      _items = [..._items, newItem];
      notifyListeners();
      return newItem;
    } on Failure catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateItem(FoodItemModel item) async {
    try {
      final updatedItem = await _repository.updateItem(item);
      _items = _items
          .map((i) => i.id == updatedItem.id ? updatedItem : i)
          .toList();
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> consumeOrWastePartial(
    FoodItemModel item,
    String status,
    double amount,
  ) async {
    final newQuantity = item.quantity - amount;

    final originalItems = List<FoodItemModel>.from(_items);
    if (newQuantity <= 0) {
      _items = _items.where((i) => i.id != item.id).toList();
    } else {
      _items = _items
          .map((i) => i.id == item.id ? i.copyWith(quantity: newQuantity) : i)
          .toList();
    }
    notifyListeners();

    try {
      if (newQuantity <= 0) {
        await _repository.updateStatus(item.id, status);
      } else {
        await _repository.updateQuantity(item.id, newQuantity);
      }
      return true;
    } on Failure catch (e) {
      _items = originalItems;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
      _items = _items.where((item) => item.id != id).toList();
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}

class InventoryModel {}
