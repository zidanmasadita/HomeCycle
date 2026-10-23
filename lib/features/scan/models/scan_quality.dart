/// Evaluasi kualitas hasil pindai — mitigasi untuk pertanyaan penguji
/// tentang kondisi nyata (pencahayaan ekstrem, objek tertutup, dan
/// sejenisnya).
///
/// Model klasifikasi sendiri tidak diubah. Sebagai gantinya, aplikasi
/// memasang dua gerbang di sekeliling model:
///
/// 1. Gerbang kecerahan: luminansi rata-rata foto hasil pindai dihitung
///    sebelum hasil diterima. Foto yang terlalu gelap atau terlalu terang
///    diberi peringatan karena akurasi model terbukti jatuh pada kondisi
///    tersebut.
/// 2. Gerbang keyakinan: hasil dengan keyakinan top-1 di bawah ambang
///    ditandai agar pengguna memeriksa ulang labelnya atau memindai ulang,
///    bukan menyimpannya begitu saja.
///
/// Ambang di bawah ini heuristik awal yang diturunkan dari uji ketahanan
/// model (Okt 2026): pada gambar uji, kondisi sangat gelap (kecerahan
/// x0,15) menurunkan ketepatan model ke kisaran 52% dan sebagian besar
/// kesalahan berkumpul di keyakinan < 0,60. Nilai-nilai ini dapat disetel
/// ulang berdasarkan data lapangan.
enum ScanQualityIssue { tooDark, tooBright, lowConfidence }

class ScanQuality {
  ScanQuality._();

  /// Keyakinan top-1 minimum agar hasil dianggap meyakinkan.
  static const double minConfidence = 0.60;

  /// Luminansi rata-rata (0..1) di bawah nilai ini dianggap terlalu gelap.
  static const double minLuminance = 0.10;

  /// Luminansi rata-rata (0..1) di atas nilai ini dianggap terlalu terang.
  static const double maxLuminance = 0.92;

  /// Menilai satu hasil pindai. [meanLuminance] boleh null bila tidak
  /// tersedia (mis. hasil live dari frame kamera); dalam hal itu hanya
  /// keyakinan yang dinilai.
  static List<ScanQualityIssue> evaluate({
    required double confidence,
    double? meanLuminance,
  }) {
    final issues = <ScanQualityIssue>[];
    if (meanLuminance != null) {
      if (meanLuminance < minLuminance) {
        issues.add(ScanQualityIssue.tooDark);
      } else if (meanLuminance > maxLuminance) {
        issues.add(ScanQualityIssue.tooBright);
      }
    }
    if (confidence < minConfidence) {
      issues.add(ScanQualityIssue.lowConfidence);
    }
    return issues;
  }
}
