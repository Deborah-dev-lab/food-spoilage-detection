import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'image_preprocessing_service.dart';

class CnnPrediction {
  final String label;
  final double confidence;
  final int classIndex;

  const CnnPrediction({
    required this.label,
    required this.confidence,
    required this.classIndex,
  });
}

class CnnInferenceService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  bool get isLoaded => _interpreter != null;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> loadModel() async {
    if (_interpreter != null) return;

    Interpreter? interpreter;

    try {
      interpreter = await Interpreter.fromAsset(
        'assets/models/freshtrack_cnn_v3.tflite',
      );

      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );

      final labels = labelsData
          .split(RegExp(r'\r?\n'))
          .where((label) => label.trim().isNotEmpty)
          .toList();

      final input = interpreter.getInputTensor(0);
      final output = interpreter.getOutputTensor(0);

      debugPrint('CNN V3 input: ${input.shape} ${input.type}');
      debugPrint('CNN V3 output: ${output.shape} ${output.type}');
      debugPrint('CNN V3 labels: ${labels.length}');

      if (input.shape.join(',') != '1,160,160,3' ||
          output.shape.join(',') != '1,32' ||
          input.type != TensorType.float32 ||
          output.type != TensorType.float32 ||
          labels.length != 32) {
        throw StateError('CNN V3 configuration mismatch');
      }

      _interpreter = interpreter;
      _labels = labels;

      debugPrint('CNN V3 model loaded successfully');
    } catch (_) {
      interpreter?.close();
      rethrow;
    }
  }

  Future<CnnPrediction> predict(Uint8List imageBytes) async {
    if (!isLoaded) {
      await loadModel();
    }

    final interpreter = _interpreter!;

    // Prepare the input image.
    final input = ImagePreprocessingService.preprocess(imageBytes);

    // Allocate output for 32 classes.
    final output = List.generate(1, (_) => List<double>.filled(32, 0.0));

    // Execute TFLite inference.
    interpreter.run(input, output);

    final scores = output[0];

    // Find the class with the highest score.
    var bestIndex = 0;

    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIndex]) {
        bestIndex = i;
      }
    }

    final prediction = CnnPrediction(
      label: _labels[bestIndex],
      confidence: scores[bestIndex],
      classIndex: bestIndex,
    );

    debugPrint(
      'CNN V3 prediction: ${prediction.label} '
      '(${(prediction.confidence * 100).toStringAsFixed(2)}%)',
    );

    return prediction;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = [];
  }
}
