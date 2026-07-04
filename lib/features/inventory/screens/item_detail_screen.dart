import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/inventory/widgets/expiry_badge.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/consumption/provider/consumption_provider.dart';
import 'package:homesikil/features/dashboard/provider/dashboard_provider.dart';
import 'package:homesikil/features/gamification/provider/gamification_provider.dart';
import 'package:homesikil/features/consumption/repository/consumption_repository.dart';
import 'package:homesikil/features/gamification/widgets/achievement_unlocked_dialog.dart';

class ItemDetailScreen extends StatefulWidget {
  final FoodItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isLoading = false;

  Future<void> _handleAction(String action) async {
    setState(() => _isLoading = true);

    try {
      final inventory = context.read<InventoryProvider>();
      final consumption = context.read<ConsumptionProvider>();
      final dashboard = context.read<DashboardProvider>();
      final gamification = context.read<GamificationProvider>();

      final category = context.read<CategoryProvider>().categories.firstWhere(
        (c) => c.id == widget.item.categoryId,
      );

      bool success = false;
      if (action == 'consumed') {
        success = await inventory.markAsConsumed(widget.item.id);
      } else {
        success = await inventory.markAsWasted(widget.item.id);
      }

      if (success) {
        await consumption.recordConsumption(
          item: widget.item,
          category: category,
          action: action,
        );

        await dashboard.loadDashboard();

        if (action == 'consumed') {
          final consumptionRepo = ConsumptionRepository();
          final streak = await consumptionRepo.getCurrentStreakWeeks();

          await gamification.checkAndUnlockAchievements(
            itemsSavedCount: dashboard.impactStats.itemsSaved,
            currentStreakWeeks: streak,
            totalCo2Saved: dashboard.impactStats.totalCo2Saved,
            totalMoneySaved: dashboard.impactStats.totalMoneySaved,
          );

          if (gamification.newlyUnlocked.isNotEmpty && mounted) {
            await AchievementUnlockedDialog.showSequentially(
              context,
              gamification,
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final category = context.read<CategoryProvider>().categories.firstWhere(
      (c) => c.id == item.categoryId,
    );

    final title = item.customName?.isNotEmpty == true
        ? item.customName!
        : category.name;
    final formatter = DateFormat('dd MMM yyyy');

    Color badgeColor;
    Color textColor;
    String statusText;

    if (item.isExpired) {
      badgeColor = AppColors.red.withValues(alpha: 0.1);
      textColor = AppColors.red;
      statusText = 'Expired';
    } else if (item.isExpiringSoon) {
      badgeColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
      statusText = 'Expiring Soon';
    } else {
      badgeColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      statusText = 'Fresh';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Top Image
                Container(
                  height: 250,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                category.iconUrl ??
                                    'assets/images/food-images/apple.png',
                                fit: BoxFit.contain,
                              ),
                        )
                      : Image.asset(
                          category.iconUrl ??
                              'assets/images/food-images/apple.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              ),
                        ),
                ),

                // Details Card
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingLarge,
                  ),
                  padding: const EdgeInsets.all(AppDimens.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.05),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 26,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ExpiryBadge(
                            status: statusText,
                            backgroundColor: badgeColor,
                            textColor: textColor,
                            paddingHorizontal: 14,
                            fontSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Detail Rows
                      _buildDetailRow(
                        Icons.category_outlined,
                        'Category',
                        category.name,
                      ),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Purchase Date',
                        formatter.format(item.createdAt),
                      ),
                      _buildDetailRow(
                        Icons.event_busy_outlined,
                        'Expiry Date',
                        formatter.format(item.estimatedExpiredDate),
                      ),
                      _buildDetailRow(
                        Icons.shopping_bag_outlined,
                        'Quantity',
                        '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                      ),
                      _buildDetailRow(
                        Icons.kitchen_outlined,
                        'Storage',
                        item.storageLocation ?? 'Unknown',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleAction('consumed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Mark as Consumed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleAction('wasted'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.red,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Mark as Wasted',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
