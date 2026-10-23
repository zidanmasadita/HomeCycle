/// Geometri crop klasifikasi — satu sumber kebenaran yang dipakai
/// pipeline inferensi (tflite_service) dan kotak pemandu di layar
/// (scan_frame_overlay), supaya yang digambar selalu sama dengan yang
/// diklasifikasikan model.
///
/// Model dilatih dari gambar yang objeknya mendominasi frame, jadi
/// ketepatannya jatuh bila objek kecil di dalam crop. Terukur pada 32
/// gambar kelas repo (objek diperkecil secara sintetis di dalam frame):
/// crop penuh memberi 75% / 66% / 28% untuk objek 100% / 50% / 35%
/// frame. Dua mekanisme melawannya tanpa mengubah model:
///
/// 1. Live: hanya persegi tengah sebesar [liveFraction] yang
///    diklasifikasikan — setara zoom digital ke tengah frame, dan
///    kotak pemandu digambar persis sebesar wilayah itu.
/// 2. Foto diam: inferensi multi-crop — probabilitas dari crop
///    [multiFractions] dirata-ratakan. Pada set uji yang sama cara ini
///    memberi 81% / 81% / 62%, terbaik atau menyamai terbaik di semua
///    jarak.
class ScanCrop {
  ScanCrop._();

  /// Fraksi sisi persegi tengah frame live yang diklasifikasikan
  /// (0,6 = 60% dari sisi terpendek frame, di tengah).
  static const double liveFraction = 0.6;

  /// Fraksi-fraksi crop untuk inferensi multi-crop pada foto diam.
  static const List<double> multiFractions = [1.0, 0.7, 0.5];
}
