import 'package:flutter/material.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/notification/widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final List<Map<String, dynamic>> todayNotifications = [
      {
        'title': 'Apple expires tomorrow',
        'date': 'Today, 09:00 AM',
        'image': 'assets/images/food-images/apple.png',
        'isUnread': true,
      },
    ];

    final List<Map<String, dynamic>> earlierNotifications = [
      {
        'title': 'Cabbage expired yesterday',
        'date': 'Yesterday, 08:30 AM',
        'image': 'assets/images/food-images/cabbage.png',
        'isUnread': false,
      },
      {
        'title': 'Carrot expires in 3 days',
        'date': '2 days ago',
        'image': 'assets/images/food-images/carrot.png',
        'isUnread': false,
      },
    ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        ),
      ),
    );
  }
}
