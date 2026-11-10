import 'dart:io';

import 'package:flutter/material.dart';

import '../services/assessment_storage.dart';
import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'feedback_screen.dart';

enum FreshnessStatus { fresh, spoiling, spoiled, uncertain }

class AssessmentResult {
  final String produceName;
  final FreshnessStatus status;
  final double? confidence;
  final bool isDemo;

  const AssessmentResult({
    required this.produceName,
    required this.status,
    this.confidence,
    this.isDemo = false,
  });
}

class AssessmentResultScreen extends StatefulWidget {
  final String imagePath;
  final AssessmentResult result;

  const AssessmentResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  static const Color forest = AppTheme.forest;
  static const Color ivory = Color(0xFFF7F8F4);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color muted = AppTheme.muted;

  static const Color freshGreen = Color(0xFF28764A);
  static const Color warningOrange = Color(0xFFB77B28);
  static const Color spoiledRed = Color(0xFFA34439);
  static const Color uncertainBlue = Color(0xFF586B7D);

  bool _isSaving = false;
  bool _isSaved = false;
  String? _saveError;
  int? _savedAssessmentId;

  @override
  void initState() {
    super.initState();

    if (!widget.result.isDemo) {
      _saveAssessment();
    }
  }

  Future<void> _saveAssessment() async {
    if (_isSaving || _isSaved || widget.result.isDemo) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final assessmentId = await AssessmentStorage.saveAssessment(
        produceName: widget.result.produceName,
        freshnessStatus: widget.result.status.name,
        confidence: widget.result.confidence,
        imagePath: widget.imagePath,
      );

      if (!mounted) return;

      setState(() {
        _savedAssessmentId = assessmentId;
        _isSaved = true;
        _isSaving = false;
      });
    } catch (error) {
      debugPrint('Failed to save assessment: $error');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _saveError = 'Could not save this assessment to local history.';
      });
    }
  }

  String get formattedProduceName {
    String name = widget.result.produceName.trim();

    name = name.replaceAll('_', ' ');
    name = name.replaceAll('-', ' ');

    name = name.replaceFirst(
      RegExp(r'^(fresh|rotten|spoiled|bad|good)\s+', caseSensitive: false),
      '',
    );

    name = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
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

  String get statusTitle {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return 'Appears fresh';
      case FreshnessStatus.spoiling:
        return 'Possible spoilage';
      case FreshnessStatus.spoiled:
        return 'Likely spoiled';
      case FreshnessStatus.uncertain:
        return 'Result uncertain';
    }
  }

  String get statusSubtitle {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return 'The model identified visual patterns '
            'associated with fresh produce.';
      case FreshnessStatus.spoiling:
        return 'The image may contain early signs '
            'of deterioration.';
      case FreshnessStatus.spoiled:
        return 'The model identified visual patterns '
            'associated with spoiled produce.';
      case FreshnessStatus.uncertain:
        return 'The model could not determine the '
            'produce condition with sufficient certainty.';
    }
  }

  String get statusLabel {
    return widget.result.status.name.toUpperCase();
  }

  Color get statusColor {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return freshGreen;
      case FreshnessStatus.spoiling:
        return warningOrange;
      case FreshnessStatus.spoiled:
        return spoiledRed;
      case FreshnessStatus.uncertain:
        return uncertainBlue;
    }
  }

  Color get statusBackground {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return const Color(0xFFE6F2E4);
      case FreshnessStatus.spoiling:
        return const Color(0xFFFFF0D8);
      case FreshnessStatus.spoiled:
        return const Color(0xFFFBE5E2);
      case FreshnessStatus.uncertain:
        return const Color(0xFFE8EDF2);
    }
  }

  IconData get statusIcon {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return Icons.check_circle_rounded;
      case FreshnessStatus.spoiling:
        return Icons.info_rounded;
      case FreshnessStatus.spoiled:
        return Icons.warning_amber_rounded;
      case FreshnessStatus.uncertain:
        return Icons.help_rounded;
    }
  }

  List<String> get recommendations {
    switch (widget.result.status) {
      case FreshnessStatus.fresh:
        return [
          'Check for unusual odours, mould, or soft spots before use.',
          'Store the produce appropriately to maintain freshness.',
          'Wash and prepare the produce using safe food-handling practices.',
        ];

      case FreshnessStatus.spoiling:
        return [
          'Inspect the produce carefully for visible deterioration.',
          'Check for unusual odours, mould, and significant softening.',
          'If the food appears unsafe or its condition is doubtful, discard it.',
        ];

      case FreshnessStatus.spoiled:
        return [
          'Avoid consuming produce with clear signs of spoilage.',
          'Discard badly deteriorated or visibly mouldy produce safely.',
          'Clean surfaces and containers that contacted spoiled food.',
        ];

      case FreshnessStatus.uncertain:
        return [
          'Retake the photo in good lighting.',
          'Keep one produce item centred and clearly visible.',
          'Inspect the food manually rather than relying on this prediction.',
        ];
    }
  }

  void _scanAnotherItem(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
      (route) => route.isFirst,
    );
  }

  void _openFeedback(BuildContext context) {
    if (widget.result.isDemo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback is available for real assessments, '
            'not demo previews.',
          ),
          behavior: SnackBarBehavior.floating,
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
                'Please wait until the assessment '
                    'is saved before giving feedback.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          assessmentId: assessmentId,
          produceName: formattedProduceName,
          assessmentStatus: widget.result.status.name,
        ),
      ),
    );
  }

  Widget _buildSaveStatus() {
    final hasError = _saveError != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFFF0D8) : AppTheme.sage,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          if (_isSaving)
            const SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.forest,
              ),
            )
          else
            Icon(
              hasError
                  ? Icons.error_outline_rounded
                  : _isSaved
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: hasError ? const Color(0xFF94631B) : AppTheme.forest,
              size: 21,
            ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _isSaving
                  ? 'Saving assessment locally...'
                  : hasError
                  ? _saveError!
                  : _isSaved
                  ? 'Assessment saved to local history'
                  : 'Preparing assessment record...',
              style: const TextStyle(
                color: AppTheme.forest,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (hasError && !_isSaving)
            TextButton(onPressed: _saveAssessment, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            SizedBox(
              height: 245,
              width: double.infinity,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: sage,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 55,
                        color: forest,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 13,
              bottom: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: forest.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 7),
                    Text(
                      'Analysed image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final rawScore = widget.result.confidence;

    final double? score = rawScore != null && rawScore.isFinite
        ? rawScore.clamp(0.0, 1.0).toDouble()
        : null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: statusBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRESHTRACK ASSESSMENT',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.result.isDemo
                          ? 'Simulated result'
                          : 'Image analysis complete',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (widget.result.isDemo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'DEMO',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            statusTitle,
            style: const TextStyle(
              color: forest,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            statusSubtitle,
            style: const TextStyle(
              color: Color(0xFF536A5A),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 21),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_outlined, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    formattedProduceName,
                    style: const TextStyle(
                      color: forest,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 22),
            Divider(color: statusColor.withValues(alpha: 0.17)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Model score',
                  style: TextStyle(
                    color: forest,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(score * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: forest,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: score,
                minHeight: 8,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is the model output score for its '
              'selected class, not a verified measure '
              'of prediction accuracy or food safety.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInformationCards() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.spa_outlined,
            label: 'Produce',
            value: formattedProduceName,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.center_focus_strong_rounded,
            label: 'Condition',
            value: statusLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return _SectionCard(
      icon: Icons.fact_check_outlined,
      title: 'What should you do?',
      subtitle: 'Practical next steps for your produce.',
      child: Column(
        children: List.generate(recommendations.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == recommendations.length - 1 ? 0 : 17,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: sage,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: forest,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendations[index],
                    style: const TextStyle(
                      color: Color(0xFF526557),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E3),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF94631B), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A quick safety reminder',
                  style: TextStyle(
                    color: Color(0xFF80571E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'FreshTrack assesses visible appearance. '
                  'A photograph cannot detect every harmful '
                  'microorganism, toxin, or contaminant. '
                  'Do not rely on this result alone to '
                  'decide whether food is safe to eat.',
                  style: TextStyle(
                    color: Color(0xFF80571E),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: sage,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              color: forest,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Was this result helpful?',
                  style: TextStyle(
                    color: forest,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tell us how we did.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 9),
                InkWell(
                  onTap: () => _openFeedback(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Give feedback',
                        style: TextStyle(
                          color: forest,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: forest,
                      ),
                    ],
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
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assessment result',
          style: TextStyle(
            color: forest,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
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
              'Here is what\nwe found.',
              style: TextStyle(
                color: forest,
                fontSize: 33,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A closer look at the visible condition '
              'of your produce.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 23),
            _buildImagePreview(),
            const SizedBox(height: 18),

            if (!widget.result.isDemo) ...[
              _buildSaveStatus(),
              const SizedBox(height: 18),
            ],

            _buildResultCard(),
            const SizedBox(height: 16),
            _buildInformationCards(),
            const SizedBox(height: 18),

            const _SectionCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Understanding your result',
              subtitle: 'How FreshTrack makes its assessment.',
              child: Text(
                'FreshTrack uses a convolutional neural '
                'network (CNN) to classify visual patterns '
                'in fruit and vegetable images.\n\n'
                'The prediction is based on image features '
                'such as colour and surface appearance. '
                'It is an estimate and may be incorrect, '
                'especially when different produce items '
                'look similar.',
                style: TextStyle(
                  color: Color(0xFF526557),
                  fontSize: 13,
                  height: 1.65,
                ),
              ),
            ),

            const SizedBox(height: 18),
            _buildRecommendations(),
            const SizedBox(height: 18),
            _buildSafetyNotice(),
            const SizedBox(height: 18),
            _buildFeedbackCard(context),
            const SizedBox(height: 25),

            SizedBox(
              height: 57,
              child: ElevatedButton.icon(
                onPressed: () => _scanAnotherItem(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: const Text(
                  'Scan another item',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 11),

            SizedBox(
              height: 53,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: forest,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'Back to photo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.forest, size: 23),
          const SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppTheme.sage,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.forest, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.forest,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          child,
        ],
      ),
    );
  }
}
