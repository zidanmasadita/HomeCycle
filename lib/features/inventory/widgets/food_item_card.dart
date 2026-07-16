import 'package:flutter/material.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/inventory/widgets/expiry_badge.dart';
import 'package:homesikil/routes/app_routes.dart';

import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/category/models/category_model.dart';
import 'package:homesikil/features/inventory/widgets/food_image.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItemModel item;
  final CategoryModel? category;

  const FoodItemCard({super.key, required this.item, this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.itemDetail, arguments: item);
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FoodImage(
                  item: item,
                  category: category,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final rawTitle = item.customName ?? category?.name ?? 'inventory.unknown_item'.tr();
                      final title = rawTitle.isNotEmpty 
                          ? '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}'
                          : rawTitle;
                      return Text(
                        title,
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      );
                    }
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isExpired 
                        ? 'inventory.status_expired'.tr()
                        : 'inventory.days_left'.tr(args: [item.daysUntilExpiration.toString()]),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: item.isExpired ? AppColors.red : Colors.grey.shade600,
                      fontWeight: item.isExpired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'inventory.stock_info'.tr(args: [item.quantity.toInt().toString(), item.unit]),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            ExpiryBadge(
              status: item.isExpired 
                  ? 'inventory.status_expired'.tr() 
                  : (item.isExpiringSoon ? 'inventory.status_soon'.tr() : 'inventory.status_fresh'.tr()),
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
