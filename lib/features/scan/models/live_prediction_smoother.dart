import 'dart:typed_data';

/// Menghaluskan keluaran model antar-frame pada pindai live.
///
/// Tanpa penghalusan, label live adalah argmax dari satu frame: geseran
/// kamera sekecil apa pun mengubah distribusi probabilitas dan label
/// langsung melompat, terutama antar kelas yang mirip. Kelas ini memakai
/// rata-rata bergerak eksponensial (EMA) atas vektor probabilitas —
/// satu frame yang menyimpang tidak cukup untuk mengganti label, tetapi
/// objek baru yang stabil mengambil alih dalam beberapa frame.
///
/// [alpha] adalah bobot frame terbaru. Nilai 0,45 berarti satu frame
/// berlawanan belum membalikkan label, dua frame berurutan sudah.
class LivePredictionSmoother {
  LivePredictionSmoother({this.alpha = 0.45});

  final double alpha;

  Float32List? _smoothed;

  /// Memasukkan vektor probabilitas satu frame dan mengembalikan vektor
  /// yang sudah dihaluskan. Vektor pertama (atau vektor yang panjangnya
  /// berubah) dipakai apa adanya sebagai titik awal.
  Float32List add(List<double> probabilities) {
    final current = _smoothed;
    if (current == null || current.length != probabilities.length) {
      final fresh = Float32List(probabilities.length);
      for (var i = 0; i < probabilities.length; i++) {
        fresh[i] = probabilities[i];
      }
      _smoothed = fresh;
      return fresh;
    }
    for (var i = 0; i < probabilities.length; i++) {
      current[i] = alpha * probabilities[i] + (1 - alpha) * current[i];
    }
    return current;
  }

  /// Mengosongkan riwayat, mis. saat sesi pindai baru dimulai, agar
  /// sisa penghalusan objek sebelumnya tidak terbawa.
  void reset() {
    _smoothed = null;
  }
}
