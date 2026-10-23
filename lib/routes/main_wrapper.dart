import 'package:flutter/material.dart';
import 'package:homecycle/features/dashboard/screens/dashboard_screen.dart';
import 'package:homecycle/features/inventory/screens/inventory_screen.dart';
import 'package:homecycle/features/gamification/screens/impact_dashboard_screen.dart';
import 'package:homecycle/features/profile/screens/profile_screen.dart';
import 'package:homecycle/routes/app_routes.dart';
import 'package:homecycle/widgets/custom_bottom_navbar.dart';

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  const MainWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(),
      InventoryScreen(),
      const SizedBox(),
      ImpactDashboardScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
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
