import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_header_card.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_menu_card.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

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
              username: user?.username ?? 'Mate',
              email: user?.email ?? 'No email provided',
              onEditTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
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
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.notificationSettings);
              },
            ),
            Consumer<HouseholdProvider>(
              builder: (context, household, child) {
                final count = household.members.length;
                return ProfileMenuCard(
                  icon: Icons.group_outlined,
                  title: 'Household Members',
                  trailingText: count > 0 ? '$count members' : 'None',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.householdMembers);
                  },
                );
              },
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
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.helpSupport);
              },
            ),
            ProfileMenuCard(
              icon: Icons.info_outline,
              title: 'About HomeCycle',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.about);
              },
            ),

            const SizedBox(height: 32),
            ProfileMenuCard(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                if (authProvider.status != AuthStatus.error && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
