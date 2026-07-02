import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:homesikil/features/scan/models/scan_result_model.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model_float32.tflite');
      
      final labelsData = await rootBundle.loadString('assets/labels/labels.json');
      final Map<String, dynamic> labelsMap = json.decode(labelsData);
      
      final maxIndex = labelsMap.keys.map(int.parse).reduce((a, b) => a > b ? a : b);
      _labels = List.generate(maxIndex + 1, (index) => labelsMap[index.toString()] as String);
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

    // Resize to exactly 224x224 (LANCZOS interpolation)
    final resizedImage = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    // Convert to Float32List and normalize to [-1, 1] using (value / 127.5) - 1.0
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

    final detectedLabel = _labels[maxIndex];

    return ScanResultModel(
      detectedLabel: detectedLabel,
      confidenceScore: maxConfidence,
      condition: 'fresh', // Neutral condition, not output by model
      imageBytes: imageBytes,
    );
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
