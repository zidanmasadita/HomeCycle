import 'package:flutter/material.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/constants/app_dimens.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';

import 'package:homecycle/features/inventory/models/food_item_model.dart';
import 'package:homecycle/features/category/models/category_model.dart';
import 'package:homecycle/features/inventory/widgets/food_image.dart';

class ExpiringSoonCard extends StatelessWidget {
  final FoodItemModel item;
  final CategoryModel? category;
  final String title;
  final String daysLeft;
  final String badgeText;
  final Color badgeColor;

  const ExpiringSoonCard({
    super.key,
    required this.item,
    this.category,
    required this.title,
    required this.daysLeft,
    this.badgeText = 'Soon',
    this.badgeColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimens.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FoodImage(
              item: item,
              category: category,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title3Bold.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft,
                  style: AppTextStyles.body2Medium.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.label1Bold.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
