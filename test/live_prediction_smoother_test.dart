import 'package:flutter_test/flutter_test.dart';
import 'package:homecycle/features/scan/models/live_prediction_smoother.dart';

int _argmax(List<double> values) {
  var best = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] > values[best]) best = i;
  }
  return best;
}

void main() {
  group('LivePredictionSmoother', () {
    test('frame pertama dipakai apa adanya', () {
      final smoother = LivePredictionSmoother();
      final result = smoother.add([0.2, 0.8]);
      expect(result[0], closeTo(0.2, 1e-6));
      expect(result[1], closeTo(0.8, 1e-6));
    });

    test('satu frame berlawanan tidak membalikkan label', () {
      final smoother = LivePredictionSmoother();
      smoother.add([0.9, 0.1]);
      final result = smoother.add([0.1, 0.9]);
      // EMA alpha 0,45: [0,54, 0,46] — label lama bertahan.
      expect(_argmax(result), 0);
    });

    test('dua frame berlawanan berurutan membalikkan label', () {
      final smoother = LivePredictionSmoother();
      smoother.add([0.9, 0.1]);
      smoother.add([0.1, 0.9]);
      final result = smoother.add([0.1, 0.9]);
      // EMA: [0,342, 0,658] — objek baru yang stabil mengambil alih.
      expect(_argmax(result), 1);
    });

    test('reset mengosongkan riwayat penghalusan', () {
      final smoother = LivePredictionSmoother();
      smoother.add([0.9, 0.1]);
      smoother.reset();
      final result = smoother.add([0.1, 0.9]);
      expect(result[1], closeTo(0.9, 1e-6));
    });

    test('vektor dengan panjang berbeda memulai ulang penghalusan', () {
      final smoother = LivePredictionSmoother();
      smoother.add([0.9, 0.1]);
      final result = smoother.add([0.1, 0.3, 0.6]);
      expect(result.length, 3);
      expect(result[2], closeTo(0.6, 1e-6));
    });
  });
}
