import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:homecycle/core/constants/app_colors.dart';

/// Jenis respons untuk menentukan icon/warna.
enum ResponseType { success, error, info }

/// Helper untuk menampilkan balasan / respons dari sistem (Dialog & Toast custom).
class CustomResponse {
  CustomResponse._();

  /// Global navigator key to allow showing response from anywhere without context.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Menampilkan popup dialog di tengah layar (Card UI).
  ///
  /// [type] menentukan icon/Lottie dan warna tema.
  static void showDialogResponse({
    BuildContext? context,
    required ResponseType type,
    required String title,
    required String message,
    String? customLottiePath,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    final ctx = context ?? navigatorKey.currentContext!;
    showDialog(
      context: ctx,
      barrierDismissible: false, // User harus klik tombol untuk menutup
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon atau Lottie
                _buildDialogIcon(type, customLottiePath),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  title,
                  style: AppTextStyles.title2Bold.copyWith(
                    color: _getColor(type),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  message,
                  style: AppTextStyles.body2Regular.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getColor(type),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (onConfirm != null) onConfirm();
                    },
                    child: Text(
                      confirmText,
                      style: AppTextStyles.body1Bold.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan custom Toast melayang (menggunakan Overlay).
  ///
  /// Bisa muncul di atas UI apapun karena menggunakan Overlay framework.
  static void showToast({
    BuildContext? context,
    required ResponseType type,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = context ?? navigatorKey.currentContext!;
    final overlayState = Overlay.of(ctx);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 20, // Muncul dari atas
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border(
                    left: BorderSide(
                      color: _getColor(type),
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(type),
                      color: _getColor(type),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: AppTextStyles.body2Medium.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Hilangkan toast setelah durasi habis
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // ─── Helpers Internal ────────────────────────────────────────────────────────

  static Color _getColor(ResponseType type) {
    switch (type) {
      case ResponseType.success:
        return Colors.green.shade600;
      case ResponseType.error:
        return Colors.red.shade600;
      case ResponseType.info:
        return AppColors.primary;
    }
  }

  static IconData _getIconData(ResponseType type) {
    switch (type) {
      case ResponseType.success:
        return Icons.check_circle_rounded;
      case ResponseType.error:
        return Icons.error_rounded;
      case ResponseType.info:
        return Icons.info_rounded;
    }
  }

  static Widget _buildDialogIcon(ResponseType type, String? customLottiePath) {
    // Kalau ada lottie spesifik yang dipassing
    if (customLottiePath != null) {
      return Lottie.asset(customLottiePath, width: 120, height: 120, repeat: false);
    }

    // Default Lottie untuk success
    if (type == ResponseType.success) {
      return Lottie.asset('assets/images/icons/Success.json', width: 120, height: 120, repeat: false);
    }

    // Default Lottie untuk error
    if (type == ResponseType.error) {
      return Lottie.asset('assets/images/icons/Error animation.json', width: 120, height: 120, repeat: false);
    }

    // Fallback pakai Icon biasa
    return Icon(
      _getIconData(type),
      color: _getColor(type),
      size: 80,
    );
  }
}
