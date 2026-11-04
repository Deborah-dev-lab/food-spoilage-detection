import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cnn_inference_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final CnnInferenceService _cnnService = CnnInferenceService();

  bool _isLoading = false;
  String _result = 'Select an image to test CNN V3';

  Future<void> _testPrediction() async {
    if (_isLoading) return;

    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _result = 'Analyzing image...';
      });

      final bytes = await image.readAsBytes();
      final prediction = await _cnnService.predict(bytes);

      if (!mounted) return;

      setState(() {
        _result =
            'Prediction: ${prediction.label}\n'
            'Confidence: ${(prediction.confidence * 100).toStringAsFixed(2)}%\n'
            'Class index: ${prediction.classIndex}';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _result = 'Prediction failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cnnService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FreshTrack CNN V3 Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_search, size: 72),
              const SizedBox(height: 24),
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testPrediction,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image'),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
