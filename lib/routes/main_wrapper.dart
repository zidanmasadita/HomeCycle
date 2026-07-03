import 'package:flutter/material.dart';
import 'package:homesikil/features/dashboard/screens/dashboard_screen.dart';
import 'package:homesikil/features/inventory/screens/inventory_screen.dart';
import 'package:homesikil/features/notification/screens/notification_screen.dart';
import 'package:homesikil/features/recipe_rescue.dart/screens/profile_screen.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/widgets/custom_bottom_navbar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const SizedBox(), // Placeholder for Scan index 2
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Push scan screen instead of switching tab
            Navigator.pushNamed(context, AppRoutes.scan);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
