import 'dart:io';

import 'package:flutter/material.dart';

import '../services/assessment_storage.dart';
import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'feedback_screen.dart';

class SpoilageAlertScreen extends StatefulWidget {
  final String imagePath;
  final String produceName;
  final double? confidence;
  final bool isDemo;

  const SpoilageAlertScreen({
    super.key,
    required this.imagePath,
    required this.produceName,
    this.confidence,
    this.isDemo = false,
  });

  @override
  State<SpoilageAlertScreen> createState() => _SpoilageAlertScreenState();
}

class _SpoilageAlertScreenState extends State<SpoilageAlertScreen> {
  static const Color forest = AppTheme.forest;
  static const Color ivory = AppTheme.ivory;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;
  static const Color alertRed = Color(0xFFAD3D35);
  static const Color alertLight = Color(0xFFFCE8E5);

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
      'FRESHTRACK: Spoilage screen opened, '
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
        freshnessStatus: 'spoiled',
        confidence: _score,
        imagePath: widget.imagePath,
      );

      debugPrint(
        'FRESHTRACK: Spoiled assessment saved '
        'with ID $assessmentId',
      );

      if (!mounted) return;

      setState(() {
        _savedAssessmentId = assessmentId;
        _isSaved = true;
        _isSaving = false;
      });
    } catch (error, stackTrace) {
      debugPrint('FRESHTRACK: Spoilage save failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _saveError = 'Could not save this assessment.';
      });
    }
  }

  void _scanAgain() {
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
          assessmentStatus: 'spoiled',
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
    final color = hasError ? alertRed : forest;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (_isSaving)
            const SizedBox(
              width: 18,
              height: 18,
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

  Widget _buildAlertCard() {
    final score = _score;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: alertLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: alertRed,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'FRESHTRACK ASSESSMENT',
                  style: TextStyle(
                    color: alertRed,
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
            'Likely spoiled',
            style: TextStyle(
              color: forest,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The CNN identified visual patterns associated '
            'with spoiled produce. This prediction may be incorrect.',
            style: TextStyle(color: alertRed, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            'Produce: $_produceName',
            style: const TextStyle(
              color: forest,
              fontSize: 15,
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
              color: alertRed,
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 10),
            const Text(
              'This score is not a verified probability '
              'of spoilage or food-safety risk.',
              style: TextStyle(color: alertRed, fontSize: 11, height: 1.5),
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

  Widget _guidanceRow(IconData icon, String title, String description) {
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
          'Spoilage alert',
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
              'Something needs\na closer look.',
              style: TextStyle(
                color: forest,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Here is what the model predicted from your photo.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 22),
            _buildImagePreview(),
            _buildSaveStatus(),
            const SizedBox(height: 18),
            _buildAlertCard(),
            const SizedBox(height: 18),
            _section(
              icon: Icons.info_outline,
              title: 'Understanding this alert',
              child: const Text(
                'FreshTrack uses a convolutional neural network '
                '(CNN) to classify visual patterns in images. '
                'Colour and surface appearance may influence '
                'its prediction, and mistakes are possible.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.fact_check_outlined,
              title: 'What should you do?',
              child: Column(
                children: [
                  _guidanceRow(
                    Icons.visibility_outlined,
                    'Inspect before consuming',
                    'Check for mould, unusual odours and visible decay. '
                        'Do not taste food to test its safety.',
                  ),
                  _guidanceRow(
                    Icons.delete_outline,
                    'Discard clearly spoiled food',
                    'Avoid consuming produce showing clear signs '
                        'of deterioration.',
                  ),
                  _guidanceRow(
                    Icons.cleaning_services_outlined,
                    'Keep surfaces clean',
                    'Wash hands and clean surfaces that contacted '
                        'spoiled produce.',
                  ),
                  _guidanceRow(
                    Icons.spa_outlined,
                    'Check nearby produce',
                    'Inspect other stored items for signs of spoilage.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.shield_outlined,
              title: 'Important food safety reminder',
              child: const Text(
                'A photograph cannot confirm whether food is '
                'safe to eat. Invisible microorganisms, toxins '
                'and contaminants may be present. Treat this '
                'assessment as guidance, not a definitive test.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _section(
              icon: Icons.rate_review_outlined,
              title: 'Was this prediction correct?',
              child: TextButton.icon(
                onPressed: widget.isDemo || !_isSaved ? null : _openFeedback,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Give feedback'),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 57,
              child: ElevatedButton.icon(
                onPressed: _scanAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: const Text('Scan another item'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
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
