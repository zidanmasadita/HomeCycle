import 'package:flutter_test/flutter_test.dart';
import 'package:homecycle/features/scan/models/scan_quality.dart';

void main() {
  group('ScanQuality.evaluate', () {
    test('kondisi baik tidak menghasilkan isu', () {
      final issues = ScanQuality.evaluate(
        confidence: 0.95,
        meanLuminance: 0.50,
      );
      expect(issues, isEmpty);
    });

    test('foto sangat gelap ditandai tooDark', () {
      final issues = ScanQuality.evaluate(
        confidence: 0.95,
        meanLuminance: 0.05,
      );
      expect(issues, contains(ScanQualityIssue.tooDark));
    });

    test('foto sangat terang ditandai tooBright', () {
      final issues = ScanQuality.evaluate(
        confidence: 0.95,
        meanLuminance: 0.97,
      );
      expect(issues, contains(ScanQualityIssue.tooBright));
    });

    test('keyakinan di bawah ambang ditandai lowConfidence', () {
      final issues = ScanQuality.evaluate(
        confidence: 0.45,
        meanLuminance: 0.50,
      );
      expect(issues, contains(ScanQualityIssue.lowConfidence));
    });

    test('keyakinan tepat di ambang tidak ditandai lowConfidence', () {
      final issues = ScanQuality.evaluate(
        confidence: ScanQuality.minConfidence,
        meanLuminance: 0.50,
      );
      expect(issues, isNot(contains(ScanQualityIssue.lowConfidence)));
    });

    test('luminansi tepat di batas rentang tidak ditandai', () {
      expect(
        ScanQuality.evaluate(
          confidence: 0.90,
          meanLuminance: ScanQuality.minLuminance,
        ),
        isNot(contains(ScanQualityIssue.tooDark)),
      );
      expect(
        ScanQuality.evaluate(
          confidence: 0.90,
          meanLuminance: ScanQuality.maxLuminance,
        ),
        isNot(contains(ScanQualityIssue.tooBright)),
      );
    });

    test('tanpa luminansi, hanya keyakinan yang dinilai', () {
      expect(ScanQuality.evaluate(confidence: 0.90), isEmpty);
      expect(
        ScanQuality.evaluate(confidence: 0.30),
        contains(ScanQualityIssue.lowConfidence),
      );
    });

    test('kombinasi gelap dan keyakinan rendah menghasilkan dua isu', () {
      final issues = ScanQuality.evaluate(
        confidence: 0.30,
        meanLuminance: 0.04,
      );
      expect(issues, hasLength(2));
      expect(issues, contains(ScanQualityIssue.tooDark));
      expect(issues, contains(ScanQualityIssue.lowConfidence));
    });
  });
}
