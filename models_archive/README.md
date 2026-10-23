# Arsip Model

## model_int8.tflite — JANGAN DIPAKAI di aplikasi

File ini hasil run pelatihan **36 kelas** (dataset versi penuh), terverifikasi dari
bentuk tensor outputnya `[1, 36]`. Aplikasi dan `assets/labels/labels.json` memakai
**32 kelas**, dan model yang dimuat kode adalah `assets/models/model_float32.tflite`.

File ini dipindahkan keluar dari `assets/` (23 Okt 2026, branch development) karena:
1. Ia tidak dirujuk kode sama sekali, tetapi ikut ter-bundle ke APK (3 MB beban mati).
2. Ia BUKAN hasil kuantisasi dari model float32 aplikasi — mengganti nama file di kode
   akan membuat label hasil scan bergeser dan memunculkan 4 kelas yang tidak ada.

Disimpan di sini hanya sebagai arsip. Bila suatu saat ingin memakai model int8,
kuantisasi harus dilakukan dari model 32 kelas yang sama, lalu output `[1, 32]`
dan akurasinya diverifikasi ulang sebelum dirilis.
