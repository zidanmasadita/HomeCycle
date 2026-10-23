import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:homecycle/features/scan/models/live_prediction_smoother.dart';
import 'package:homecycle/features/scan/models/scan_crop.dart';
import 'package:homecycle/features/scan/models/scan_result_model.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateData {
  final int width;
  final int height;
  final String formatGroup;
  final List<Uint8List> planeBytes;
  final List<int> planeBytesPerRow;
  final List<int?> planeBytesPerPixel;

  /// Sudut (derajat, kelipatan 90) untuk memutar hasil crop agar tegak.
  /// Frame stream kamera Android tiba dalam orientasi sensor
  /// (menyamping); tanpa putaran ini model mengklasifikasikan gambar
  /// miring 90 derajat, yang terbukti menurunkan ketepatannya.
  final int rotationDegrees;

  IsolateData({
    required this.width,
    required this.height,
    required this.formatGroup,
    required this.planeBytes,
    required this.planeBytesPerRow,
    required this.planeBytesPerPixel,
    required this.rotationDegrees,
  });
}

class IsolateResult {
  final Float32List inputList;
  final Uint8List imageBytes;

  /// Luminansi rata-rata (0..1) area crop yang diklasifikasikan,
  /// dihitung dari piksel 224x224 yang sama dengan masukan model.
  final double meanLuminance;

  IsolateResult(this.inputList, this.imageBytes, this.meanLuminance);
}

// Top-level function for Isolate
IsolateResult _processImageInIsolate(IsolateData data) {
  // Model hanya memakai persegi tengah frame sebesar ScanCrop.liveFraction
  // (lihat scan_crop.dart), jadi hanya area itu yang dikonversi ke RGB.
  // Mengonversi seluruh frame membuang sebagian besar pekerjaan isolate
  // pada piksel yang tidak pernah dilihat model.
  final fullSize = data.width < data.height ? data.width : data.height;
  final size = (fullSize * ScanCrop.liveFraction).round();
  final x0 = (data.width - size) ~/ 2;
  final y0 = (data.height - size) ~/ 2;

  img.Image squareImage;
  if (data.formatGroup == 'yuv420') {
    squareImage = _convertYUV420RegionToImage(data, x0, y0, size);
  } else if (data.formatGroup == 'bgra8888') {
    final fullImage = _convertBGRA8888ToImage(data);
    squareImage = img.copyCrop(
      fullImage,
      x: x0,
      y: y0,
      width: size,
      height: size,
    );
  } else {
    throw Exception('Format gambar tidak didukung: ${data.formatGroup}');
  }

  // We no longer encode to JPG during live preview!
  // This saves massive amounts of CPU and completely fixes the stuttering.
  // The actual high quality JPG will be captured using the native camera API
  // when the user taps the capture button.
  final imageBytes = Uint8List(0);

  var resizedImage = img.copyResize(
    squareImage,
    width: 224,
    height: 224,
    interpolation: img.Interpolation.linear,
  );

  // Putar ke orientasi tegak pada ukuran 224x224 (paling murah, dan
  // untuk kelipatan 90 derajat tidak ada piksel yang terbuang).
  final rotation = data.rotationDegrees % 360;
  if (rotation != 0) {
    resizedImage = img.copyRotate(resizedImage, angle: rotation);
  }

  var input = Float32List(1 * 224 * 224 * 3);
  var pixelIndex = 0;
  var luminanceSum = 0.0;
  for (var y = 0; y < resizedImage.height; y++) {
    for (var x = 0; x < resizedImage.width; x++) {
      final pixel = resizedImage.getPixel(x, y);
      input[pixelIndex++] = (pixel.r / 127.5) - 1.0;
      input[pixelIndex++] = (pixel.g / 127.5) - 1.0;
      input[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      // Luminansi persepsi (ITU-R BT.709) dari piksel yang sama, supaya
      // jalur live juga punya angka kecerahan untuk gerbang kualitas.
      luminanceSum += 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
    }
  }
  final meanLuminance = luminanceSum / (224 * 224) / 255.0;

  return IsolateResult(input, imageBytes, meanLuminance);
}

img.Image _convertBGRA8888ToImage(IsolateData data) {
  return img.Image.fromBytes(
    width: data.width,
    height: data.height,
    bytes: data.planeBytes[0].buffer,
    order: img.ChannelOrder.bgra,
  );
}

/// Mengonversi hanya wilayah persegi (x0, y0, size x size) dari frame
/// YUV420 ke gambar RGB berukuran size x size. Indeks UV selalu dihitung
/// dari koordinat absolut frame asli, karena sub-sampling kroma 2x2
/// mengacu pada posisi piksel di frame penuh, bukan di wilayah crop.
img.Image _convertYUV420RegionToImage(
  IsolateData data,
  int x0,
  int y0,
  int size,
) {
  final int uvRowStride = data.planeBytesPerRow[1];
  final int uvPixelStride = data.planeBytesPerPixel[1] ?? 1;

  final img.Image imgResult = img.Image(width: size, height: size);
  final plane0Bytes = data.planeBytes[0];
  final plane1Bytes = data.planeBytes[1];
  final plane2Bytes = data.planeBytes[2];
  final plane0BytesPerRow = data.planeBytesPerRow[0];

  for (int y = 0; y < size; y++) {
    final int srcY = y0 + y;
    final int pY = srcY * plane0BytesPerRow;
    final int pUV = (srcY ~/ 2) * uvRowStride;

    for (int x = 0; x < size; x++) {
      final int srcX = x0 + x;
      final int uvOffset = pUV + (srcX ~/ 2) * uvPixelStride;
      final yp = plane0Bytes[pY + srcX];
      final up = plane1Bytes[uvOffset];
      final vp = plane2Bytes[uvOffset];

      int r = (yp + vp * 1436 / 1024 - 179).round();
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
      int b = (yp + up * 1814 / 1024 - 227).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      imgResult.setPixelRgb(x, y, r, g, b);
    }
  }
  return imgResult;
}


class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  /// Penghalus keluaran antar-frame khusus jalur live; jalur foto
  /// tangkapan (runInference) tidak dihaluskan karena hanya satu frame.
  final LivePredictionSmoother _liveSmoother = LivePredictionSmoother();

  /// Mengosongkan riwayat penghalusan live, mis. saat layar pindai
  /// dibuka kembali untuk objek yang berbeda.
  void resetLiveSmoothing() {
    _liveSmoother.reset();
  }

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/model_float32.tflite',
      );

      final labelsData = await rootBundle.loadString(
        'assets/labels/labels.json',
      );
      final Map<String, dynamic> labelsMap = json.decode(labelsData);

      final maxIndex = labelsMap.keys
          .map(int.parse)
          .reduce((a, b) => a > b ? a : b);
      _labels = List.generate(
        maxIndex + 1,
        (index) => labelsMap[index.toString()] as String,
      );
    } catch (e) {
      throw Exception('Gagal memuat model TFLite: $e');
    }
  }

  /// Memotong persegi tengah sebesar [fraction] dari sisi terpendek
  /// gambar, lalu mengubah ukurannya menjadi 224x224 — masukan model.
  img.Image _squareCropResize(img.Image image, double fraction) {
    final fullSize = image.width < image.height ? image.width : image.height;
    final size = (fullSize * fraction).round();
    final x0 = (image.width - size) ~/ 2;
    final y0 = (image.height - size) ~/ 2;
    final croppedImage = img.copyCrop(
      image,
      x: x0,
      y: y0,
      width: size,
      height: size,
    );
    return img.copyResize(
      croppedImage,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Menjalankan model pada gambar 224x224 dan mengembalikan vektor
  /// probabilitas semua kelas.
  List<double> _runModel(img.Image resizedImage) {
    var inputObj = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.filled(3, 0.0)),
      ),
    );

    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputObj[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        inputObj[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        inputObj[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }

    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final numClasses = outputShape[1]; // e.g. 32
    var outputObj = List.generate(1, (_) => List.filled(numClasses, 0.0));
    _interpreter!.run(inputObj, outputObj);

    return outputObj[0];
  }

  /// Membentuk hasil dari vektor probabilitas (argmax + label).
  ScanResultModel _resultFromProbabilities(
    List<double> probabilities, {
    required Uint8List imageBytes,
    required double? meanLuminance,
  }) {
    int maxIndex = 0;
    double maxConfidence = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    final detectedLabel = maxIndex < _labels.length
        ? _labels[maxIndex]
        : 'Unknown';

    return ScanResultModel(
      detectedLabel: detectedLabel,
      confidenceScore: maxConfidence,
      condition: 'fresh',
      imageBytes: imageBytes,
      meanLuminance: meanLuminance,
    );
  }

  /// Decode gambar dan terapkan orientasi EXIF-nya. Sebagian perangkat
  /// menulis JPEG dalam orientasi sensor plus tag EXIF, dan decodeImage
  /// tidak memutarnya otomatis; tanpa ini foto bisa diklasifikasikan
  /// miring. Bila EXIF normal, bakeOrientation tidak mengubah apa pun.
  img.Image _decodeOriented(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw Exception('Gagal decode gambar');
    return img.bakeOrientation(decoded);
  }

  Future<ScanResultModel> runInference(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception('Model belum diinisialisasi');
    }

    final image = _decodeOriented(imageBytes);
    final resizedImage = _squareCropResize(image, 1.0);
    final probabilities = _runModel(resizedImage);

    return _resultFromProbabilities(
      probabilities,
      imageBytes: imageBytes,
      meanLuminance: _meanLuminance(resizedImage),
    );
  }

  /// Seperti [runInference], tetapi probabilitas adalah rata-rata dari
  /// beberapa crop tengah (lihat ScanCrop.multiFractions), sehingga
  /// lebih tahan terhadap objek yang tidak memenuhi frame. Luminansi
  /// tetap dihitung dari crop penuh, konsisten dengan gerbang kualitas.
  Future<ScanResultModel> runInferenceMultiCrop(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception('Model belum diinisialisasi');
    }

    final image = _decodeOriented(imageBytes);
    List<double>? totals;
    double? luminance;
    for (final fraction in ScanCrop.multiFractions) {
      final resizedImage = _squareCropResize(image, fraction);
      final probabilities = _runModel(resizedImage);
      if (fraction == 1.0) {
        luminance = _meanLuminance(resizedImage);
      }
      if (totals == null) {
        totals = List<double>.from(probabilities);
      } else {
        for (var i = 0; i < probabilities.length; i++) {
          totals[i] += probabilities[i];
        }
      }
    }

    final count = ScanCrop.multiFractions.length;
    final averaged = [for (final v in totals!) v / count];

    return _resultFromProbabilities(
      averaged,
      imageBytes: imageBytes,
      meanLuminance: luminance,
    );
  }

  /// Luminansi rata-rata (0..1) sebuah gambar yang sudah berukuran 224x224,
  /// memakai bobot persepsi standar (ITU-R BT.709).
  static double _meanLuminance(img.Image image) {
    var sum = 0.0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        sum += 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
      }
    }
    return sum / (image.width * image.height) / 255.0;
  }

  /// Menghitung luminansi rata-rata foto pada area tengah yang sama dengan
  /// area yang diklasifikasikan model (crop persegi tengah). Dipakai untuk
  /// jalur tangkapan kamera live, yang hasil klasifikasinya berasal dari
  /// frame stream. Mengembalikan null bila gambar gagal didekode.
  double? estimateMeanLuminance(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final size = image.width < image.height ? image.width : image.height;
      final x0 = (image.width - size) ~/ 2;
      final y0 = (image.height - size) ~/ 2;
      final croppedImage = img.copyCrop(
        image,
        x: x0,
        y: y0,
        width: size,
        height: size,
      );
      final resizedImage = img.copyResize(
        croppedImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );
      return _meanLuminance(resizedImage);
    } catch (_) {
      return null;
    }
  }

  Future<ScanResultModel> runInferenceFromCameraImage(
    CameraImage image, {
    int rotationDegrees = 0,
  }) async {
    if (_interpreter == null) throw Exception('Model belum diinisialisasi');

    try {
      final isolateData = IsolateData(
        width: image.width,
        height: image.height,
        formatGroup: image.format.group.name,
        // MUST use Uint8List.fromList to copy the native memory view,
        // otherwise compute() throws an exception and fails!
        planeBytes: image.planes.map((p) => Uint8List.fromList(p.bytes)).toList(),
        planeBytesPerRow: image.planes.map((p) => p.bytesPerRow).toList(),
        planeBytesPerPixel: image.planes.map((p) => p.bytesPerPixel).toList(),
        rotationDegrees: rotationDegrees,
      );

      // Offload heavy image processing to an isolate
      final result = await compute(_processImageInIsolate, isolateData);

      var inputObj = List.generate(
        1,
        (_) => List.generate(
          224,
          (_) => List.generate(224, (_) => List.filled(3, 0.0)),
        ),
      );
      
      int p = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          inputObj[0][y][x][0] = result.inputList[p++];
          inputObj[0][y][x][1] = result.inputList[p++];
          inputObj[0][y][x][2] = result.inputList[p++];
        }
      }

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape[1];
      var outputObj = List.generate(1, (_) => List.filled(numClasses, 0.0));
      _interpreter!.run(inputObj, outputObj);
      
      final outputList = outputObj[0];

      // Haluskan antar-frame sebelum argmax: label dan keyakinan yang
      // tampil adalah milik vektor yang sudah dirata-ratakan, bukan
      // milik satu frame yang kebetulan lewat.
      final smoothed = _liveSmoother.add(outputList);
      int maxIndex = 0;
      double maxConfidence = smoothed[0];

      for (int i = 1; i < smoothed.length; i++) {
        if (smoothed[i] > maxConfidence) {
          maxConfidence = smoothed[i];
          maxIndex = i;
        }
      }

      final detectedLabel = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';

      return ScanResultModel(
        detectedLabel: detectedLabel,
        confidenceScore: maxConfidence,
        condition: 'fresh',
        imageBytes: result.imageBytes,
        meanLuminance: result.meanLuminance,
      );
    } catch (e) {
      throw Exception('Gagal konversi frame kamera: $e');
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
