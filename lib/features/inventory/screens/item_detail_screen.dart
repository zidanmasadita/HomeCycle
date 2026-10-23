import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecycle/core/widgets/detail_row_widget.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:homecycle/core/constants/app_dimens.dart';
import 'package:homecycle/features/inventory/widgets/expiry_badge.dart';
import 'package:homecycle/features/inventory/models/food_item_model.dart';
import 'package:homecycle/features/category/provider/category_provider.dart';
import 'package:homecycle/features/inventory/provider/inventory_provider.dart';
import 'package:homecycle/features/consumption/provider/consumption_provider.dart';
import 'package:homecycle/features/dashboard/provider/dashboard_provider.dart';
import 'package:homecycle/features/gamification/provider/gamification_provider.dart';
import 'package:homecycle/features/household/provider/household_provider.dart';
import 'package:homecycle/features/gamification/widgets/achievement_unlocked_dialog.dart';
import 'package:homecycle/features/inventory/widgets/food_image.dart';
import 'package:homecycle/features/consumption/repository/consumption_repository.dart';
import 'package:homecycle/core/utils/app_helpers.dart';
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

    // Semua provider dan id admin ditangkap di depan, sebelum ada
    // await atau pop, agar context tidak dipakai setelah widget
    // dinonaktifkan.
    final inventory = context.read<InventoryProvider>();
    final consumption = context.read<ConsumptionProvider>();
    final dashboard = context.read<DashboardProvider>();
    final gamification = context.read<GamificationProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final adminId =
        context.read<HouseholdProvider>().adminId ?? widget.item.userId;

    try {
      final currentItem = inventory.inventory.firstWhere(
        (i) => i.id == widget.item.id,
        orElse: () => widget.item,
      );

      final category = categoryProvider.categories
          .where((c) => c.id == currentItem.categoryId)
          .firstOrNull;
      if (category == null) {
        AppHelpers.showError('Kategori item tidak ditemukan, aksi dibatalkan.');
        return;
      }

      final itemName = currentItem.customName ?? category.name;

      // Pembaruan dijalankan DULU. Sebelumnya toast sukses tampil
      // sebelum operasi dan layar ditutup sebelum pekerjaan selesai,
      // sehingga kegagalan di basis data berakhir tanpa pesan apa pun.
      final success = await inventory.consumeOrWastePartial(
        currentItem,
        action,
        1.0,
      );

      if (!success) {
        AppHelpers.showError(
          inventory.errorMessage ?? 'Gagal memperbarui item. Coba lagi.',
        );
        return;
      }

      final consumedItem = currentItem.copyWith(quantity: 1.0);
      final logged = await consumption.recordConsumption(
        item: consumedItem,
        category: category,
        action: action,
      );
      if (!logged) {
        AppHelpers.showError(
          consumption.errorMessage ??
              'Status item berubah, tetapi catatan konsumsi gagal disimpan.',
        );
        return;
      }

      await dashboard.loadDashboard();

      if (action == 'consumed') {
        final consumptionRepo = ConsumptionRepository();
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

      AppHelpers.showSuccess(
        action == 'consumed'
            ? 'inventory.success_consumed'.tr(args: [itemName])
            : 'inventory.success_wasted'.tr(args: [itemName]),
      );

      // Layar ditutup terakhir, hanya bila item benar-benar habis.
      if (currentItem.quantity <= 1.0 && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Jangan biarkan kegagalan apa pun mati diam-diam: sebelumnya
      // handler ini hanya punya try-finally, jadi setiap lemparan yang
      // tidak tertangkap membuat tombol tampak tidak berpengaruh.
      if (mounted) {
        AppHelpers.showError('Gagal memproses aksi: $e');
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
                              style: AppTextStyles.title1SemiBold.copyWith(
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
                      DetailRowWidget(
                        icon: Icons.category_outlined,
                        label: 'inventory.category'.tr(),
                        value: categoryName,
                        padding: const EdgeInsets.only(bottom: 20.0),
                      ),
                      DetailRowWidget(
                        icon: Icons.calendar_today_outlined,
                        label: 'inventory.purchase_date'.tr(),
                        value: formatter.format(item.createdAt),
                        padding: const EdgeInsets.only(bottom: 20.0),
                      ),
                      DetailRowWidget(
                        icon: Icons.event_busy_outlined,
                        label: 'inventory.expiry_date'.tr(),
                        value: formatter.format(item.estimatedExpiredDate),
                        padding: const EdgeInsets.only(bottom: 20.0),
                      ),
                      DetailRowWidget(
                        icon: Icons.shopping_bag_outlined,
                        label: 'inventory.quantity'.tr(),
                        value: '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                        padding: const EdgeInsets.only(bottom: 20.0),
                      ),
                      DetailRowWidget(
                        icon: Icons.kitchen_outlined,
                        label: 'inventory.storage'.tr(),
                        value: formatStorageLocation(item.storageLocation),
                        padding: const EdgeInsets.only(bottom: 20.0),
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
                                style: AppTextStyles.body1Bold.copyWith(
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
                                style: AppTextStyles.body1Bold.copyWith(
                                  color: Colors.redAccent,
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

}
