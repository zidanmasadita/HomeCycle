import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';


import 'data/remote/supabase_service.dart';
import 'data/remote/tflite_service.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'core/theme/app_theme.dart';

// Repositories
import 'features/auth/repository/auth_repository.dart';
import 'features/category/repository/category_repository.dart';
import 'features/inventory/repository/inventory_repository.dart';
import 'features/consumption/repository/consumption_repository.dart';
import 'features/scan/repository/scan_repository.dart';
import 'features/notification/repository/notification_repository.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/gamification/repository/gamification_repository.dart';
import 'features/profile/repository/profile_repository.dart';

// Providers
import 'features/auth/provider/auth_provider.dart';
import 'features/category/provider/category_provider.dart';
import 'features/inventory/provider/inventory_provider.dart';
import 'features/consumption/provider/consumption_provider.dart';
import 'features/scan/provider/scan_provider.dart';
import 'features/notification/provider/notification_provider.dart';
import 'features/dashboard/provider/dashboard_provider.dart';
import 'features/gamification/provider/gamification_provider.dart';
import 'features/profile/provider/profile_provider.dart';

import 'package:homesikil/core/utils/app_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('id'),
      child: const HomeCycleApp(),
    ),
  );
}

class HomeCycleApp extends StatelessWidget {
  const HomeCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Independent Providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(CategoryRepository())..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(InventoryRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsumptionProvider(ConsumptionRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(NotificationRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => GamificationProvider(GamificationRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(ProfileRepository()),
        ),
        
        // Dependent Providers
        ChangeNotifierProxyProvider2<CategoryProvider, InventoryProvider, ScanProvider>(
          create: (context) => ScanProvider(
            repository: ScanRepository(),
            tfLiteService: TFLiteService(),
            categoryProvider: context.read<CategoryProvider>(),
            inventoryProvider: context.read<InventoryProvider>(),
          ),
          update: (context, category, inventory, previous) {
            return previous ?? ScanProvider(
              repository: ScanRepository(),
              tfLiteService: TFLiteService(),
              categoryProvider: category,
              inventoryProvider: inventory,
            );
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'HomeCycle',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: AppSnackbar.messengerKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }
}
