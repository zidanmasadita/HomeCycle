import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:homesikil/features/gamification/widgets/achievement_unlocked_dialog.dart';
import 'package:homesikil/features/inventory/widgets/food_image.dart';
import 'package:homesikil/features/consumption/repository/consumption_repository.dart';
import 'package:homesikil/core/utils/app_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';

class ItemDetailScreen extends StatefulWidget {
  final FoodItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isLoading = false;

  Future<void> _handleAction(String action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final inventory = context.read<InventoryProvider>();
      final consumption = context.read<ConsumptionProvider>();
      final dashboard = context.read<DashboardProvider>();
      final gamification = context.read<GamificationProvider>();

      final currentItem = inventory.inventory.firstWhere(
        (i) => i.id == widget.item.id,
        orElse: () => widget.item,
      );

      final category = context.read<CategoryProvider>().categories.firstWhere(
        (c) => c.id == currentItem.categoryId,
      );

      if (currentItem.quantity <= 1.0 && mounted) {
        Navigator.pop(context);
      }

      final actionText = action == 'consumed' ? 'inventory.consumed'.tr().toLowerCase() : 'inventory.wasted'.tr().toLowerCase();
      AppSnackbar.showSuccess(
        action == 'consumed' 
          ? 'inventory.success_consumed'.tr(args: [currentItem.customName ?? category.name])
          : 'inventory.success_wasted'.tr(args: [currentItem.customName ?? category.name]),
      );

      bool success = false;
      if (action == 'consumed') {
        success = await inventory.consumeOrWastePartial(
          currentItem,
          'consumed',
          1.0,
        );
      } else {
        success = await inventory.consumeOrWastePartial(
          currentItem,
          'wasted',
          1.0,
        );
      }

      if (success) {
        final consumedItem = currentItem.copyWith(quantity: 1.0);
        await consumption.recordConsumption(
          item: consumedItem,
          category: category,
          action: action,
        );

        await dashboard.loadDashboard();

        if (action == 'consumed') {
          final consumptionRepo = ConsumptionRepository();
          final adminId =
              context.read<HouseholdProvider>().adminId ?? currentItem.userId;
          final streak = await consumptionRepo.getCurrentStreakWeeks(adminId);

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
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = context.watch<InventoryProvider>().inventory.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );

    final category = context.read<CategoryProvider>().categories.firstWhere(
      (c) => c.id == item.categoryId,
    );

    String rawTitle = item.customName?.isNotEmpty == true
        ? item.customName!
        : category.name;
    final title = rawTitle.isNotEmpty 
        ? '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}'
        : rawTitle;
    
    final categoryName = category.name.isNotEmpty
        ? '${category.name[0].toUpperCase()}${category.name.substring(1)}'
        : category.name;
    
    String formatStorageLocation(String? loc) {
      if (loc == 'room_temp') return 'inventory.room_temp'.tr();
      if (loc == 'fridge') return 'inventory.fridge'.tr();
      if (loc == 'freezer') return 'inventory.freezer'.tr();
      if (loc == null || loc.isEmpty) return 'inventory.unknown'.tr();
      return '${loc[0].toUpperCase()}${loc.substring(1)}';
    }
    final formatter = DateFormat('dd MMM yyyy', context.locale.languageCode);

    Color badgeColor;
    Color textColor;
    String statusText;

    if (item.isExpired) {
      badgeColor = AppColors.red.withValues(alpha: 0.1);
      textColor = AppColors.red;
      statusText = 'inventory.status_expired'.tr();
    } else if (item.isExpiringSoon) {
      badgeColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
      statusText = 'inventory.status_expiring_soon'.tr();
    } else {
      badgeColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      statusText = 'inventory.status_fresh'.tr();
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
                  child: FoodImage(
                    item: item,
                    category: category,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
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
                        'inventory.category'.tr(),
                        categoryName,
                      ),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'inventory.purchase_date'.tr(),
                        formatter.format(item.createdAt),
                      ),
                      _buildDetailRow(
                        Icons.event_busy_outlined,
                        'inventory.expiry_date'.tr(),
                        formatter.format(item.estimatedExpiredDate),
                      ),
                      _buildDetailRow(
                        Icons.shopping_bag_outlined,
                        'inventory.quantity'.tr(),
                        '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                      ),
                      _buildDetailRow(
                        Icons.kitchen_outlined,
                        'inventory.storage'.tr(),
                        formatStorageLocation(item.storageLocation),
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
                          onPressed: _isLoading ? null : () => _handleAction('consumed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'inventory.consumed'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => _handleAction('wasted'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.redAccent,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'inventory.wasted'.tr(),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
