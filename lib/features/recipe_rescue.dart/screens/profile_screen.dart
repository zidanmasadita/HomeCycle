import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_header_card.dart';
import 'package:homesikil/features/recipe_rescue.dart/widgets/profile_menu_card.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // Force rebuild on locale change
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'profile.title'.tr(),
          style: AppTextStyles.heading.copyWith(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HouseholdProvider>().loadMembers();
          // Add any other user profile reloads here if necessary
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderCard(
              username: user?.username ?? 'Mate',
              email: user?.email ?? 'profile.no_email'.tr(),
              avatarUrl: user?.avatarUrl,
              onEditTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
            ),
            const SizedBox(height: 32),

            Text(
              'profile.general'.tr(),
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ProfileMenuCard(
              icon: Icons.language,
              title: 'profile.language'.tr(),
              trailingText: context.locale.languageCode == 'id' ? 'Indonesian' : 'English (US)',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.languageSettings);
              },
            ),
            ProfileMenuCard(
              icon: Icons.notifications_active_outlined,
              title: 'profile.notification_settings'.tr(),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.notificationSettings);
              },
            ),
            Consumer<HouseholdProvider>(
              builder: (context, household, child) {
                final count = household.members.length;
                return ProfileMenuCard(
                  icon: Icons.group_outlined,
                  title: 'profile.household_members'.tr(),
                  trailingText: count > 0 ? 'profile.members_count'.tr(args: [count.toString()]) : 'profile.none'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.householdMembers);
                  },
                );
              },
            ),

            const SizedBox(height: 24),
            Text(
              'profile.other'.tr(),
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            ProfileMenuCard(
              icon: Icons.help_outline,
              title: 'profile.help_support'.tr(),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.helpSupport);
              },
            ),
            ProfileMenuCard(
              icon: Icons.info_outline,
              title: 'profile.about'.tr(),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.about);
              },
            ),

            const SizedBox(height: 32),
            ProfileMenuCard(
              icon: Icons.logout,
              title: 'profile.logout'.tr(),
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
      ),
    );
  }
}
