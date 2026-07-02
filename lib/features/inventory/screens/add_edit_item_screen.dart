import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddEditItemScreen extends StatelessWidget {
  const AddEditItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AddEditItemScreen'.tr())),
      body: Center(child: Text('AddEditItemScreen Placeholder'.tr())),
    );
  }
}


