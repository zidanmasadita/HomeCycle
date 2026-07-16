import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/features/inventory/widgets/category_filter_chip.dart';
import 'package:homesikil/features/inventory/widgets/food_item_card.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<String> categories = ['All', 'Fresh', 'Expire Soon', 'Expired'];
  String selectedCategory = 'All';
  String _searchQuery = '';
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    context.locale; // Force rebuild on locale change
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
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
                      'inventory.my_inventory'.tr(),
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
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          iconSize: 20,
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            FocusScope.of(context).unfocus();
                          },
                        ) 
                      : null,
                    hintText: 'inventory.search_food'.tr(),
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
                  String displayCategory = category;
                  if (category == 'All') displayCategory = 'inventory.filter_all'.tr();
                  else if (category == 'Fresh') displayCategory = 'inventory.filter_fresh'.tr();
                  else if (category == 'Expire Soon') displayCategory = 'inventory.filter_expire_soon'.tr();
                  else if (category == 'Expired') displayCategory = 'inventory.filter_expired'.tr();

                  return CategoryFilterChip(
                    label: displayCategory,
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

                  if (_searchQuery.isNotEmpty) {
                    displayList = displayList.where((item) {
                      final customNameMatch = item.customName?.toLowerCase().contains(_searchQuery) ?? false;
                      
                      // Find category name safely
                      String catName = '';
                      try {
                        final cat = categories.categories.firstWhere((c) => c.id == item.categoryId);
                        catName = cat.name.toLowerCase();
                      } catch (_) {}
                      
                      return customNameMatch || catName.contains(_searchQuery);
                    }).toList();
                  }

                  if (inventory.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (displayList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<InventoryProvider>().loadInventory();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Text('inventory.empty_category'.tr()),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<InventoryProvider>().loadInventory();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: AppDimens.paddingLarge,
                        right: AppDimens.paddingLarge,
                        bottom: 80,
                      ),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        final category = categories.findById(item.categoryId);
                        return FoodItemCard(item: item, category: category);
                      },
                    ),
                  );
                  },
                ),
              ),
            ],
        ),
      ),
    );
  }
}
