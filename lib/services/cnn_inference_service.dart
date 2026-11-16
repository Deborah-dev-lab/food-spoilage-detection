import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'image_preprocessing_service.dart';

class CnnPrediction {
  final String label;
  final double confidence;
  final int classIndex;
  final bool isProduce;
  final double produceScore;

  const CnnPrediction({
    required this.label,
    required this.confidence,
    required this.classIndex,
    this.isProduce = true,
    this.produceScore = 1.0,
  });
}

class CnnInferenceService {
  Interpreter? _detector;
  Interpreter? _classifier;

  List<String> _labels = [];

  static const double produceThreshold = 0.50;
  static const int classCount = 25;

  bool get isLoaded => _detector != null && _classifier != null;

  List<String> get labels => List.unmodifiable(_labels);

  Future<void> loadModel() async {
    if (isLoaded) return;

    Interpreter? detector;
    Interpreter? classifier;

    try {
      detector = await Interpreter.fromAsset(
        'assets/models/freshtrack_produce_detector.tflite',
      );

      classifier = await Interpreter.fromAsset(
        'assets/models/freshtrack_v4_classifier.tflite',
      );

      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );

      final labels = labelsData
          .split(RegExp(r'\r?\n'))
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      final detectorInput = detector.getInputTensor(0);
      final detectorOutput = detector.getOutputTensor(0);

      final classifierInput = classifier.getInputTensor(0);
      final classifierOutput = classifier.getOutputTensor(0);

      debugPrint(
        'Produce detector input: '
        '${detectorInput.shape} ${detectorInput.type}',
      );

      debugPrint(
        'Produce detector output: '
        '${detectorOutput.shape} ${detectorOutput.type}',
      );

      debugPrint(
        'CNN V4 input: '
        '${classifierInput.shape} ${classifierInput.type}',
      );

      debugPrint(
        'CNN V4 output: '
        '${classifierOutput.shape} ${classifierOutput.type}',
      );

      if (detectorInput.shape.join(',') != '1,160,160,3' ||
          detectorOutput.shape.join(',') != '1,1' ||
          classifierInput.shape.join(',') != '1,160,160,3' ||
          classifierOutput.shape.join(',') != '1,25' ||
          detectorInput.type != TensorType.float32 ||
          detectorOutput.type != TensorType.float32 ||
          classifierInput.type != TensorType.float32 ||
          classifierOutput.type != TensorType.float32 ||
          labels.length != classCount) {
        throw StateError('FreshTrack V4 model configuration mismatch.');
      }

      _detector = detector;
      _classifier = classifier;
      _labels = labels;

      debugPrint('FreshTrack V4 models loaded successfully.');
    } catch (error) {
      detector?.close();
      classifier?.close();
      rethrow;
    }
  }

  Future<CnnPrediction> predict(Uint8List imageBytes) async {
    if (!isLoaded) {
      await loadModel();
    }

    // Both models use the same image dimensions.
    // The input must contain RGB float32 values
    // in the 0-255 range.
    final input = ImagePreprocessingService.preprocess(imageBytes);

    // -----------------------------------------
    // STAGE A: PRODUCE DETECTION
    // -----------------------------------------

    final detectorOutput = [
      <double>[0.0],
    ];

    _detector!.run(input, detectorOutput);

    final produceScore = detectorOutput[0][0];

    if (!produceScore.isFinite || produceScore < 0.0 || produceScore > 1.0) {
      throw StateError('Invalid produce detector output.');
    }

    debugPrint(
      'Produce detection score: '
      '${(produceScore * 100).toStringAsFixed(2)}%',
    );

    if (produceScore < produceThreshold) {
      return CnnPrediction(
        label: 'No fruit or vegetable detected',
        confidence: 1.0 - produceScore,
        classIndex: -1,
        isProduce: false,
        produceScore: produceScore,
      );
    }

    // -----------------------------------------
    // STAGE B: CNN V4 CLASSIFICATION
    // -----------------------------------------

    final classifierOutput = [List<double>.filled(classCount, 0.0)];

    _classifier!.run(input, classifierOutput);

    final scores = classifierOutput[0];

    var bestIndex = 0;

    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIndex]) {
        bestIndex = i;
      }
    }

    final confidence = scores[bestIndex];

    if (!confidence.isFinite || confidence < 0.0 || confidence > 1.0) {
      throw StateError('Invalid CNN V4 classification output.');
    }

    final prediction = CnnPrediction(
      label: _labels[bestIndex],
      confidence: confidence,
      classIndex: bestIndex,
      isProduce: true,
      produceScore: produceScore,
    );

    debugPrint(
      'CNN V4 prediction: ${prediction.label} '
      '(${(confidence * 100).toStringAsFixed(2)}%)',
    );

    return prediction;
  }

  void dispose() {
    _detector?.close();
    _classifier?.close();

    _detector = null;
    _classifier = null;
    _labels = [];
  }
}
