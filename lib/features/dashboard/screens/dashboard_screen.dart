import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(DashboardScreen.tr())),
      body: const Center(child: Text(DashboardScreen Placeholder.tr())),
    );
  }
}


