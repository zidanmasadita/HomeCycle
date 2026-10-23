import 'package:flutter/material.dart';
import 'package:homecycle/features/inventory/models/food_item_model.dart';
import 'package:homecycle/features/category/models/category_model.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';

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
    // Nilai icon_url dari database bisa masih berakhiran .png; aset lokal
    // food-images sudah dikonversi ke WebP (branch development, 23 Okt 2026).
    final normalized = iconUrl.endsWith('.png')
        ? '${iconUrl.substring(0, iconUrl.length - 4)}.webp'
        : iconUrl;
    if (normalized.startsWith('assets/')) return normalized;
    return 'assets/images/food-images/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    final itemName = (item.customName ?? category?.name ?? '')
        .toLowerCase()
        .replaceAll(' ', '');
    final nameAsset = 'assets/images/food-images/$itemName.webp';

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
          style: AppTextStyles.body1Bold.copyWith(
            fontSize: width * 0.4,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
