import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OnboardingScreen'.tr())),
      body: Center(child: Text('OnboardingScreen Placeholder'.tr())),
    );
  }
}


