import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';

class SpoilageAlertScreen extends StatelessWidget {
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

  static const Color alertRed = Color(0xFFAD3D35);
  static const Color alertLight = Color(0xFFFCE8E5);
  static const Color alertText = Color(0xFF7B2B26);

  void _scanAgain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
      (route) => route.isFirst,
    );
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _buildSafetyStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppTheme.sage,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppTheme.forest, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.forest,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.muted,
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

  @override
  Widget build(BuildContext context) {
    final normalizedConfidence = confidence?.clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Spoilage alert',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.forest,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            // ==========================================
            // WARNING HEADER
            // ==========================================
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: alertLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: alertRed,
                  size: 54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Spoilage warning',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: alertRed,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Visible signs of spoilage may have '
              'been detected in this food item.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 23),

            // ==========================================
            // RED ALERT CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: alertRed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.report_problem_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'LIKELY SPOILED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (isDemo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    produceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Do not rely on this image result '
                    'alone to decide whether food is '
                    'safe. If there are clear signs '
                    'of spoilage, avoid consuming it.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),

            // ==========================================
            // SELECTED FOOD PHOTO
            // ==========================================
            ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: SizedBox(
                width: double.infinity,
                height: 210,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.sage,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppTheme.forest,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 19),

            // ==========================================
            // CLASSIFICATION INFORMATION
            // ==========================================
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assessment details',
                    style: TextStyle(
                      color: AppTheme.forest,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 17),
                  _DetailLine(label: 'Produce', value: produceName),
                  const SizedBox(height: 12),
                  const _DetailLine(
                    label: 'Classification',
                    value: 'Likely spoiled',
                  ),
                  if (normalizedConfidence != null) ...[
                    const SizedBox(height: 12),
                    _DetailLine(
                      label: 'Model confidence',
                      value:
                          '${(normalizedConfidence * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                  const SizedBox(height: 15),
                  const Text(
                    'Model confidence measures certainty '
                    'in the predicted class, not the '
                    'probability that food is unsafe.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),

            // ==========================================
            // RECOMMENDED ACTIONS
            // ==========================================
            const Text(
              'What should you do?',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 21, 18, 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _buildSafetyStep(
                    icon: Icons.no_food_outlined,
                    title: 'Avoid consuming visibly spoiled food',
                    description:
                        'Do not taste food to check '
                        'whether it is safe.',
                  ),
                  _buildSafetyStep(
                    icon: Icons.delete_outline_rounded,
                    title: 'Dispose of spoiled produce',
                    description:
                        'If there is visible mould, '
                        'extensive decay or an unusual '
                        'odour, discard the item safely.',
                  ),
                  _buildSafetyStep(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clean affected surfaces',
                    description:
                        'Wash hands and clean any '
                        'containers or surfaces that '
                        'contacted the spoiled item.',
                  ),
                  _buildSafetyStep(
                    icon: Icons.visibility_outlined,
                    title: 'Inspect nearby produce',
                    description:
                        'Check other stored fruits and '
                        'vegetables for visible '
                        'deterioration.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),

            // ==========================================
            // FOOD SAFETY DISCLAIMER
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2DF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF8A5B1D),
                    size: 23,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'FreshTrack evaluates visible '
                      'image features only. It cannot '
                      'detect invisible bacteria, '
                      'toxins or chemical contamination. '
                      'A photograph is not a food '
                      'safety test.',
                      style: TextStyle(
                        color: Color(0xFF80571E),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // ==========================================
            // ACTION BUTTONS
            // ==========================================
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _scanAgain(context),
                icon: const Icon(Icons.center_focus_strong_rounded),
                label: const Text('Check another item'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _goHome(context),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
