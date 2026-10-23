import 'package:flutter/material.dart';
import 'package:homecycle/core/routes/slide_page_route.dart';
import 'package:homecycle/routes/app_routes.dart';
import 'package:homecycle/features/auth/screens/login_screen.dart';
import 'package:homecycle/features/auth/screens/register_screen.dart';
import 'package:homecycle/features/auth/screens/forgot_password_screen.dart';
import 'package:homecycle/routes/main_wrapper.dart';
import 'package:homecycle/features/gamification/screens/impact_dashboard_screen.dart';
import 'package:homecycle/features/inventory/screens/add_edit_item_screen.dart';
import 'package:homecycle/features/inventory/screens/inventory_screen.dart';
import 'package:homecycle/features/inventory/screens/item_detail_screen.dart';
import 'package:homecycle/features/inventory/models/food_item_model.dart';
import 'package:homecycle/features/notification/screens/notification_screen.dart';
import 'package:homecycle/features/onboarding/screens/onboarding_screen.dart';
import 'package:homecycle/features/profile/screens/language_settings_screen.dart';
import 'package:homecycle/features/profile/screens/profile_screen.dart';
import 'package:homecycle/features/profile/screens/settings_screen.dart';
import 'package:homecycle/features/profile/screens/notification_settings_screen.dart';
import 'package:homecycle/features/profile/screens/household_members_screen.dart';
import 'package:homecycle/features/profile/screens/help_support_screen.dart';
import 'package:homecycle/features/profile/screens/about_screen.dart';
import 'package:homecycle/features/profile/screens/edit_profile_screen.dart';
import 'package:homecycle/features/scan/screens/scan_result_screen.dart';
import 'package:homecycle/features/scan/screens/scan_screen.dart';
import 'package:homecycle/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const SplashScreen());
      case AppRoutes.login:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const LoginScreen());
      case AppRoutes.register:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const RegisterScreen());
      case AppRoutes.forgotPassword:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const ForgotPasswordScreen());
      case AppRoutes.onboarding:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const OnboardingScreen());
      case AppRoutes.dashboard:
        final int index = (settings.arguments as Map<String, dynamic>?)?['index'] as int? ?? 0;
        return SlidePageRouteFactory.withSettings(settings: settings, page: MainWrapper(initialIndex: index));
      case AppRoutes.inventory:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const InventoryScreen());
      case AppRoutes.itemDetail:
        final item = settings.arguments as FoodItemModel;
        return SlidePageRouteFactory.withSettings(settings: settings, page: ItemDetailScreen(item: item));
      case AppRoutes.addEditItem:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const AddEditItemScreen());
      case AppRoutes.scan:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const ScanScreen());
      case AppRoutes.scanResult:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const ScanResultScreen());
      case AppRoutes.notification:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const NotificationScreen());
      case AppRoutes.impactDashboard:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const ImpactDashboardScreen());
      case AppRoutes.profile:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const ProfileScreen());
      case AppRoutes.settings:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const SettingsScreen());
      case AppRoutes.languageSettings:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const LanguageSettingsScreen());
      case AppRoutes.notificationSettings:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const NotificationSettingsScreen());
      case AppRoutes.householdMembers:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const HouseholdMembersScreen());
      case AppRoutes.helpSupport:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const HelpSupportScreen());
      case AppRoutes.about:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const AboutScreen());
      case AppRoutes.editProfile:
        return SlidePageRouteFactory.withSettings(settings: settings, page: const EditProfileScreen());
      default:
        // Supabase OAuth callback route
        if (settings.name != null && settings.name!.contains('login-callback')) {
          return SlidePageRouteFactory.withSettings(
            settings: settings,
            page: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return SlidePageRouteFactory.withSettings(settings: settings, page: const SplashScreen());
    }
  }
}
