import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'assessment_result_screen.dart';
import 'spoilage_alert_screen.dart';
import 'uncertain_result_screen.dart';

class ImageReviewScreen extends StatefulWidget {
  final String imagePath;

  const ImageReviewScreen({super.key, required this.imagePath});

  @override
  State<ImageReviewScreen> createState() => _ImageReviewScreenState();
}

class _ImageReviewScreenState extends State<ImageReviewScreen> {
  final ImagePicker _picker = ImagePicker();

  late String _imagePath;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  Future<void> _changePhoto(ImageSource source) async {
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
        setState(() => _imagePath = photo.path);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open image: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showFreshResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentResultScreen(
          imagePath: _imagePath,
          result: const AssessmentResult(
            produceName: 'Selected produce (demo)',
            status: FreshnessStatus.fresh,
            confidence: 0.91,
            isDemo: true,
          ),
        ),
      ),
    );
  }

  void _showSpoilageAlert() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpoilageAlertScreen(
          imagePath: _imagePath,
          produceName: 'Selected produce (demo)',
          confidence: 0.94,
          isDemo: true,
        ),
      ),
    );
  }

  void _showUncertainResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UncertainResultScreen(
          imagePath: _imagePath,
          produceName: 'Selected produce (demo)',
          confidence: 0.48,
          isDemo: true,
        ),
      ),
    );
  }

  Widget _photoTip(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.sage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.forest, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.forest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color background,
    required Color foreground,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPickingImage ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppTheme.border,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 19),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Review your photo',
          style: TextStyle(
            color: AppTheme.forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
          children: [
            const Text(
              'BEFORE YOUR ASSESSMENT',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Looking good?',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure the food is clearly visible '
              'before continuing.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: SizedBox(
                width: double.infinity,
                height: 245,
                child: Image.file(
                  File(_imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.sage,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 58,
                      color: AppTheme.forest,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isPickingImage
                        ? null
                        : () => _changePhoto(ImageSource.camera),
                    child: const Text('Retake photo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isPickingImage
                        ? null
                        : () => _changePhoto(ImageSource.gallery),
                    child: const Text('Gallery'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo quality checklist',
                    style: TextStyle(
                      color: AppTheme.forest,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _photoTip(
                    Icons.wb_sunny_outlined,
                    'Good lighting',
                    'The food should be well lit.',
                  ),
                  _photoTip(
                    Icons.center_focus_strong_rounded,
                    'Clear focus',
                    'Avoid blurry or distant images.',
                  ),
                  _photoTip(
                    Icons.crop_free_rounded,
                    'One main item',
                    'Keep the produce centred in the photo.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.sage,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.science_outlined, color: AppTheme.forest),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DEMO MODE\n'
                      'Choose a result below to preview its '
                      'screen. No CNN analysis is performed '
                      'on your photo yet.',
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

            const SizedBox(height: 20),

            const Text(
              'Preview a result',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select one of the three demonstration outcomes.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),

            _previewButton(
              label: 'Fresh result',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _showFreshResult,
              background: AppTheme.forest,
              foreground: Colors.white,
            ),
            const SizedBox(height: 11),
            _previewButton(
              label: 'Spoilage alert',
              icon: Icons.warning_amber_rounded,
              onPressed: _showSpoilageAlert,
              background: const Color(0xFFFBE5E2),
              foreground: const Color(0xFFA34439),
            ),
            const SizedBox(height: 11),
            _previewButton(
              label: 'Uncertain result',
              icon: Icons.help_outline_rounded,
              onPressed: _showUncertainResult,
              background: const Color(0xFFFFF0D8),
              foreground: const Color(0xFF91621D),
            ),
            const SizedBox(height: 14),
            const Text(
              'All outcomes shown above are simulated.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
