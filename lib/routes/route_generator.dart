import 'package:flutter/material.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/features/auth/screens/login_screen.dart';
import 'package:homesikil/features/auth/screens/register_screen.dart';
import 'package:homesikil/features/auth/screens/forgot_password_screen.dart';
import 'package:homesikil/routes/main_wrapper.dart';
import 'package:homesikil/features/gamification/screens/impact_dashboard_screen.dart';
import 'package:homesikil/features/inventory/screens/add_edit_item_screen.dart';
import 'package:homesikil/features/inventory/screens/inventory_screen.dart';
import 'package:homesikil/features/inventory/screens/item_detail_screen.dart';
import 'package:homesikil/features/inventory/models/food_item_model.dart';
import 'package:homesikil/features/notification/screens/notification_screen.dart';
import 'package:homesikil/features/onboarding/screens/onboarding_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/language_settings_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/profile_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/settings_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/notification_settings_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/household_members_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/help_support_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/about_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/edit_profile_screen.dart';
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
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.dashboard:
        final int index = (settings.arguments as Map<String, dynamic>?)?['index'] as int? ?? 0;
        return MaterialPageRoute(builder: (_) => MainWrapper(initialIndex: index));
      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case AppRoutes.itemDetail:
        final item = settings.arguments as FoodItemModel;
        return MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item));
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
      case AppRoutes.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case AppRoutes.householdMembers:
        return MaterialPageRoute(builder: (_) => const HouseholdMembersScreen());
      case AppRoutes.helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        // Supabase OAuth callback route
        if (settings.name != null && settings.name!.contains('login-callback')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
