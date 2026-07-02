import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ImpactDashboardScreen extends StatelessWidget {
  const ImpactDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ImpactDashboardScreen'.tr())),
      body: Center(child: Text('ImpactDashboardScreen Placeholder'.tr())),
    );
  }
}


