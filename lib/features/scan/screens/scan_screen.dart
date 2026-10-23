import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:homecycle/features/scan/models/scan_quality.dart';
import 'package:homecycle/features/scan/provider/scan_provider.dart';
import 'package:homecycle/features/scan/widgets/scan_frame_overlay.dart';
import 'package:homecycle/routes/app_routes.dart';
import 'package:homecycle/core/constants/app_colors.dart';
import 'package:homecycle/core/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  /// Sudut putar agar frame stream menjadi tegak. Hanya Android:
  /// frame tiba dalam orientasi sensor; kamera belakang umumnya
  /// sensorOrientation 90, kamera depan kebalikannya.
  int _frameRotationDegrees = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().initModel();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      if (Platform.isAndroid) {
        _frameRotationDegrees =
            backCamera.lensDirection == CameraLensDirection.front
            ? (360 - backCamera.sensorOrientation) % 360
            : backCamera.sensorOrientation;
      }

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      try {
        // Sedikit saja: offset -1,5 sebelumnya membuat frame live jauh
        // lebih gelap daripada foto tangkapan, sehingga label mudah
        // berubah antar-frame dan gerbang kecerahan mudah terpicu.
        // -0,5 tetap meredam silau tanpa menggelapkan masukan model.
        await _controller!.setExposureOffset(-0.5);
      } catch (e) {
        debugPrint('Could not set exposure offset: $e');
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        // Start live stream
        _controller!.startImageStream((CameraImage image) {
          if (mounted) {
            context.read<ScanProvider>().processCameraFrame(
              image,
              rotationDegrees: _frameRotationDegrees,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureLiveResult() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final scanProvider = context.read<ScanProvider>();
      if (scanProvider.liveResult == null) return;

      // Stop the image stream to freeze the camera and stop processing
      await _controller!.stopImageStream();

      // Show a loading dialog just in case
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Take high quality picture using native camera API
      final XFile picture = await _controller!.takePicture();
      final Uint8List imageBytes = await picture.readAsBytes();

      // Bekukan hasil live sebagai hasil akhir, lengkapi dengan foto
      // beresolusi penuh dan luminansinya untuk gerbang kualitas.
      await scanProvider.captureWithQuality(imageBytes);

      // Close loading dialog and navigate
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, AppRoutes.scanResult);
      }
    } catch (e) {
      debugPrint('Error capturing result: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)),

          // Bingkai pemandu: area persegi yang benar-benar diproses model
          const ScanFrameOverlay(),

          // Back button
          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Live Result Overlay
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Consumer<ScanProvider>(
              builder: (context, provider, child) {
                if (provider.errorMessage != null) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.withValues(alpha: 0.8),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final result = provider.liveResult;
                if (result == null) return const SizedBox.shrink();

                final confidence = (result.confidenceScore * 100)
                    .toStringAsFixed(1);

                // Peringatan kecerahan saat membidik: luminansi frame
                // live dinilai dengan gerbang yang sama seperti foto
                // tangkapan, supaya pengguna memperbaiki cahaya SEBELUM
                // memotret, bukan baru tahu sesudahnya di layar hasil.
                final liveIssues = ScanQuality.evaluate(
                  confidence: result.confidenceScore,
                  meanLuminance: result.meanLuminance,
                );
                final ScanQualityIssue? brightnessIssue =
                    liveIssues.contains(ScanQualityIssue.tooDark)
                    ? ScanQualityIssue.tooDark
                    : liveIssues.contains(ScanQualityIssue.tooBright)
                    ? ScanQualityIssue.tooBright
                    : null;

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              result.detectedLabel.toUpperCase(),
                              style: AppTextStyles.title2Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'scan.confidence'.tr(args: [confidence]),
                              style: AppTextStyles.body1Regular.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (brightnessIssue != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                brightnessIssue == ScanQualityIssue.tooDark
                                    ? Icons.dark_mode
                                    : Icons.wb_sunny,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  brightnessIssue == ScanQualityIssue.tooDark
                                      ? 'scan.quality_too_dark'.tr()
                                      : 'scan.quality_too_bright'.tr(),
                                  style: AppTextStyles.body2Regular.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Capture button area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: Colors.black.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _captureLiveResult,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
