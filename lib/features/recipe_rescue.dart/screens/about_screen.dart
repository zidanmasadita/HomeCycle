import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'profile.about'.tr(),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(AppAssets.mascot1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'HomeCycle',
              style: AppTextStyles.heading.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'profile.version'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            Text(
              'profile.our_mission'.tr(),
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'profile.mission_desc'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('profile.terms'.tr(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                Text(' | ', style: TextStyle(color: Colors.grey.shade400)),
                TextButton(
                  onPressed: () {},
                  child: Text('profile.privacy'.tr(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '© 2026 HomeCycle Inc.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
