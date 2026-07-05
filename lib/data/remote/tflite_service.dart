import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:homesikil/features/scan/models/scan_result_model.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

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

  Future<ScanResultModel> runInference(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception('Model belum diinisialisasi');
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Gagal decode gambar');

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

    var input = Float32List(1 * 224 * 224 * 3);
    var pixelIndex = 0;

    for (var y = 0; y < resizedImage.height; y++) {
      for (var x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);

        input[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }

    final inputShape = [1, 224, 224, 3];
    final inputObj = input.reshape(inputShape);

    final outputShape = [1, 36];
    var outputObj = List.filled(36, 0.0).reshape(outputShape);

    _interpreter!.run(inputObj, outputObj);

    final outputList = (outputObj as List)[0] as List<double>;

    int maxIndex = 0;
    double maxConfidence = outputList[0];

    for (int i = 1; i < outputList.length; i++) {
      if (outputList[i] > maxConfidence) {
        maxConfidence = outputList[i];
        maxIndex = i;
      }
    }

    final detectedLabel = maxConfidence >= 0.70 ? _labels[maxIndex] : 'Unknown';

    return ScanResultModel(
      detectedLabel: detectedLabel,
      confidenceScore: maxConfidence,
      condition: 'fresh',
      imageBytes: imageBytes,
    );
  }

  Future<ScanResultModel> runInferenceFromCameraImage(CameraImage image) async {
    if (_interpreter == null) throw Exception('Model belum diinisialisasi');

    img.Image? convertedImage;

    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        convertedImage = _convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        convertedImage = _convertBGRA8888ToImage(image);
      } else {
        throw Exception('Format gambar tidak didukung: ${image.format.group}');
      }
    } catch (e) {
      throw Exception('Gagal konversi frame kamera: $e');
    }

    if (convertedImage == null) throw Exception('Gagal decode frame kamera');

    final imageBytes = Uint8List.fromList(
      img.encodeJpg(convertedImage, quality: 70),
    );

    final size = convertedImage.width < convertedImage.height
        ? convertedImage.width
        : convertedImage.height;
    final x0 = (convertedImage.width - size) ~/ 2;
    final y0 = (convertedImage.height - size) ~/ 2;

    final croppedImage = img.copyCrop(
      convertedImage,
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

    var input = Float32List(1 * 224 * 224 * 3);
    var pixelIndex = 0;
    for (var y = 0; y < resizedImage.height; y++) {
      for (var x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }

    final inputShape = [1, 224, 224, 3];
    final inputObj = input.reshape(inputShape);
    final outputShape = [1, 36];
    var outputObj = List.filled(36, 0.0).reshape(outputShape);

    _interpreter!.run(inputObj, outputObj);
    final outputList = (outputObj as List)[0] as List<double>;
    int maxIndex = 0;
    double maxConfidence = outputList[0];

    for (int i = 1; i < outputList.length; i++) {
      if (outputList[i] > maxConfidence) {
        maxConfidence = outputList[i];
        maxIndex = i;
      }
    }

    final detectedLabel = maxConfidence >= 0.70 ? _labels[maxIndex] : 'Unknown';

    return ScanResultModel(
      detectedLabel: detectedLabel,
      confidenceScore: maxConfidence,
      condition: 'fresh',
      imageBytes: imageBytes,
    );
  }

  img.Image _convertBGRA8888ToImage(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final img.Image imgResult = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      int pY = y * image.planes[0].bytesPerRow;
      int pUV = (y ~/ 2) * uvRowStride;

      for (int x = 0; x < width; x++) {
        final int uvOffset = pUV + (x ~/ 2) * uvPixelStride;
        final yp = image.planes[0].bytes[pY];
        final up = image.planes[1].bytes[uvOffset];
        final vp = image.planes[2].bytes[uvOffset];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgResult.setPixelRgb(x, y, r, g, b);
        pY++;
      }
    }
    return imgResult;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
