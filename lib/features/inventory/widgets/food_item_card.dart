import 'package:flutter/material.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/inventory/widgets/expiry_badge.dart';
import 'package:homesikil/routes/app_routes.dart';

import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/category/models/category_model.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItemModel item;
  final CategoryModel? category;

  const FoodItemCard({super.key, required this.item, this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.itemDetail);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: Image.asset(
                item.imageUrl ?? category?.iconUrl ?? AppAssets.logo,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.customName ?? category?.name ?? 'Unknown Item',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isExpired 
                        ? 'Expired' 
                        : '${item.daysUntilExpiration} days left',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: item.isExpired ? AppColors.red : Colors.grey.shade600,
                      fontWeight: item.isExpired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            ExpiryBadge(
              status: item.isExpired 
                  ? 'Expired' 
                  : (item.isExpiringSoon ? 'Soon' : 'Fresh'),
              backgroundColor: item.isExpired 
                  ? AppColors.red.withValues(alpha: 0.1)
                  : (item.isExpiringSoon ? AppColors.yellow.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1)),
              textColor: item.isExpired 
                  ? AppColors.red 
                  : (item.isExpiringSoon ? AppColors.yellow : AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}
