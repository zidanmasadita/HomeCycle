import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/category/models/category_model.dart';

class CategoryRepository {
  final _client = SupabaseService.client;
  static const _table = 'categories';

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _client.from(_table).select().order('name');
      ();
      return (response as List<dynamic>)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<CategoryModel>> getByType(String type) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('type', type)
          .order('name');
      return (response as List<dynamic>)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<CategoryModel?> getById(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
