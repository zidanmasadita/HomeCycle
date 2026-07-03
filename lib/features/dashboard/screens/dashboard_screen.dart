import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/features/dashboard/widgets/quick_stats_card.dart';
import 'package:homesikil/features/dashboard/widgets/expiring_soon_card.dart';
import 'package:homesikil/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.logo,
                          height: 26,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.eco, color: AppColors.primary, size: 26),
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
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, color: AppColors.primary),
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
                      // Welcome Section (Text only)
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 100.0, bottom: 25.0),
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
                              'Zidan Masadita',
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiring Soon',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    ExpiringSoonCard(
                      title: 'Banana',
                      daysLeft: '2 Days Left',
                      imagePath: AppAssets.banana, 
                    ),
                    ExpiringSoonCard(
                      title: 'Apple',
                      daysLeft: '1 Days Left',
                      imagePath: AppAssets.apple, 
                    ),
                  ],
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

