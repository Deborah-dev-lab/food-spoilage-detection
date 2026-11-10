import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/assessment_storage.dart';
import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'feedback_screen.dart';
import 'image_review_screen.dart';

class UncertainResultScreen extends StatefulWidget {
  final String imagePath;
  final String produceName;
  final double? confidence;
  final bool isDemo;

  const UncertainResultScreen({
    super.key,
    required this.imagePath,
    required this.produceName,
    this.confidence,
    this.isDemo = false,
  });

  @override
  State<UncertainResultScreen> createState() => _UncertainResultScreenState();
}

class _UncertainResultScreenState extends State<UncertainResultScreen> {
  static const Color forest = AppTheme.forest;
  static const Color ivory = AppTheme.ivory;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;
  static const Color amber = Color(0xFF93621B);
  static const Color amberLight = Color(0xFFFFF0D8);

  final ImagePicker _picker = ImagePicker();

  bool _isPickingImage = false;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _saveError;
  int? _savedAssessmentId;

  String get _produceName {
    var name = widget.produceName.trim();
    name = name.replaceAll(RegExp(r'[_-]+'), ' ');
    name = name.replaceFirst(
      RegExp(r'^(fresh|rotten|spoiled|bad|good)\s+', caseSensitive: false),
      '',
    );

    if (name.isEmpty) return 'Unknown produce';

    return name
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  double? get _score {
    final value = widget.confidence;
    if (value == null || !value.isFinite) return null;
    return value.clamp(0.0, 1.0).toDouble();
  }

  @override
  void initState() {
    super.initState();

    debugPrint(
      'FRESHTRACK: Uncertain screen opened, '
      'isDemo=${widget.isDemo}',
    );

    if (!widget.isDemo) {
      _saveAssessment();
    }
  }

  Future<void> _saveAssessment() async {
    if (_isSaving || _isSaved || widget.isDemo) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final assessmentId = await AssessmentStorage.saveAssessment(
        produceName: _produceName,
        freshnessStatus: 'uncertain',
        confidence: _score,
        imagePath: widget.imagePath,
      );

      debugPrint(
        'FRESHTRACK: Uncertain assessment saved '
        'with ID $assessmentId',
      );

      if (!mounted) return;

      setState(() {
        _savedAssessmentId = assessmentId;
        _isSaved = true;
        _isSaving = false;
      });
    } catch (error, stackTrace) {
      debugPrint('FRESHTRACK: Uncertain save failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _saveError = 'Could not save this assessment.';
      });
    }
  }

  Future<void> _tryAgain(ImageSource source) async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (photo != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ImageReviewScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (error) {
      debugPrint('FRESHTRACK: Image selection failed: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open image: $error')));
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _openCamera() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
      (route) => route.isFirst,
    );
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _openFeedback() {
    if (widget.isDemo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback is unavailable for demo assessments.'),
        ),
      );
      return;
    }

    final assessmentId = _savedAssessmentId;

    if (assessmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _saveError ??
                'Please wait until the assessment has been '
                    'saved before giving feedback.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          assessmentId: assessmentId,
          produceName: _produceName,
          assessmentStatus: 'uncertain',
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: double.infinity,
          height: 245,
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) {
              return Container(
                color: sage,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: forest,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSaveStatus() {
    if (widget.isDemo) return const SizedBox.shrink();

    final hasError = _saveError != null;
    final color = hasError ? Colors.red.shade700 : forest;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (_isSaving)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: forest),
            )
          else
            Icon(
              hasError
                  ? Icons.error_outline
                  : _isSaved
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: color,
              size: 19,
            ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _isSaved
                  ? 'Assessment saved to local history'
                  : hasError
                  ? _saveError!
                  : 'Saving assessment...',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasError)
            TextButton(onPressed: _saveAssessment, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildUncertainCard() {
    final score = _score;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: amberLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: amber, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'FRESHTRACK ASSESSMENT',
                  style: TextStyle(
                    color: amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.isDemo) const Chip(label: Text('DEMO')),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Result uncertain',
            style: TextStyle(
              color: forest,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The model did not produce a sufficiently '
            'strong prediction to assign a freshness '
            'condition under the current threshold.',
            style: TextStyle(color: amber, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            'Possible match: $_produceName',
            style: const TextStyle(
              color: forest,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 18),
            Text(
              'Model score: ${(score * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: forest,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: score,
              minHeight: 8,
              color: amber,
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isDemo
                  ? 'This is a simulated score for interface testing.'
                  : 'This score is not a calibrated probability '
                        'of freshness or spoilage.',
              style: const TextStyle(color: amber, fontSize: 11, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: forest, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _reason(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: forest, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: ivory,
        foregroundColor: forest,
        centerTitle: true,
        title: const Text(
          'Assessment result',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            const Text(
              'YOUR FRESHTRACK REPORT',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's take\nanother look.",
              style: TextStyle(
                color: forest,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We could not establish a sufficiently '
              'strong freshness prediction from this image.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 22),
            _buildImagePreview(),
            _buildSaveStatus(),
            const SizedBox(height: 18),
            _buildUncertainCard(),
            const SizedBox(height: 18),
            _section(
              icon: Icons.info_outline,
              title: 'Understanding your result',
              child: const Text(
                'FreshTrack uses a convolutional neural network '
                '(CNN) to analyse visual patterns in produce. '
                'When its highest class score is below the '
                'current acceptance threshold, the result '
                'is reported as uncertain.\n\n'
                'This does not prove the image is poor quality '
                'or that the item is outside the training data.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.psychology_outlined,
              title: 'Why might this happen?',
              child: Column(
                children: [
                  _reason(
                    Icons.blur_on,
                    'Image is out of focus',
                    'Blur may hide useful surface details.',
                  ),
                  _reason(
                    Icons.wb_sunny_outlined,
                    'Lighting conditions',
                    'Strong shadows or glare can affect the image.',
                  ),
                  _reason(
                    Icons.crop_free,
                    'Produce is not clearly framed',
                    'The item may be distant, hidden or cropped.',
                  ),
                  _reason(
                    Icons.auto_awesome_outlined,
                    'Model limitations',
                    'The model may confuse similar produce items '
                        'or unfamiliar images.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.tips_and_updates_outlined,
              title: 'Tips for a better photo',
              child: const Text(
                'Place one fruit or vegetable in good, even '
                'lighting. Keep the camera steady, ensure '
                'the surface is visible and avoid busy backgrounds.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.shield_outlined,
              title: 'Food safety reminder',
              child: const Text(
                'An uncertain result does not mean food is safe '
                'or unsafe. FreshTrack cannot detect invisible '
                'bacteria, toxins or contaminants. Avoid eating '
                'produce with clear signs of spoilage.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.rate_review_outlined,
              title: 'Was this result helpful?',
              child: TextButton.icon(
                onPressed: widget.isDemo || !_isSaved ? null : _openFeedback,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Give feedback'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 57,
              child: ElevatedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _tryAgain(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  _isPickingImage ? 'Opening camera...' : 'Retake photo',
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isPickingImage
                  ? null
                  : () => _tryAgain(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose another photo'),
            ),
            TextButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Open FreshTrack camera'),
            ),
            TextButton.icon(
              onPressed: _goHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
