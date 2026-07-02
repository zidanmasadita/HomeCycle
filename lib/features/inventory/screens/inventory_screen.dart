import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('InventoryScreen'.tr())),
      body: Center(child: Text('InventoryScreen Placeholder'.tr())),
    );
  }
}


