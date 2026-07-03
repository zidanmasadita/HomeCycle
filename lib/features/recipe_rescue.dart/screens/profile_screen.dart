import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_header_card.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_menu_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
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
            ProfileHeaderCard(
              username: 'Zidan Masadita',
              email: 'zidan@example.com',
              onEditTap: () {},
            ),
            const SizedBox(height: 32),

            Text(
              'General',
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ProfileMenuCard(
              icon: Icons.language,
              title: 'Language',
              trailingText: 'English (US)',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.languageSettings);
              },
            ),
            ProfileMenuCard(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications Setting',
              onTap: () {},
            ),
            ProfileMenuCard(
              icon: Icons.group_outlined,
              title: 'Household Members',
              onTap: () {},
            ),

            const SizedBox(height: 24),
            Text(
              'Other',
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ProfileMenuCard(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            ProfileMenuCard(
              icon: Icons.info_outline,
              title: 'About HomeCycle',
              onTap: () {},
            ),

            const SizedBox(height: 32),
            ProfileMenuCard(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
