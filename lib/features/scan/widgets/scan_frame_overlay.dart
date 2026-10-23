import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';

/// Bingkai pemandu pada layar pindai — lapis pencegahan untuk mitigasi
/// kondisi nyata (pertanyaan penguji no. 3).
///
/// Kotak persegi di tengah layar menunjukkan persis area yang diproses
/// model: pipeline klasifikasi memotong persegi tengah gambar lalu
/// mengubah ukurannya menjadi 224x224. Instruksi di bawah bingkai mengajak
/// pengguna memenuhi bingkai dengan objek, tidak menutupi objek dengan
/// tangan/benda lain, dan memastikan cahaya cukup — tiga hal yang terbukti
/// paling memengaruhi ketepatan hasil pindai.
class ScanFrameOverlay extends StatelessWidget {
  const ScanFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.78;
    final frameCenterY = size.height * 0.42;

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
