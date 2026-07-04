import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/notification/models/notification_model.dart';
import 'package:homesikil/features/notification/provider/notification_provider.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    void handleNavigation() {
      if (isUnread) {
        context.read<NotificationProvider>().markAsRead(notification.id);
      }

      if (notification.type == 'achievement') {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboard, (route) => false,
            arguments: {'index': 3});
      } else if (notification.type == 'invite' || notification.type == 'household' || notification.type == 'household_invite') {
        Navigator.pushNamed(context, AppRoutes.householdMembers);
      } else if (notification.type == 'expiring_soon' ||
          notification.type == 'expired') {
        if (notification.foodItemId != null) {
          final items = context
              .read<InventoryProvider>()
              .inventory
              .where((i) => i.id == notification.foodItemId);
          if (items.isNotEmpty) {
            Navigator.pushNamed(context, AppRoutes.itemDetail,
                arguments: items.first);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.dashboard, (route) => false,
                arguments: {'index': 1});
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.dashboard, (route) => false,
              arguments: {'index': 1});
        }
      }
    }

    return InkWell(
      onTap: handleNavigation,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: _buildIconForType(notification.type),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(notification.createdAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // View Button
          const SizedBox(width: 8),
          TextButton(
            onPressed: handleNavigation,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'View',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildIconForType(String type) {
    switch (type) {
      case 'expiring_soon':
        return const Icon(Icons.timer, color: AppColors.yellow, size: 28);
      case 'expired':
        return const Icon(Icons.warning, color: AppColors.red, size: 28);
      case 'achievement':
        return const Icon(Icons.star, color: AppColors.primary, size: 28);
      case 'tip':
        return const Icon(Icons.lightbulb, color: Colors.amber, size: 28);
      case 'invite':
        return const Icon(Icons.group, color: AppColors.primary, size: 28);
      default:
        return const Icon(Icons.notifications, color: Colors.grey, size: 28);
    }
  }
}
