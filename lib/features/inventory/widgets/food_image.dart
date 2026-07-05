import 'package:flutter/material.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/category/models/category_model.dart';
import 'package:homesikil/core/constants/app_colors.dart';

class FoodImage extends StatelessWidget {
  final FoodItemModel item;
  final CategoryModel? category;
  final double width;
  final double height;
  final BoxFit fit;

  const FoodImage({
    super.key,
    required this.item,
    this.category,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
  });

  String _getCategoryAssetPath(String iconUrl) {
    if (iconUrl.startsWith('http')) return iconUrl;
    if (iconUrl.startsWith('assets/')) return iconUrl;
    return 'assets/images/food-images/$iconUrl';
  }

  @override
  Widget build(BuildContext context) {
    final itemName = (item.customName ?? category?.name ?? '')
        .toLowerCase()
        .replaceAll(' ', '');
    final nameAsset = 'assets/images/food-images/$itemName.png';

    return Image.asset(
      nameAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
          return Image.network(
            item.imageUrl!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                _buildCategoryFallback(),
          );
        }

        return _buildCategoryFallback();
      },
    );
  }

  Widget _buildCategoryFallback() {
    if (category?.iconUrl != null) {
      return Image.asset(
        _getCategoryAssetPath(category!.iconUrl!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildInitialsFallback(),
      );
    }
    return _buildInitialsFallback();
  }

  Widget _buildInitialsFallback() {
    final name = item.customName ?? category?.name ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: width * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
