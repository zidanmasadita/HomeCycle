import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:homecycle/features/scan/models/scan_crop.dart';

/// Bingkai pemandu pada layar pindai — lapis pencegahan untuk mitigasi
/// kondisi nyata (pertanyaan penguji no. 3).
///
/// Kotak persegi menunjukkan persis area yang diproses model pada
/// jalur live: persegi tengah frame sebesar ScanCrop.liveFraction
/// (lihat scan_crop.dart). Ukurannya dihitung dari ukuran pratinjau
/// kamera dengan skala cover-fit yang sama seperti yang dipakai
/// CameraPreview, dan diletakkan di tengah frame — bukan perkiraan
/// kasar dari ukuran layar. Instruksi di bawah bingkai mengajak
/// pengguna memenuhi bingkai dengan objek, tidak menutupi objek
/// dengan tangan/benda lain, dan memastikan cahaya cukup — tiga hal
/// yang terbukti paling memengaruhi ketepatan hasil pindai.
class ScanFrameOverlay extends StatelessWidget {
  const ScanFrameOverlay({super.key, this.uprightPreviewSize});

  /// Ukuran pratinjau kamera dalam orientasi tegak (lebar x tinggi).
  /// Null bila belum diketahui; ukuran kotak kembali ke perkiraan lama.
  final Size? uprightPreviewSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = _frameSide(size);
    final frameCenterY = size.height / 2;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanFramePainter(
                frameSize: frameSize,
                frameCenterY: frameCenterY,
              ),
            ),
          ),
          Positioned(
            top: frameCenterY + frameSize / 2 + 16,
            left: 32,
            right: 32,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'scan.guide_instruction'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2Regular.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sisi kotak (piksel logis) untuk wilayah crop live: fraksi crop
  /// dari sisi terpendek frame, diskalakan dengan skala cover-fit
  /// pratinjau terhadap layar.
  double _frameSide(Size screen) {
    final preview = uprightPreviewSize;
    if (preview == null || preview.width <= 0 || preview.height <= 0) {
      return screen.width * 0.78;
    }
    final scale = math.max(
      screen.width / preview.width,
      screen.height / preview.height,
    );
    final cropPx = ScanCrop.liveFraction * math.min(preview.width, preview.height);
    return cropPx * scale;
  }
}

class _ScanFramePainter extends CustomPainter {
  final double frameSize;
  final double frameCenterY;

  const _ScanFramePainter({required this.frameSize, required this.frameCenterY});

  @override
  void paint(Canvas canvas, Size size) {
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, frameCenterY),
      width: frameSize,
      height: frameSize,
    );
    final frameRRect = RRect.fromRectAndRadius(
      frameRect,
      const Radius.circular(20),
    );

    // Redupkan area di luar bingkai.
    final scrimPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(frameRRect);
    scrimPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(
      scrimPath,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    // Garis bingkai.
    canvas.drawRRect(
      frameRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Aksen sudut.
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const cornerLen = 26.0;
    final corners = <(Offset, Offset, Offset)>[
      (
        frameRect.topLeft + const Offset(-4, cornerLen),
        frameRect.topLeft + const Offset(-4, -4),
        frameRect.topLeft + const Offset(cornerLen, -4),
      ),
      (
        frameRect.topRight + const Offset(-cornerLen, -4),
        frameRect.topRight + const Offset(4, -4),
        frameRect.topRight + const Offset(4, cornerLen),
      ),
      (
        frameRect.bottomRight + const Offset(4, -cornerLen),
        frameRect.bottomRight + const Offset(4, 4),
        frameRect.bottomRight + const Offset(-cornerLen, 4),
      ),
      (
        frameRect.bottomLeft + const Offset(cornerLen, 4),
        frameRect.bottomLeft + const Offset(-4, 4),
        frameRect.bottomLeft + const Offset(-4, -cornerLen),
      ),
    ];
    for (final (a, b, c) in corners) {
      canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy), cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) =>
      oldDelegate.frameSize != frameSize ||
      oldDelegate.frameCenterY != frameCenterY;
}
