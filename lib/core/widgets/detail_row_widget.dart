import 'package:flutter/material.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';

/// Widget reusable untuk menampilkan baris detail informasi (Icon, Label, dan Value/Trailing).
///
/// Contoh Penggunaan:
/// ```dart
/// DetailRowWidget(
///   icon: Icons.calendar_today,
///   label: 'Estimated Expiry',
///   value: '7 Days',
/// )
/// ```
class DetailRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  
  /// Nilai teks yang akan ditampilkan di kanan.
  /// Jika [trailing] diisi, maka [value] tidak akan ditampilkan.
  final String value;
  
  /// Warna icon dan background bulat icon (jika [hasIconBackground] true).
  /// Secara default akan menggunakan [AppColors.primary].
  final Color? color;
  
  /// Widget custom untuk menggantikan teks [value] di sebelah kanan.
  final Widget? trailing;
  
  /// Menambahkan jarak di luar baris. Berguna jika ingin ada margin bottom.
  final EdgeInsetsGeometry? padding;
  
  /// Menentukan apakah icon memiliki background bulat berwarna.
  /// Gaya dengan background bulat ini dipakai di ScanResultScreen.
  final bool hasIconBackground;

  const DetailRowWidget({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.color,
    this.trailing,
    this.padding,
    this.hasIconBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    
    Widget content = Row(
      children: [
        // ── Icon Container ──
        if (hasIconBackground)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveColor, size: 20),
          )
        else
          Icon(icon, color: Colors.black54, size: 24),

        SizedBox(width: hasIconBackground ? 12 : 16),
        
        // ── Label ──
        Text(
          label,
          style: AppTextStyles.body2Medium.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        
        const Spacer(),
        
        // ── Value / Trailing ──
        trailing ??
            Text(
              value,
              style: AppTextStyles.body1Bold.copyWith(
                color: Colors.black87,
              ),
            ),
      ],
    );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }
}
