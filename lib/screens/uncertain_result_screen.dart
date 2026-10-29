import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
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
  final ImagePicker _picker = ImagePicker();

  bool _isPickingImage = false;

  static const Color amber = Color(0xFF93621B);
  static const Color amberLight = Color(0xFFFFF0D8);

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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open image: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Widget _reason({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
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
            child: Icon(icon, size: 22, color: AppTheme.forest),
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
                    height: 1.55,
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
    final confidence = widget.confidence?.clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assessment result',
          style: TextStyle(
            color: AppTheme.forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
          children: [
            // ========================================
            // MAIN UNCERTAIN ICON
            // ========================================
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: amberLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: amber,
                  size: 53,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'We are not quite sure',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 11),

            const Text(
              'We could not confidently determine '
              'the freshness of this food item.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 22),

            // ========================================
            // UNCERTAIN RESULT CARD
            // ========================================
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: amberLight,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: const Color(0xFFEACF9F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: amber),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'RESULT UNCERTAIN',
                          style: TextStyle(
                            color: amber,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (widget.isDemo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              color: amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.produceName,
                    style: const TextStyle(
                      color: AppTheme.forest,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'There is not enough reliable '
                    'information to classify this item '
                    'as fresh, spoiling or spoiled.',
                    style: TextStyle(
                      color: Color(0xFF795B2E),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 19),

            // ========================================
            // PHOTO PREVIEW
            // ========================================
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: double.infinity,
                height: 210,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.sage,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppTheme.forest,
                        size: 55,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 19),

            // ========================================
            // CONFIDENCE INFORMATION
            // ========================================
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assessment confidence',
                    style: TextStyle(
                      color: AppTheme.forest,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 13),

                  if (confidence != null) ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Model confidence',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '${(confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: amber,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: confidence,
                        minHeight: 9,
                        backgroundColor: amberLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(amber),
                      ),
                    ),
                    const SizedBox(height: 13),
                  ],

                  Text(
                    widget.isDemo
                        ? 'This confidence value is simulated '
                              'for interface testing. It is not '
                              'calculated from your photograph.'
                        : 'A confidence score describes the '
                              'model prediction, not whether food '
                              'is safe to eat.',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ========================================
            // POSSIBLE CAUSES
            // ========================================
            const Text(
              'Why might this happen?',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _reason(
                    icon: Icons.blur_on_rounded,
                    title: 'Blurry photograph',
                    description:
                        'Important surface details may '
                        'not be clearly visible.',
                  ),
                  _reason(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Poor lighting',
                    description:
                        'Shadows or reflections can make '
                        'the image difficult to interpret.',
                  ),
                  _reason(
                    icon: Icons.crop_free_rounded,
                    title: 'Food not clearly visible',
                    description:
                        'The item may be too far away, '
                        'partially hidden or cropped.',
                  ),
                  _reason(
                    icon: Icons.psychology_outlined,
                    title: 'Uncertain classification',
                    description:
                        'The model may not have enough '
                        'evidence to distinguish between '
                        'freshness categories.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ========================================
            // IMPROVEMENT GUIDANCE
            // ========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.sage,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppTheme.forest,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Try taking another photo in '
                      'natural light, with the produce '
                      'in focus and the surface clearly '
                      'visible. A new photo may help '
                      'produce a more reliable result.',
                      style: TextStyle(
                        color: AppTheme.forest,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2DF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: amber,
                    size: 23,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'An uncertain result does not '
                      'mean that the food is safe or '
                      'unsafe. FreshTrack cannot detect '
                      'invisible contamination. Do not '
                      'consume food with clear signs '
                      'of spoilage.',
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

            // ========================================
            // RETRY BUTTONS
            // ========================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _tryAgain(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Retake photo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _tryAgain(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose another photo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to photo review'),
            ),
          ],
        ),
      ),
    );
  }
}
