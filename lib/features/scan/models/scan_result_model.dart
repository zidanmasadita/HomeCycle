import 'dart:typed_data';

class ScanResultModel {
  final String detectedLabel;
  final double confidenceScore;
  final String? condition;
  final Uint8List? imageBytes;
  final String? categoryId;

  /// Luminansi rata-rata (0..1) foto yang dipindai, dihitung dari area
  /// tengah yang sama dengan yang diklasifikasikan model. Dipakai oleh
  /// gerbang kecerahan (lihat scan_quality.dart). Null bila tidak tersedia,
  /// mis. pada hasil live dari frame kamera.
  final double? meanLuminance;

  const ScanResultModel({
    required this.detectedLabel,
    required this.confidenceScore,
    this.condition,
    this.imageBytes,
    this.categoryId,
    this.meanLuminance,
  });

  ScanResultModel copyWith({
    String? detectedLabel,
    double? confidenceScore,
    String? condition,
    Uint8List? imageBytes,
    String? categoryId,
    double? meanLuminance,
  }) {
    return ScanResultModel(
      detectedLabel: detectedLabel ?? this.detectedLabel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      condition: condition ?? this.condition,
      imageBytes: imageBytes ?? this.imageBytes,
      categoryId: categoryId ?? this.categoryId,
      meanLuminance: meanLuminance ?? this.meanLuminance,
    );
  }
}
