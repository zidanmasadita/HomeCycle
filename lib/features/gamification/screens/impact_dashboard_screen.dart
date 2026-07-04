import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/utils/impact_calculator.dart';
import 'package:homesikil/features/gamification/provider/gamification_provider.dart';
import 'package:homesikil/features/dashboard/provider/dashboard_provider.dart';
import 'package:homesikil/features/gamification/widgets/impact_card_widget.dart';
import 'package:homesikil/features/gamification/widgets/streak_widget.dart';
import 'package:homesikil/features/gamification/widgets/achievement_badge.dart';
import 'package:homesikil/features/gamification/widgets/achievement_unlocked_dialog.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Your Impact',
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<GamificationProvider, DashboardProvider>(
        builder: (context, gamification, dashboard, child) {
          _checkNewlyUnlocked(context, gamification);

          final impactStats = dashboard.impactStats;
          final moneySaved = impactStats.totalMoneySaved;
          final co2Saved = impactStats.totalCo2Saved;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/mascots/Mascot6.png',
                        height: 100,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Great Job!',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By rescuing ${impactStats.itemsSaved} items, you\'ve saved Rp ${moneySaved.toStringAsFixed(0)} and reduced ${co2Saved.toStringAsFixed(1)} kg of CO2.',
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
                  label: 'Week Streak',
                  activeDays: gamification.filledDaysThisWeek,
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ImpactCardWidget(
                          title: 'Money Saved',
                          amount: 'Rp ${moneySaved.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet,
                          iconColor: AppColors.primary,
                          isCompact: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ImpactCardWidget(
                          title: 'CO2 Reduced',
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
                        'Achievements',
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (gamification.status == GamificationStatus.loading)
                        const Center(child: CircularProgressIndicator())
                      else if (gamification.achievements.isEmpty)
                        Center(
                          child: Text(
                            'No achievements yet.',
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
                                childAspectRatio: 0.95,
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
                                      ? 'Show less'
                                      : 'Show all achievements',
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
                                  ? 'Keep it up!'
                                  : 'Rescue food more often!',
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
                                  ? 'You are on a great streak of saving food and money.'
                                  : 'You haven\'t rescued food recently. Start saving today!',
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
          );
        },
      ),
    );
  }
}
