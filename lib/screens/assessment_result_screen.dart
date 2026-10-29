import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'feedback_screen.dart';

// =====================================================
// ASSESSMENT DATA MODEL
// =====================================================

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

// =====================================================
// FRESHTRACK ASSESSMENT RESULTS SCREEN
// =====================================================

class AssessmentResultScreen extends StatelessWidget {
  final String imagePath;
  final AssessmentResult result;

  const AssessmentResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  // =====================================================
  // CLASSIFICATION LABEL
  // =====================================================

  String get statusTitle {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return 'Appears fresh';

      case FreshnessStatus.spoiling:
        return 'Signs of spoilage';

      case FreshnessStatus.spoiled:
        return 'Likely spoiled';

      case FreshnessStatus.uncertain:
        return 'Result uncertain';
    }
  }

  // =====================================================
  // CLASSIFICATION DESCRIPTION
  // =====================================================

  String get statusDescription {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return 'The image classification suggests that '
            'the produce appears visually fresh.';

      case FreshnessStatus.spoiling:
        return 'The classification suggests possible '
            'visible signs of deterioration.';

      case FreshnessStatus.spoiled:
        return 'The classification suggests visible '
            'patterns associated with spoiled produce.';

      case FreshnessStatus.uncertain:
        return 'The model could not confidently determine '
            'the visible freshness condition.';
    }
  }

  // =====================================================
  // STATUS COLOURS
  // =====================================================

  Color get statusColor {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return const Color(0xFF28764A);

      case FreshnessStatus.spoiling:
        return const Color(0xFF94631B);

      case FreshnessStatus.spoiled:
        return const Color(0xFFA34439);

      case FreshnessStatus.uncertain:
        return const Color(0xFF586B7D);
    }
  }

  Color get statusBackground {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return const Color(0xFFE4F1E4);

      case FreshnessStatus.spoiling:
        return const Color(0xFFFFF0D8);

      case FreshnessStatus.spoiled:
        return const Color(0xFFFBE5E2);

      case FreshnessStatus.uncertain:
        return const Color(0xFFE8EDF2);
    }
  }

  // =====================================================
  // STATUS ICON
  // =====================================================

  IconData get statusIcon {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return Icons.check_circle_outline_rounded;

      case FreshnessStatus.spoiling:
        return Icons.info_outline_rounded;

      case FreshnessStatus.spoiled:
        return Icons.warning_amber_rounded;

      case FreshnessStatus.uncertain:
        return Icons.help_outline_rounded;
    }
  }

  // =====================================================
  // RECOMMENDATIONS
  // =====================================================

  List<String> get recommendations {
    switch (result.status) {
      case FreshnessStatus.fresh:
        return [
          'Inspect the produce for unusual odours, '
              'mould or soft spots before use.',
          'Store it under appropriate conditions '
              'to maintain freshness.',
          'Follow normal food hygiene practices '
              'during preparation.',
        ];

      case FreshnessStatus.spoiling:
        return [
          'Inspect the produce carefully for mould, '
              'unusual odours or extensive deterioration.',
          'Do not consume produce with clear signs '
              'of unsafe spoilage.',
          'If its condition is doubtful, '
              'the safer option is to discard it.',
        ];

      case FreshnessStatus.spoiled:
        return [
          'Avoid consuming produce that shows '
              'clear signs of spoilage.',
          'Discard visibly mouldy or badly '
              'deteriorated produce safely.',
          'Clean any surfaces or containers '
              'that contacted spoiled food.',
        ];

      case FreshnessStatus.uncertain:
        return [
          'Take another photo using good lighting '
              'and a clear background.',
          'Keep the produce centred and in focus.',
          'Inspect the food manually and do not '
              'rely on an uncertain prediction.',
        ];
    }
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  void checkAnotherItem(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
      (route) => route.isFirst,
    );
  }

  void openFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          produceName: result.produceName,
          assessmentStatus: statusTitle,
        ),
      ),
    );
  }

  // =====================================================
  // BUILD SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final double? confidence = result.confidence?.clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.ivory,

      // ================================================
      // APP BAR
      // ================================================
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Freshness assessment',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.forest,
          ),
        ),
      ),

      // ================================================
      // MAIN CONTENT
      // ================================================
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            // ------------------------------------------
            // PAGE HEADER
            // ------------------------------------------

            const Text(
              'FOOD QUALITY REPORT',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your food,\nexplained.',
              style: TextStyle(
                fontSize: 33,
                height: 1.1,
                letterSpacing: -1,
                fontWeight: FontWeight.w800,
                color: AppTheme.forest,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'A closer look at the visible '
              'condition of your produce.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.muted,
              ),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------
            // ANALYSED FOOD IMAGE
            // ------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SizedBox(
                width: double.infinity,
                height: 240,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.sage,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 65,
                          color: AppTheme.forest,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------
            // CLASSIFICATION RESULT CARD
            // ------------------------------------------
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 24),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'VISUAL FRESHNESS RESULT',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      if (result.isDemo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
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

                  const SizedBox(height: 18),

                  Text(
                    statusTitle,
                    style: const TextStyle(
                      color: AppTheme.forest,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    statusDescription,
                    style: const TextStyle(
                      color: Color(0xFF587060),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),

                  // ------------------------------------
                  // CONFIDENCE SCORE
                  // ------------------------------------
                  if (confidence != null) ...[
                    const SizedBox(height: 22),

                    Divider(color: statusColor.withValues(alpha: 0.18)),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Model confidence',
                          style: TextStyle(
                            color: AppTheme.forest,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          '${(confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: AppTheme.forest,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: confidence,
                        minHeight: 8,
                        backgroundColor: statusColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),

                    const SizedBox(height: 11),

                    const Text(
                      'This score indicates model '
                      'confidence, not the probability '
                      'that food is safe.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------
            // ASSESSMENT INFORMATION
            // ------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.eco_outlined,
                    label: 'Produce',
                    value: result.produceName,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: _InfoCard(
                    icon: Icons.center_focus_strong_rounded,
                    label: 'Assessment',
                    value: 'Image-based',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ------------------------------------------
            // RESULT EXPLANATION
            // ------------------------------------------
            const _SectionCard(
              icon: Icons.search_rounded,
              title: 'Understanding this result',
              child: Text(
                'This assessment uses image-based '
                'classification to identify visual '
                'patterns associated with freshness '
                'or spoilage. Colour, surface appearance '
                'and texture may contribute to the '
                'classification where visible.\n\n'
                'It cannot directly detect bacteria, '
                'toxins or contamination that is '
                'not visible in a photograph.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.65,
                  color: AppTheme.muted,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------
            // RECOMMENDATIONS
            // ------------------------------------------
            _SectionCard(
              icon: Icons.fact_check_outlined,
              title: 'Recommended next steps',
              child: Column(
                children: recommendations.map((recommendation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF28764A),
                          size: 19,
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Text(
                            recommendation,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: Color(0xFF4D6354),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------
            // FOOD SAFETY NOTICE
            // ------------------------------------------
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E3),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF966824)),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Important food safety reminder',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF80571E),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text(
                    'A photograph cannot confirm that '
                    'food is safe to eat. Some harmful '
                    'microorganisms and contaminants '
                    'are not visible. Use this result '
                    'as additional guidance rather '
                    'than a definitive food safety test.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.65,
                      color: Color(0xFF80571E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // ASSESSMENT FEEDBACK SECTION - NEW
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: AppTheme.sage,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      size: 27,
                      color: AppTheme.forest,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'How helpful was this result?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forest,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Share your experience to help '
                    'evaluate and improve FreshTrack.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppTheme.muted,
                    ),
                  ),

                  const SizedBox(height: 17),

                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: OutlinedButton.icon(
                      onPressed: () => openFeedback(context),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text(
                        'Give feedback',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ------------------------------------------
            // CHECK ANOTHER ITEM
            // ------------------------------------------
            SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () => checkAnotherItem(context),
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: const Text('Check another item'),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------
            // BACK TO PHOTO
            // ------------------------------------------
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// REUSABLE INFORMATION CARD
// =====================================================

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
          Icon(icon, color: AppTheme.forest, size: 24),

          const SizedBox(height: 16),

          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.forest,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REUSABLE SECTION CARD
// =====================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
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
              Icon(icon, color: AppTheme.forest, size: 23),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.forest,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          child,
        ],
      ),
    );
  }
}
