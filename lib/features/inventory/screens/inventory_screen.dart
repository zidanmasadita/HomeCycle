import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/inventory/widgets/category_filter_chip.dart';
import 'package:homesikil/features/inventory/widgets/food_item_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<String> categories = ['All', 'Fresh', 'Expire Soon', 'Expired'];
  String selectedCategory = 'All';

  // Mock data for UI layout
  final List<Map<String, dynamic>> items = [
    {
      'name': 'Apple',
      'daysLeft': '2 days left',
      'status': 'Fresh',
      'image': 'assets/images/food-images/apple.png',
      'color': AppColors.success.withValues(alpha: 0.1),
      'textColor': AppColors.success,
    },
    {
      'name': 'Cabbage',
      'daysLeft': '1 day left',
      'status': 'Soon',
      'image': 'assets/images/food-images/cabbage.png',
      'color': AppColors.yellow.withValues(alpha: 0.1),
      'textColor': AppColors.yellow,
    },
    {
      'name': 'Lettuce',
      'daysLeft': 'Expired',
      'status': 'Expired',
      'image': 'assets/images/food-images/lettuce.png',
      'color': AppColors.red.withValues(alpha: 0.1),
      'textColor': AppColors.red,
      'subtitleColor': AppColors.red,
    },
    {
      'name': 'Carrot',
      'daysLeft': '4 days left',
      'status': 'Fresh',
      'image': 'assets/images/food-images/carrot.png',
      'color': AppColors.success.withValues(alpha: 0.1),
      'textColor': AppColors.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLarge,
                vertical: AppDimens.paddingMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'My Inventory',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLarge,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search food...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimens.paddingMedium),

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLarge,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return CategoryFilterChip(
                    label: category,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimens.paddingMedium),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLarge,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return FoodItemCard(item: item);
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
