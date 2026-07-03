import 'package:flutter/material.dart';

class ExpiryBadge extends StatelessWidget {
  final String status;
  final Color backgroundColor;
  final Color textColor;
  final double paddingHorizontal;
  final double fontSize;

  const ExpiryBadge({
    super.key,
    required this.status,
    required this.backgroundColor,
    required this.textColor,
    this.paddingHorizontal = 12,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
