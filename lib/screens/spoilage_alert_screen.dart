import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'feedback_screen.dart';

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

  static const Color forest = AppTheme.forest;
  static const Color ivory = AppTheme.ivory;
  static const Color sage = AppTheme.sage;
  static const Color muted = AppTheme.muted;

  static const Color alertRed = Color(0xFFAD3D35);
  static const Color alertLight = Color(0xFFFCE8E5);
  static const Color alertText = Color(0xFF7B2B26);

  String get formattedProduceName {
    var name = produceName.trim().replaceAll(RegExp(r'[_-]+'), ' ');

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

  double? get modelScore {
    if (confidence == null || !confidence!.isFinite) {
      return null;
    }
    return confidence!.clamp(0.0, 1.0).toDouble();
  }

  void _scanAgain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
      (route) => route.isFirst,
    );
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _openFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          produceName: formattedProduceName,
          assessmentStatus: 'Likely spoiled',
        ),
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
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: sage,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: forest,
                        size: 55,
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
                    Icon(Icons.image_outlined, color: Colors.white, size: 15),
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

  Widget _buildAlertCard() {
    final score = modelScore;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: alertLight,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: alertRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRESHTRACK ASSESSMENT',
                      style: TextStyle(
                        color: alertRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Visual spoilage classification',
                      style: TextStyle(color: alertText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isDemo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: alertRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Likely spoiled',
            style: TextStyle(
              color: forest,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'The model identified image patterns '
            'associated with spoiled produce. '
            'This prediction may be incorrect.',
            style: TextStyle(color: alertText, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_outlined, color: alertRed, size: 18),
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
            Divider(color: alertRed.withValues(alpha: 0.18)),
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
                backgroundColor: alertRed.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(alertRed),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is the output score for the selected '
              'class, not a verified probability of '
              'spoilage or food-safety risk.',
              style: TextStyle(color: alertText, fontSize: 11, height: 1.5),
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
          child: _AlertInfoCard(
            icon: Icons.spa_outlined,
            label: 'Produce',
            value: formattedProduceName,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _AlertInfoCard(
            icon: Icons.center_focus_strong_rounded,
            label: 'Condition',
            value: 'SPOILED',
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: sage,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: forest, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. $title',
                style: const TextStyle(
                  color: forest,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(color: muted, fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return _AlertSectionCard(
      icon: Icons.fact_check_outlined,
      title: 'What should you do?',
      subtitle: 'Practical food-handling guidance.',
      child: Column(
        children: [
          _buildSafetyStep(
            number: 1,
            icon: Icons.no_food_outlined,
            title: 'Inspect before consuming',
            description:
                'Check for mould, unusual odours, '
                'extensive softening or visible decay. '
                'Do not taste food to test its safety.',
          ),
          const SizedBox(height: 22),
          _buildSafetyStep(
            number: 2,
            icon: Icons.delete_outline_rounded,
            title: 'Discard clearly spoiled food',
            description:
                'Avoid eating badly deteriorated produce. '
                'Dispose of items showing clear signs '
                'of unsafe spoilage.',
          ),
          const SizedBox(height: 22),
          _buildSafetyStep(
            number: 3,
            icon: Icons.cleaning_services_outlined,
            title: 'Keep surfaces clean',
            description:
                'Wash your hands and clean containers '
                'or surfaces that contacted spoiled food.',
          ),
          const SizedBox(height: 22),
          _buildSafetyStep(
            number: 4,
            icon: Icons.visibility_outlined,
            title: 'Check nearby produce',
            description:
                'Inspect other stored fruits and '
                'vegetables for signs of deterioration.',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return const _AlertSectionCard(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Understanding this alert',
      subtitle: 'How FreshTrack reached its prediction.',
      child: Text(
        'FreshTrack uses a convolutional neural '
        'network (CNN) to classify visual patterns '
        'in fruit and vegetable images.\n\n'
        'Features such as colour and surface '
        'appearance may influence the prediction. '
        'Different produce items can look similar, '
        'so the model may occasionally identify '
        'the wrong item or condition.',
        style: TextStyle(color: Color(0xFF526557), fontSize: 13, height: 1.65),
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
                  'Important food safety reminder',
                  style: TextStyle(
                    color: Color(0xFF80571E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A photograph cannot confirm whether '
                  'food is safe or unsafe to eat. '
                  'Some harmful microorganisms, toxins '
                  'and contaminants are not visible. '
                  'Use this assessment as additional '
                  'guidance, not a definitive test.',
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
                  'Was this prediction correct?',
                  style: TextStyle(
                    color: forest,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Help us evaluate FreshTrack.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 10),
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
                        color: forest,
                        size: 16,
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
          'Spoilage alert',
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
              'Something needs\na closer look.',
              style: TextStyle(
                color: forest,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Here is what the model predicted '
              'from your produce photo.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 23),
            _buildImagePreview(),
            const SizedBox(height: 18),
            _buildAlertCard(),
            const SizedBox(height: 16),
            _buildInformationCards(),
            const SizedBox(height: 18),
            _buildExplanation(),
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
                onPressed: () => _scanAgain(context),
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
                onPressed: () => _goHome(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: forest,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.home_outlined),
                label: const Text(
                  'Back to home',
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

class _AlertInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AlertInfoCard({
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

class _AlertSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _AlertSectionCard({
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
