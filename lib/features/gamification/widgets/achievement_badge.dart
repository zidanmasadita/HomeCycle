import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/gamification/models/achievement_model.dart';

class AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadge({super.key, required this.achievement});

  void _showAchievementDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: achievement.iconUrl != null
                      ? Image.asset(
                          'assets/images/badges/${achievement.iconUrl}${achievement.isUnlocked ? '' : '-locked'}.png',
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          Icons.emoji_events,
                          size: 64,
                          color: achievement.isUnlocked
                              ? AppColors.primary
                              : Colors.grey.shade400,
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  achievement.title,
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (achievement.isUnlocked && achievement.achievedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Unlocked on ${achievement.achievedAt!.day}/${achievement.achievedAt!.month}/${achievement.achievedAt!.year}',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Locked',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: [
                if (achievement.isUnlocked)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: achievement.iconUrl != null
                ? Image.asset(
                    'assets/images/badges/${achievement.iconUrl}${achievement.isUnlocked ? '' : '-locked'}.png',
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.emoji_events,
                    color: achievement.isUnlocked
                        ? AppColors.primary
                        : Colors.grey.shade500,
                    size: 32,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: AppTextStyles.title.copyWith(
              fontSize: 12,
              color: achievement.isUnlocked
                  ? Colors.black87
                  : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
