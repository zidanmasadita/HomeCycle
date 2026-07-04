import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/inventory/widgets/category_filter_chip.dart';
import 'package:homesikil/features/inventory/widgets/food_item_card.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:provider/provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<String> categories = ['All', 'Fresh', 'Expire Soon', 'Expired'];
  String selectedCategory = 'All';



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
              child: Consumer2<InventoryProvider, CategoryProvider>(
                builder: (context, inventory, categories, _) {
                  var displayList = inventory.inventory;
                  
                  if (selectedCategory == 'Fresh') {
                    displayList = inventory.activeItems.where((i) => !i.isExpiringSoon && !i.isExpired).toList();
                  } else if (selectedCategory == 'Expire Soon') {
                    displayList = inventory.expiringSoonItems;
                  } else if (selectedCategory == 'Expired') {
                    displayList = inventory.expiredItems;
                  }

                  if (inventory.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (displayList.isEmpty) {
                    return const Center(
                      child: Text('Your inventory is empty in this category!'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingLarge,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final category = categories.findById(item.categoryId);
                      return FoodItemCard(item: item, category: category);
                    },
                  );
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
