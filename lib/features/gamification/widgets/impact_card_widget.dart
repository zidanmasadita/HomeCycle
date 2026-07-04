import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';

class ImpactCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final String? comparisonText;
  final IconData icon;
  final Color iconColor;

  final bool isCompact;

  const ImpactCardWidget({
    super.key,
    required this.title,
    required this.amount,
    this.comparisonText,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? null : double.infinity,
      margin: EdgeInsets.only(bottom: isCompact ? 0 : 16),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 8 : 10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: isCompact ? 20 : 24),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
              ],
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.title.copyWith(fontSize: 14),
            ),
          ],
          SizedBox(height: isCompact ? 8 : 16),
          Text(
            amount,
            style: AppTextStyles.heading.copyWith(
              fontSize: isCompact ? 24 : 32,
              color: AppColors.primary,
            ),
          ),
          if (comparisonText != null) ...[
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              comparisonText!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade500,
                fontSize: isCompact ? 12 : 14,
              ),
              maxLines: isCompact ? 2 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
            ),
          ],
        ],
      ),
    );
  }
}
