import 'package:flutter/material.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/category/models/category_model.dart';
import 'package:homesikil/features/category/repository/category_repository.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  CategoryStatus _status = CategoryStatus.initial;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  CategoryStatus get status => _status;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CategoryStatus.loading;

  List<CategoryModel> get fruits =>
      _categories.where((category) => category.isFruit).toList();
  List<CategoryModel> get vegetables =>
      _categories.where((category) => category.isVegetable).toList();

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (_status == CategoryStatus.loaded && !forceRefresh) return;

    _status = CategoryStatus.loading;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
      _status = CategoryStatus.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = CategoryStatus.error;
    }
    notifyListeners();
  }

  CategoryModel? findById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }
}
