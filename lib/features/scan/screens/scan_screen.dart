import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/features/scan/provider/scan_provider.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'package:homesikil/core/constants/app_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

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

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      try {
        // Reduce camera exposure brightness to prevent overexposed images
        await _controller!.setExposureOffset(-1.5);
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
            context.read<ScanProvider>().processCameraFrame(image);
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

      // Capture the current live result as the final result
      scanProvider.captureLiveResult();

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
                final result = provider.liveResult;
                if (result == null) return const SizedBox.shrink();

                final confidence = (result.confidenceScore * 100)
                    .toStringAsFixed(1);

                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.detectedLabel.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: $confidence%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
