import 'package:flutter/material.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:homesikil/features/inventory/provider/inventory_provider.dart';
import 'package:homesikil/features/gamification/provider/gamification_provider.dart';
import 'package:homesikil/features/category/provider/category_provider.dart';
import 'package:homesikil/features/notification/provider/notification_provider.dart';
import 'package:homesikil/features/profile/provider/profile_provider.dart';
import 'package:homesikil/features/household/provider/household_provider.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      // Fetch dynamic data before routing
      await Future.wait([
        context.read<InventoryProvider>().loadInventory(),
        context.read<GamificationProvider>().loadImpactStats(),
        context.read<CategoryProvider>().loadCategories(),
        context.read<NotificationProvider>().loadNotifications(),
        context.read<ProfileProvider>().loadPreferences(),
        context.read<HouseholdProvider>().loadMembers(),
      ]);

      if (!mounted) return;

      if (hasSeenOnboarding) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

