import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(LanguageSettingsScreen.tr())),
      body: const Center(child: Text(LanguageSettingsScreen Placeholder.tr())),
    );
  }
}


