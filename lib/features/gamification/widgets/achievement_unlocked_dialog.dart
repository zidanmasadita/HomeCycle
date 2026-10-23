import 'package:flutter/material.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:homecycle/features/gamification/models/achievement_model.dart';
import 'package:homecycle/features/gamification/widgets/achievement_badge.dart';
import 'package:homecycle/features/gamification/provider/gamification_provider.dart';

class AchievementUnlockedDialog extends StatelessWidget {
  final AchievementModel achievement;
  final GamificationProvider gamification;
  
  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.gamification,
  });

  static Future<void> showSequentially(
      BuildContext context, GamificationProvider gamification) async {
    final unlocked = List<AchievementModel>.from(gamification.newlyUnlocked);
    gamification.clearNewlyUnlocked();
    
    for (var achievement in unlocked) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AchievementUnlockedDialog(
          achievement: achievement,
          gamification: gamification,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascots/Mascot6.png',
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'New Achievement Unlocked!',
              style: AppTextStyles.title3Bold.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AchievementBadge(achievement: achievement),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Awesome!',
                  style: AppTextStyles.body1Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
