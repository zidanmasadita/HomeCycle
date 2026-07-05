import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/dashboard/widgets/quick_stats_card.dart';
import 'package:homesikil/features/dashboard/widgets/expiring_soon_card.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/features/notification/provider/notification_provider.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final username = auth.currentUser?.username ?? 'Mate';
    final expiringItems = inventoryProvider.expiringSoonItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.logo,
                          height: 26,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.eco,
                                color: AppColors.primary,
                                size: 26,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HomeCycle',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, child) {
                            if (notificationProvider.unreadCount > 0) {
                              return Badge(
                                label: Text(
                                  notificationProvider.unreadCount.toString(),
                                ),
                                backgroundColor: AppColors.red,
                                child: const Icon(
                                  Icons.notifications_none,
                                  color: AppColors.primary,
                                ),
                              );
                            }
                            return const Icon(
                              Icons.notifications_none,
                              color: AppColors.primary,
                            );
                          },
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.notification);
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 100.0,
                          bottom: 25.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 32,
                                color: Colors.black87,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              username,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 28,
                                color: AppColors.primary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's save more food today",
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stats Grid
                      const QuickStatsCard(),
                    ],
                  ),
                  Positioned(
                    right: -5,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow Layer
                        Transform.translate(
                          offset: const Offset(0, 2),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 2),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.srcATop,
                              ),
                              child: Image.asset(
                                AppAssets.mascot1,
                                height: 160,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        // Actual Mascot
                        Image.asset(
                          AppAssets.mascot1,
                          height: 160,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(height: 160, width: 120),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Expiring Soon Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiring Soon',
                      style: AppTextStyles.title.copyWith(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.dashboard,
                          arguments: {'index': 1},
                        );
                      },
                      child: Text(
                        'See All',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expiring Soon List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: expiringItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Nothing expiring soon! Great job!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: expiringItems.map((item) {
                          final category = categoryProvider.findById(
                            item.categoryId,
                          );
                          return ExpiringSoonCard(
                            item: item,
                            category: category,
                            title:
                                item.customName ??
                                category?.name ??
                                'Unknown Item',
                            daysLeft: '${item.daysUntilExpiration} Days Left',
                            badgeColor: item.daysUntilExpiration == 0
                                ? Colors.red
                                : AppColors.yellow,
                            badgeText: item.daysUntilExpiration == 0
                                ? 'Today'
                                : 'Soon',
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
