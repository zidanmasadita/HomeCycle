import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NotificationScreen'.tr())),
      body: Center(child: Text('NotificationScreen Placeholder'.tr())),
    );
  }
}


