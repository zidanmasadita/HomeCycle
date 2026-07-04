import 'package:flutter/material.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/notification/widgets/notification_card.dart';
import 'package:homesikil/features/notification/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.status == NotificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayNotifications = notificationProvider.todayNotifications;
          final earlierNotifications = notificationProvider.earlierNotifications;

          if (todayNotifications.isEmpty && earlierNotifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications right now.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todayNotifications.isNotEmpty) ...[
                  Text(
                    'Today',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...todayNotifications.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NotificationCard(notification: notification),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
                if (earlierNotifications.isNotEmpty) ...[
                  Text(
                    'Earlier',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...earlierNotifications.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NotificationCard(notification: notification),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
