import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final List<Map<String, String>> languages = [
    {'name': 'English (US)', 'code': 'en'},
    {'name': 'Indonesian', 'code': 'id'},
  ];

  Widget _buildLanguageCard(String languageName, String languageCode) {
    final provider = context.watch<ProfileProvider>();
    final currentCode = provider.preferences?.preferredLanguage ?? 'id';
    final isSelected = currentCode == languageCode;

    return GestureDetector(
      onTap: () async {
        await context.read<ProfileProvider>().updateLanguage(languageCode);
        if (context.mounted) {
          await context.setLocale(Locale(languageCode));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageName,
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

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
          'profile.language'.tr(),
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
              'profile.select_language'.tr(),
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => _buildLanguageCard(lang['name']!, lang['code']!)),
          ],
        ),
      ),
    );
  }
}
