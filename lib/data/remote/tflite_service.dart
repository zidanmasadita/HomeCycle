import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:homesikil/features/scan/models/scan_result_model.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateData {
  final int width;
  final int height;
  final String formatGroup;
  final List<Uint8List> planeBytes;
  final List<int> planeBytesPerRow;
  final List<int?> planeBytesPerPixel;

  IsolateData({
    required this.width,
    required this.height,
    required this.formatGroup,
    required this.planeBytes,
    required this.planeBytesPerRow,
    required this.planeBytesPerPixel,
  });
}

class IsolateResult {
  final Float32List inputList;
  final Uint8List imageBytes;

  IsolateResult(this.inputList, this.imageBytes);
}

// Top-level function for Isolate
IsolateResult _processImageInIsolate(IsolateData data) {
  img.Image? convertedImage;

  if (data.formatGroup == 'yuv420') {
    convertedImage = _convertYUV420ToImage(data);
  } else if (data.formatGroup == 'bgra8888') {
    convertedImage = _convertBGRA8888ToImage(data);
  } else {
    throw Exception('Format gambar tidak didukung: ${data.formatGroup}');
  }

  if (convertedImage == null) throw Exception('Gagal decode frame kamera');

  // We no longer encode to JPG during live preview!
  // This saves massive amounts of CPU and completely fixes the stuttering.
  // The actual high quality JPG will be captured using the native camera API
  // when the user taps the capture button.
  final imageBytes = Uint8List(0);

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

  return IsolateResult(input, imageBytes);
}

img.Image _convertBGRA8888ToImage(IsolateData data) {
  return img.Image.fromBytes(
    width: data.width,
    height: data.height,
    bytes: data.planeBytes[0].buffer,
    order: img.ChannelOrder.bgra,
  );
}

img.Image _convertYUV420ToImage(IsolateData data) {
  final int width = data.width;
  final int height = data.height;
  final int uvRowStride = data.planeBytesPerRow[1];
  final int uvPixelStride = data.planeBytesPerPixel[1] ?? 1;

  final img.Image imgResult = img.Image(width: width, height: height);
  final plane0Bytes = data.planeBytes[0];
  final plane1Bytes = data.planeBytes[1];
  final plane2Bytes = data.planeBytes[2];
  final plane0BytesPerRow = data.planeBytesPerRow[0];

  for (int y = 0; y < height; y++) {
    int pY = y * plane0BytesPerRow;
    int pUV = (y ~/ 2) * uvRowStride;

    for (int x = 0; x < width; x++) {
      final int uvOffset = pUV + (x ~/ 2) * uvPixelStride;
      final yp = plane0Bytes[pY];
      final up = plane1Bytes[uvOffset];
      final vp = plane2Bytes[uvOffset];

      int r = (yp + vp * 1436 / 1024 - 179).round();
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
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

    var inputObj = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.filled(3, 0.0)),
      ),
    );
    
    var pixelIndex = 0;
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

    final outputList = outputObj[0];

    int maxIndex = 0;
    double maxConfidence = outputList[0];

    for (int i = 1; i < outputList.length; i++) {
      if (outputList[i] > maxConfidence) {
        maxConfidence = outputList[i];
        maxIndex = i;
      }
    }

    final detectedLabel = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';

    return ScanResultModel(
      detectedLabel: detectedLabel,
      confidenceScore: maxConfidence,
      condition: 'fresh',
      imageBytes: imageBytes,
    );
  }

  Future<ScanResultModel> runInferenceFromCameraImage(CameraImage image) async {
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
      int maxIndex = 0;
      double maxConfidence = outputList[0];

      for (int i = 1; i < outputList.length; i++) {
        if (outputList[i] > maxConfidence) {
          maxConfidence = outputList[i];
          maxIndex = i;
        }
      }

      final detectedLabel = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';

      return ScanResultModel(
        detectedLabel: detectedLabel,
        confidenceScore: maxConfidence,
        condition: 'fresh',
        imageBytes: result.imageBytes,
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
