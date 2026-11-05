import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _isPickingImage = false;

  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;

  static const Color amber = Color(0xFF93621B);
  static const Color amberLight = Color(0xFFFFF0D8);
  static const Color amberText = Color(0xFF795B2E);

  String get _formattedProduceName {
    var name = widget.produceName.trim().replaceAll(RegExp(r'[_-]+'), ' ');

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

  double? get _modelScore {
    final score = widget.confidence;

    if (score == null || !score.isFinite) {
      return null;
    }

    return score.clamp(0.0, 1.0).toDouble();
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          produceName: _formattedProduceName,
          assessmentStatus: 'Uncertain',
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
              width: double.infinity,
              height: 245,
              child: Image.file(
                File(widget.imagePath),
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

  Widget _buildUncertainCard() {
    final score = _modelScore;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: amberLight,
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
                  Icons.help_outline_rounded,
                  color: amber,
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
                        color: amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Further assessment needed',
                      style: TextStyle(color: amberText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (widget.isDemo)
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
                      color: amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Result uncertain',
            style: TextStyle(
              color: forest,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'The model did not produce a sufficiently '
            'strong prediction to report a freshness '
            'condition under the current threshold.',
            style: TextStyle(color: amberText, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_outlined, color: amber, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Possible match: $_formattedProduceName',
                    style: const TextStyle(
                      color: forest,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 21),
            Divider(color: amber.withValues(alpha: 0.20)),
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
                backgroundColor: amber.withValues(alpha: 0.16),
                valueColor: const AlwaysStoppedAnimation<Color>(amber),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isDemo
                  ? 'This is a simulated score for interface testing.'
                  : 'This score represents the selected class output. '
                        'It is not a calibrated probability that '
                        'the produce is fresh or spoiled.',
              style: const TextStyle(
                color: amberText,
                fontSize: 11,
                height: 1.5,
              ),
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
          child: _UncertainInfoCard(
            icon: Icons.spa_outlined,
            label: 'Possible produce',
            value: _formattedProduceName,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _UncertainInfoCard(
            icon: Icons.help_outline_rounded,
            label: 'Condition',
            value: 'UNCERTAIN',
          ),
        ),
      ],
    );
  }

  Widget _buildReason({
    required IconData icon,
    required String title,
    required String description,
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
                title,
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

  Widget _buildPossibleReasons() {
    return _UncertainSectionCard(
      icon: Icons.psychology_outlined,
      title: 'Why might this happen?',
      subtitle: 'Possible factors affecting the result.',
      child: Column(
        children: [
          _buildReason(
            icon: Icons.blur_on_rounded,
            title: 'Image is out of focus',
            description:
                'Blur may hide useful details on '
                'the surface of the produce.',
          ),
          const SizedBox(height: 23),
          _buildReason(
            icon: Icons.wb_sunny_outlined,
            title: 'Lighting conditions',
            description:
                'Strong shadows, glare or dim lighting '
                'may change how the image appears.',
          ),
          const SizedBox(height: 23),
          _buildReason(
            icon: Icons.crop_free_rounded,
            title: 'Produce is not clearly framed',
            description:
                'The item may be too far away, '
                'partially hidden or cropped.',
          ),
          const SizedBox(height: 23),
          _buildReason(
            icon: Icons.auto_awesome_outlined,
            title: 'Model limitations',
            description:
                'The model may confuse similar produce '
                'or encounter images unlike its '
                'training examples.',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return const _UncertainSectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Understanding your result',
      subtitle: 'What an uncertain prediction means.',
      child: Text(
        'FreshTrack uses a convolutional neural '
        'network (CNN) to analyse visual patterns '
        'in fruits and vegetables.\n\n'
        'When its highest class score is below '
        'the current acceptance threshold, '
        'FreshTrack reports the assessment as '
        'uncertain rather than assigning a '
        'freshness condition.\n\n'
        'This does not prove that the photograph '
        'is poor quality or that the item is '
        'outside the model\'s training data.',
        style: TextStyle(color: Color(0xFF526557), fontSize: 13, height: 1.65),
      ),
    );
  }

  Widget _buildPhotoTips() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, color: forest, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips for a better photo',
                  style: TextStyle(
                    color: forest,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Place one fruit or vegetable in '
                  'good, even lighting. Keep the '
                  'camera steady and ensure the '
                  'surface is visible. Avoid busy '
                  'backgrounds and strong shadows.',
                  style: TextStyle(color: forest, fontSize: 12, height: 1.6),
                ),
              ],
            ),
          ),
        ],
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
                  'Food safety reminder',
                  style: TextStyle(
                    color: Color(0xFF80571E),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'An uncertain result does not mean '
                  'that food is safe or unsafe. '
                  'FreshTrack cannot detect invisible '
                  'bacteria, toxins or contaminants. '
                  'Avoid consuming produce with '
                  'clear signs of spoilage.',
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

  Widget _buildFeedbackCard() {
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
                  'Share feedback about the prediction.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _openFeedback,
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
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
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
              'Let\'s take\nanother look.',
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
              'We could not establish a sufficiently '
              'strong freshness prediction from '
              'this image.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 23),
            _buildImagePreview(),
            const SizedBox(height: 18),
            _buildUncertainCard(),
            const SizedBox(height: 16),
            _buildInformationCards(),
            const SizedBox(height: 18),
            _buildExplanation(),
            const SizedBox(height: 18),
            _buildPossibleReasons(),
            const SizedBox(height: 18),
            _buildPhotoTips(),
            const SizedBox(height: 18),
            _buildSafetyNotice(),
            const SizedBox(height: 18),
            _buildFeedbackCard(),
            const SizedBox(height: 25),
            SizedBox(
              height: 57,
              child: ElevatedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _tryAgain(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  _isPickingImage ? 'Opening camera...' : 'Retake photo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () => _tryAgain(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  foregroundColor: forest,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text(
                  'Choose another photo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _isPickingImage ? null : _openCamera,
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

class _UncertainInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _UncertainInfoCard({
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

class _UncertainSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _UncertainSectionCard({
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
