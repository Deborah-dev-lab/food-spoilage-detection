import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../camera_screen.dart';
import '../learning_hub_screen.dart';

enum RecommendationCondition { fresh, spoiling, spoiled, uncertain }

class VendorRecommendation {
  final RecommendationCondition condition;
  final String title;
  final String description;
  final List<String> actions;
  final IconData icon;

  const VendorRecommendation({
    required this.condition,
    required this.title,
    required this.description,
    required this.actions,
    required this.icon,
  });
}

class VendorRecommendationsScreen extends StatefulWidget {
  const VendorRecommendationsScreen({super.key});

  @override
  State<VendorRecommendationsScreen> createState() =>
      _VendorRecommendationsScreenState();
}

class _VendorRecommendationsScreenState
    extends State<VendorRecommendationsScreen> {
  RecommendationCondition? selectedCondition;

  static const Color forest = AppTheme.forest;
  static const Color sage = AppTheme.sage;
  static const Color muted = AppTheme.muted;
  static const Color lime = Color(0xFFC6F0A5);

  static const List<VendorRecommendation> recommendations = [
    VendorRecommendation(
      condition: RecommendationCondition.fresh,
      title: 'Handling fresh produce',
      description:
          'Good handling and appropriate storage can help '
          'maintain the quality of suitable produce.',
      actions: [
        'Keep produce in clean storage and display areas.',
        'Follow storage guidance for each fruit or vegetable.',
        'Rotate stock using purchase or arrival dates.',
        'Inspect produce regularly for deterioration.',
      ],
      icon: Icons.eco_outlined,
    ),
    VendorRecommendation(
      condition: RecommendationCondition.spoiling,
      title: 'Produce showing deterioration',
      description:
          'Changes in appearance may indicate declining '
          'quality and require closer inspection.',
      actions: [
        'Separate concerning items from saleable stock.',
        'Inspect for mould, leakage, unusual texture or odour.',
        'Review storage conditions and handling practices.',
        'Do not sell or process produce that appears unsafe.',
      ],
      icon: Icons.warning_amber_rounded,
    ),
    VendorRecommendation(
      condition: RecommendationCondition.spoiled,
      title: 'Handling suspected spoiled produce',
      description:
          'Suspected spoiled produce should not be '
          'treated as safe based on an image assessment.',
      actions: [
        'Remove suspected spoiled items from saleable stock.',
        'Avoid using rotten or mouldy produce for processing.',
        'Clean affected storage and preparation surfaces.',
        'Follow appropriate local waste disposal practices.',
      ],
      icon: Icons.delete_outline_rounded,
    ),
    VendorRecommendation(
      condition: RecommendationCondition.uncertain,
      title: 'When the assessment is uncertain',
      description:
          'An uncertain model result means the image '
          'does not provide a sufficiently reliable classification.',
      actions: [
        'Capture another clear photograph in good lighting.',
        'Check that the produce is visible and unobstructed.',
        'Inspect the produce manually for warning signs.',
        'Do not rely on a model score as proof of safety.',
      ],
      icon: Icons.help_outline_rounded,
    ),
  ];

  String _conditionLabel(RecommendationCondition condition) {
    switch (condition) {
      case RecommendationCondition.fresh:
        return 'Fresh';
      case RecommendationCondition.spoiling:
        return 'Spoiling';
      case RecommendationCondition.spoiled:
        return 'Spoiled';
      case RecommendationCondition.uncertain:
        return 'Uncertain';
    }
  }

  Color _conditionColor(RecommendationCondition condition) {
    switch (condition) {
      case RecommendationCondition.fresh:
        return const Color(0xFF287C50);
      case RecommendationCondition.spoiling:
        return const Color(0xFF93621B);
      case RecommendationCondition.spoiled:
        return const Color(0xFFB44848);
      case RecommendationCondition.uncertain:
        return const Color(0xFF536B83);
    }
  }

  Color _conditionBackground(RecommendationCondition condition) {
    switch (condition) {
      case RecommendationCondition.fresh:
        return const Color(0xFFE5F3E8);
      case RecommendationCondition.spoiling:
        return const Color(0xFFFFF0D8);
      case RecommendationCondition.spoiled:
        return const Color(0xFFFBE8E8);
      case RecommendationCondition.uncertain:
        return const Color(0xFFE8EEF5);
    }
  }

  void _startScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _openLearningHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LearningHubScreen()),
    );
  }

  Widget _buildRecommendationCard(VendorRecommendation recommendation) {
    final condition = recommendation.condition;
    final color = _conditionColor(condition);
    final background = _conditionBackground(condition);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(recommendation.icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _conditionLabel(condition),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            recommendation.description,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recommended actions',
            style: TextStyle(
              color: forest,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...recommendation.actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(
                        color: forest,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningHubCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: forest, size: 27),
              SizedBox(width: 10),
              Text(
                'LEARN & EXPLORE',
                style: TextStyle(
                  color: forest,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Food safety & value addition',
            style: TextStyle(
              color: forest,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Explore practical articles on safe food '
            'handling, storage, fruit processing '
            'and reducing post-harvest losses.',
            style: TextStyle(color: forest, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openLearningHub,
              style: ElevatedButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'Explore articles',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecommendations = recommendations
        .where(
          (recommendation) =>
              selectedCondition == null ||
              recommendation.condition == selectedCondition,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'Recommendations',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
          children: [
            const Text(
              'VENDOR GUIDANCE',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Make informed\nstock decisions.',
              style: TextStyle(
                color: forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Review general produce-handling guidance '
              'based on different freshness conditions.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 23),

            // SCAN SHORTCUT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: lime, size: 29),
                  const SizedBox(height: 12),
                  const Text(
                    'Not sure about your produce?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture an image for a visual '
                    'CNN-based freshness assessment.',
                    style: TextStyle(color: sage, fontSize: 12, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lime,
                        foregroundColor: forest,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text(
                        'Scan produce',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Handling recommendations',
              style: TextStyle(
                color: forest,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a condition to explore guidance.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 15),

            // CONDITION FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: selectedCondition == null,
                      selectedColor: sage,
                      onSelected: (_) {
                        setState(() {
                          selectedCondition = null;
                        });
                      },
                    ),
                  ),
                  ...RecommendationCondition.values.map(
                    (condition) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_conditionLabel(condition)),
                        selected: selectedCondition == condition,
                        selectedColor: sage,
                        onSelected: (_) {
                          setState(() {
                            selectedCondition = condition;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ...visibleRecommendations.map(_buildRecommendationCard),

            const SizedBox(height: 14),

            // LEARNING HUB - CONNECTED
            _buildLearningHubCard(),

            const SizedBox(height: 24),

            // SAFETY NOTE
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D8),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: Color(0xFF93621B),
                    size: 24,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'These recommendations provide '
                      'general information, not personalised '
                      'food-safety certification. Visual '
                      'assessments cannot detect all hazards. '
                      'Never use spoiled or unsafe produce '
                      'for value addition.',
                      style: TextStyle(
                        color: Color(0xFF78511B),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
