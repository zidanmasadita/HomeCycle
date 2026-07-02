import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ItemDetailScreen'.tr())),
      body: Center(child: Text('ItemDetailScreen Placeholder'.tr())),
    );
  }
}


