import 'package:flutter/material.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/auth/screens/login_screen.dart';
import 'package:homesikil/features/auth/screens/register_screen.dart';
import 'package:homesikil/routes/main_wrapper.dart';
import 'package:homesikil/features/gamification/screens/impact_dashboard_screen.dart';
import 'package:homesikil/features/inventory/screens/add_edit_item_screen.dart';
import 'package:homesikil/features/inventory/screens/inventory_screen.dart';
import 'package:homesikil/features/inventory/screens/item_detail_screen.dart';
import 'package:homesikil/features/notification/screens/notification_screen.dart';
import 'package:homesikil/features/onboarding/screens/onboarding_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/language_settings_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/profile_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/settings_screen.dart';
import 'package:homesikil/features/scan/screens/scan_result_screen.dart';
import 'package:homesikil/features/scan/screens/scan_screen.dart';
import 'package:homesikil/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const MainWrapper());
      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case AppRoutes.itemDetail:
        return MaterialPageRoute(builder: (_) => const ItemDetailScreen());
      case AppRoutes.addEditItem:
        return MaterialPageRoute(builder: (_) => const AddEditItemScreen());
      case AppRoutes.scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case AppRoutes.scanResult:
        return MaterialPageRoute(builder: (_) => const ScanResultScreen());
      case AppRoutes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case AppRoutes.impactDashboard:
        return MaterialPageRoute(builder: (_) => const ImpactDashboardScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.languageSettings:
        return MaterialPageRoute(builder: (_) => const LanguageSettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
