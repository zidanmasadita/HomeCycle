import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/utils/impact_calculator.dart';
import 'package:homesikil/features/gamification/provider/gamification_provider.dart';
import 'package:homesikil/features/dashboard/provider/dashboard_provider.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/gamification/widgets/impact_card_widget.dart';
import 'package:homesikil/features/gamification/widgets/streak_widget.dart';
import 'package:homesikil/features/gamification/widgets/achievement_badge.dart';
import 'package:homesikil/features/gamification/widgets/achievement_unlocked_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  bool _showAllAchievements = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gamification = context.read<GamificationProvider>();
      gamification.loadAchievements();
      gamification.loadStreakData();
      context.read<DashboardProvider>().loadDashboard();
      context.read<InventoryProvider>().loadInventory();
    });
  }

  void _checkNewlyUnlocked(
    BuildContext context,
    GamificationProvider gamification,
  ) {
    if (gamification.newlyUnlocked.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AchievementUnlockedDialog.showSequentially(context, gamification);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // Force rebuild on locale change
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'gamification.your_impact'.tr(),
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer3<GamificationProvider, DashboardProvider, InventoryProvider>(
        builder: (context, gamification, dashboard, inventory, child) {
          _checkNewlyUnlocked(context, gamification);

          final impactStats = dashboard.impactStats;
          final moneySaved = impactStats.totalMoneySaved;
          final co2Saved = impactStats.totalCo2Saved;
          
          final expiredItems = inventory.expiredItems;
          final hasExpiredItems = expiredItems.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<GamificationProvider>().loadImpactStats();
              await context.read<GamificationProvider>().loadAchievements();
              await context.read<DashboardProvider>().loadDashboard();
              await context.read<InventoryProvider>().loadInventory();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: hasExpiredItems ? Colors.red.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasExpiredItems ? Colors.red.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      ColorFiltered(
                        colorFilter: hasExpiredItems 
                          ? const ColorFilter.matrix([
                              0.33, 0.59, 0.11, 0, 0,
                              0.33, 0.59, 0.11, 0, 0,
                              0.33, 0.59, 0.11, 0, 0,
                              0,    0,    0,    1, 0,
                            ])
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                        child: Image.asset(
                          'assets/images/mascots/Mascot6.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasExpiredItems ? 'gamification.oh_no'.tr() : 'gamification.great_job'.tr(),
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 20,
                                color: hasExpiredItems ? Colors.red.shade700 : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasExpiredItems 
                                ? 'gamification.expired_items_msg'.tr(args: [expiredItems.length.toString()])
                                : 'gamification.rescued_items_msg'.tr(args: [impactStats.itemsSaved.toString(), moneySaved.toStringAsFixed(0), co2Saved.toStringAsFixed(1)]),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Streak
                StreakWidget(
                  streakNumber: gamification.currentStreakWeeks,
                  label: 'gamification.week_streak'.tr(),
                  activeDays: gamification.filledDaysThisWeek,
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ImpactCardWidget(
                          title: 'gamification.money_saved'.tr(),
                          amount: 'Rp ${moneySaved.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet,
                          iconColor: AppColors.primary,
                          isCompact: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ImpactCardWidget(
                          title: 'gamification.co2_reduced'.tr(),
                          amount: '${co2Saved.toStringAsFixed(1)} kg',
                          comparisonText:
                              ImpactCalculator.getRelatableComparison(co2Saved),
                          icon: Icons.eco,
                          iconColor: AppColors.primary,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Achievements Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Text(
                        'gamification.achievements'.tr(),
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (gamification.status == GamificationStatus.loading)
                        const Center(child: CircularProgressIndicator())
                      else if (gamification.achievements.isEmpty)
                        Center(
                          child: Text(
                            'gamification.no_achievements'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _showAllAchievements
                              ? gamification.achievements.length
                              : (gamification.achievements.length > 6
                                    ? 6
                                    : gamification.achievements.length),
                          itemBuilder: (context, index) {
                            final achievement =
                                gamification.achievements[index];
                            return AchievementBadge(achievement: achievement);
                          },
                        ),
                      if (gamification.achievements.length > 6) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showAllAchievements = !_showAllAchievements;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showAllAchievements
                                      ? 'gamification.show_less'.tr()
                                      : 'gamification.show_all_achievements'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _showAllAchievements
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: gamification.currentStreakWeeks > 0
                        ? Colors.orange.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: gamification.currentStreakWeeks > 0
                          ? Colors.orange.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        gamification.currentStreakWeeks > 0
                            ? Icons.tips_and_updates
                            : Icons.warning_amber_rounded,
                        color: gamification.currentStreakWeeks > 0
                            ? Colors.orange
                            : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gamification.currentStreakWeeks > 0
                                  ? 'gamification.keep_it_up'.tr()
                                  : 'gamification.rescue_more_often'.tr(),
                              style: AppTextStyles.title.copyWith(
                                fontSize: 16,
                                color: gamification.currentStreakWeeks > 0
                                    ? Colors.orange.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gamification.currentStreakWeeks > 0
                                  ? 'gamification.great_streak_msg'.tr()
                                  : 'gamification.no_recent_rescue_msg'.tr(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: gamification.currentStreakWeeks > 0
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
