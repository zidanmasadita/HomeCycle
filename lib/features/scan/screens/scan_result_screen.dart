import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/core/utils/app_snackbar.dart';
import 'package:homesikil/features/scan/provider/scan_provider.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:uuid/uuid.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  double _quantity = 1.0;

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final result = scanProvider.lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Result'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(scanProvider.errorMessage ?? "No result found"),
        ),
      );
    }

    final confidencePercent = (result.confidenceScore * 100).toStringAsFixed(0);
    final rawName = result.detectedLabel;
    final capitalizedName = rawName.isNotEmpty
        ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
        : rawName;

    final expirationDays = 7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Scan Result', style: AppTextStyles.heading),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanned Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: result.imageBytes != null
                          ? Image.memory(
                              result.imageBytes!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/food-images/apple.png',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Result Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.restaurant,
                          'Food Name',
                          capitalizedName,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.eco,
                          'Freshness',
                          'Fresh ($confidencePercent%)',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Estimated Expiry',
                          '$expirationDays Days',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.shopping_basket,
                          'Quantity',
                          '',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_quantity.toInt()} Pcs',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () {
                                  setState(() => _quantity++);
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.category, 'Category', 'Detected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pinned Buttons at bottom
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: scanProvider.isLoading
                          ? null
                          : () async {
                              final user = context
                                  .read<AuthProvider>()
                                  .currentUser;
                              final adminId = context
                                  .read<HouseholdProvider>()
                                  .adminId;
                              final ownerId = adminId ?? user?.id;
                              if (ownerId == null) return;

                              final categories = context
                                  .read<CategoryProvider>()
                                  .categories;
                              final fallbackCategoryId = categories.isNotEmpty
                                  ? categories.first.id
                                  : '';

                              final item = FoodItemModel(
                                id: Uuid().v4(),
                                userId: ownerId,
                                categoryId:
                                    result.categoryId ?? fallbackCategoryId,
                                customName: capitalizedName,
                                condition: 'fresh',
                                confidenceScore: result.confidenceScore,
                                quantity: _quantity,
                                unit: 'pcs',
                                storageLocation: 'fridge',
                                scannedAt: DateTime.now(),
                                estimatedExpiredDate: DateTime.now().add(
                                  Duration(days: expirationDays),
                                ),
                                actualStatus: 'active',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              final success = await context
                                  .read<ScanProvider>()
                                  .confirmAndSave(
                                    item: item,
                                    adminId: ownerId,
                                  );

                              if (success && context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.dashboard,
                                  (route) => false,
                                  arguments: {'index': 1},
                                );
                                AppSnackbar.showSuccess(
                                  'Item saved to inventory!',
                                );
                              } else if (context.mounted) {
                                AppSnackbar.showError(
                                  scanProvider.errorMessage ??
                                      'Failed to save item',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: scanProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save to Inventory',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Redirect back to scan screen
                        Navigator.pushReplacementNamed(context, AppRoutes.scan);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Scan Again',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
        ),
        const Spacer(),
        trailing ??
            Text(
              value,
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
      ],
    );
  }
}
