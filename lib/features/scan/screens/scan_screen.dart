import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ScanScreen'.tr())),
      body: Center(child: Text('ScanScreen Placeholder'.tr())),
    );
  }
}


