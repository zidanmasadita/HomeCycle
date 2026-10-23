import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:homecycle/core/constants/app_colors.dart';

/// Screen untuk menampilkan animasi sukses menggunakan Lottie.
///
/// Biasanya digunakan setelah sebuah form atau aksi berhasil (misal: tambah barang, registrasi),
/// kemudian otomatis akan redirect (pop) atau memanggil [onComplete] setelah [durationInSeconds].
class SuccessAnimationScreen extends StatefulWidget {
  /// Judul utama
  final String title;

  /// Teks subjudul penjelasan
  final String subtitle;

  /// Durasi hitung mundur sebelum pindah/kembali (dalam detik).
  final int durationInSeconds;

  /// Teks hitung mundur, gunakan '{time}' sebagai placeholder untuk angkanya.
  /// Contoh: 'Akan diarahkan kembali dalam {time} detik'
  final String redirectMessageTemplate;

  /// Callback jika tidak ingin Navigator.pop(context), melainkan navigasi custom.
  final VoidCallback? onComplete;

  const SuccessAnimationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.durationInSeconds = 3,
    this.redirectMessageTemplate = 'Akan diarahkan kembali ke halaman dalam {time} detik',
    this.onComplete,
  });

  @override
  State<SuccessAnimationScreen> createState() => _SuccessAnimationScreenState();
}

class _SuccessAnimationScreenState extends State<SuccessAnimationScreen> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.durationInSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_timeLeft > 1) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/icons/Success.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: AppTextStyles.title1Bold.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.body1Regular.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48), // Gap agak jauh
                Text(
                  widget.redirectMessageTemplate.replaceAll(
                    '{time}',
                    '$_timeLeft',
                  ),
                  style: AppTextStyles.label1Regular.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
