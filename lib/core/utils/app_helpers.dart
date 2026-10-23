// ─── app_helpers.dart ─────────────────────────────────────────────────────────
// Satu file pusat berisi semua helper/utilitas yang bisa dipakai ulang di mana
// saja di dalam aplikasi HomeSikil.
//
// Cara import di file lain:
//   import 'package:homecycle/core/utils/app_helpers.dart';
//
// Kemudian panggil langsung:
//   AppHelpers.formatDate(someDateTime)
//   AppHelpers.formatCurrency(15000)
//   AppHelpers.capitalize('hello world') // → 'Hello World'
// ──────────────────────────────────────────────────────────────────────────────

library app_helpers;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:homecycle/core/utils/custom_response.dart';

export 'package:homecycle/core/utils/custom_response.dart';
export 'package:homecycle/core/utils/validators.dart';
export 'package:homecycle/core/utils/action_throttler.dart';
export 'package:homecycle/core/utils/impact_calculator.dart';
export 'package:homecycle/core/utils/unit_converter.dart';
export 'package:homecycle/core/utils/local_notification_helper.dart';

// ─── AppHelpers ───────────────────────────────────────────────────────────────
class AppHelpers {
  AppHelpers._();

  // ── Toast shortcuts (menggunakan CustomResponse) ──────────────────
  
  /// Tampilkan toast sukses (hijau).
  /// Tidak membutuhkan [BuildContext] — cukup panggil di mana saja.
  static void showSuccess(String message) {
    CustomResponse.showToast(type: ResponseType.success, message: message);
  }

  /// Tampilkan toast error (merah).
  static void showError(String message) {
    CustomResponse.showToast(type: ResponseType.error, message: message);
  }

  /// Tampilkan toast info (warna primer).
  static void showInfo(String message) {
    CustomResponse.showToast(type: ResponseType.info, message: message);
  }

  // ── Date Helpers ───────────────────────────────────────────────────────────

  static final _dateFormatter  = DateFormat('dd MMM yyyy', 'id_ID');
  static final _timeFormatter  = DateFormat('HH:mm', 'id_ID');
  static final _fullFormatter  = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  /// Format [date] menjadi "14 Jan 2025".
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Format [date] menjadi "09:30".
  static String formatTime(DateTime date) => _timeFormatter.format(date);

  /// Format [date] menjadi "14 Jan 2025, 09:30".
  static String formatDateTime(DateTime date) => _fullFormatter.format(date);

  /// Mengembalikan selisih hari antara [date] dan hari ini.
  /// Nilai positif = hari ini lebih awal (belum kedaluwarsa).
  /// Nilai negatif = sudah kedaluwarsa.
  static int daysUntil(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  /// Mengembalikan teks relatif seperti "2 hari lagi", "Hari ini", "1 hari lalu".
  static String relativeDay(DateTime date) {
    final diff = daysUntil(date);
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return '1 hari lalu';
    if (diff > 0) return '$diff hari lagi';
    return '${diff.abs()} hari lalu';
  }

  // ── Currency Helpers ───────────────────────────────────────────────────────

  /// Format angka ke format rupiah: "Rp 15.000".
  static String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format angka besar ke format singkat: 1500 → "1,5 rb", 2000000 → "2 jt".
  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)} jt';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)} rb';
    }
    return amount.toString();
  }

  // ── String Helpers ─────────────────────────────────────────────────────────

  /// Kapitalisasi setiap kata: "hello world" → "Hello World".
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Singkat teks jika melebihi [maxLength] karakter, diakhiri "...".
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Mengembalikan inisial dari nama: "Zidan Masadita" → "ZM".
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ── Navigation Helpers ─────────────────────────────────────────────────────

  /// Pop halaman jika bisa, atau tutup tanpa error.
  static void safeBack(BuildContext context, {dynamic result}) {
    if (Navigator.canPop(context)) Navigator.pop(context, result);
  }

  // ── Validation Helpers (wrapper agar bisa diakses via AppHelpers) ───────────
  // Validator lengkap tersedia dari validators.dart yang di-export di atas.
  // Contoh: import 'app_helpers.dart'; lalu pakai validateEmail(...)

  // ── Misc Helpers ───────────────────────────────────────────────────────────

  /// Delay non-blocking: await AppHelpers.delay(milliseconds: 300);
  static Future<void> delay({int milliseconds = 300}) =>
      Future.delayed(Duration(milliseconds: milliseconds));

  /// Cek apakah string adalah URL yang valid.
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}
