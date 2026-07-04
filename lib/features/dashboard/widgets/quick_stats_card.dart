import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/gamification/provider/gamification_provider.dart';
import 'package:provider/provider.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final gamification = context.watch<GamificationProvider>();

    final inventoryCount = inventory.inventory.length;
    final expiringSoonCount = inventory.expiringSoonItems.length;
    final moneySaved = gamification.impactStats.totalMoneySaved;
    final co2Saved = gamification.impactStats.totalCo2Saved;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            // Top Row
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        title: 'Inventory',
                        value: '$inventoryCount',
                        subtitle: 'items',
                      ),
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: _buildStatItem(
                        title: 'Expiring Soon',
                        value: '$expiringSoonCount',
                        subtitle: 'items',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingMedium),
            // Bottom Row
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        title: 'Saved Money',
                        value: 'Rp ${moneySaved.toStringAsFixed(0)}',
                        iconPath: AppAssets.coin,
                      ),
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: _buildStatItem(
                        title: 'CO² Saved',
                        value: '${co2Saved.toStringAsFixed(1)} kg',
                        iconPath: AppAssets.leaf,
                        showInfo: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    String? subtitle,
    String? iconPath,
    bool showInfo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showInfo)
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
              if (iconPath != null) ...[
                const Spacer(),
                Image.asset(
                  iconPath,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.eco, color: AppColors.primary, size: 24),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: Colors.grey.shade400,
    );
  }


}
