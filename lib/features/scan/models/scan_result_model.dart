import 'dart:typed_data';

class ScanResultModel {
  final String detectedLabel;
  final double confidenceScore;
  final String? condition;
  final Uint8List? imageBytes;
  final String? categoryId;

  const ScanResultModel({
    required this.detectedLabel,
    required this.confidenceScore,
    this.condition,
    this.imageBytes,
    this.categoryId,
  });

  ScanResultModel copyWith({
    String? detectedLabel,
    double? confidenceScore,
    String? condition,
    Uint8List? imageBytes,
    String? categoryId,
  }) {
    return ScanResultModel(
      detectedLabel: detectedLabel ?? this.detectedLabel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      condition: condition ?? this.condition,
      imageBytes: imageBytes ?? this.imageBytes,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
