import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettitngsScreen extends StatelessWidget {
  const SettitngsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SettitngsScreen.tr())),
      body: const Center(child: Text(SettitngsScreen Placeholder.tr())),
    );
  }
}


