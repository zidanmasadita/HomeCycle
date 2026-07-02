import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ScanResultScreen.tr())),
      body: const Center(child: Text(ScanResultScreen Placeholder.tr())),
    );
  }
}


