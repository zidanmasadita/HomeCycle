import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              question,
              style: AppTextStyles.title.copyWith(fontSize: 15),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: Colors.grey.shade400,
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            expandedAlignment: Alignment.topLeft,
            children: [
              Text(
                answer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
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
          'profile.help_support'.tr(),
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
              'profile.contact_us'.tr(),
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.email_support'.tr(),
                        style: AppTextStyles.title,
                      ),
                      Text(
                        'masadita20@gmail.com',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'profile.faq'.tr(),
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              context,
              'profile.faq_1_q'.tr(),
              'profile.faq_1_a'.tr(),
            ),
            _buildFaqItem(
              context,
              'profile.faq_2_q'.tr(),
              'profile.faq_2_a'.tr(),
            ),
            _buildFaqItem(
              context,
              'profile.faq_3_q'.tr(),
              'profile.faq_3_a'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
