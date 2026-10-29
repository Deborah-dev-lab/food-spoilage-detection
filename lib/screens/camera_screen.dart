import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'image_review_screen.dart';

class CameraScreen extends StatefulWidget {
  final bool openGallery;

  const CameraScreen({super.key, this.openGallery = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();

    if (widget.openGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pickImage(ImageSource.gallery);
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;

    setState(() => _isPicking = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (photo != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageReviewScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to open image: $e')));
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        centerTitle: true,
        title: const Text(
          'Scan your food',
          style: TextStyle(
            color: AppTheme.forest,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          children: [
            const Text(
              'A closer look\nat your food.',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 32,
                height: 1.12,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Take a clear photo of your fruit or vegetable '
              'to begin a freshness check.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            // PHOTO GUIDE
            Container(
              height: 330,
              decoration: BoxDecoration(
                color: AppTheme.sage,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PHOTO GUIDE',
                        style: TextStyle(
                          color: AppTheme.forest,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.38),
                    ),
                  ),

                  const Icon(
                    Icons.apple_rounded,
                    color: AppTheme.forest,
                    size: 145,
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(34, 58, 34, 58),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.forest.withValues(alpha: 0.38),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'KEEP YOUR FOOD INSIDE THE FRAME',
                        style: TextStyle(
                          color: AppTheme.forest,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // PHOTO TIPS
            const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppTheme.forest,
                  size: 22,
                ),
                SizedBox(width: 9),
                Text(
                  'For the best photo',
                  style: TextStyle(
                    color: AppTheme.forest,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const _TipRow(
              icon: Icons.wb_sunny_outlined,
              text: 'Use bright, natural lighting',
            ),
            const _TipRow(
              icon: Icons.center_focus_strong_rounded,
              text: 'Keep your produce in focus',
            ),
            const _TipRow(
              icon: Icons.filter_center_focus_rounded,
              text: 'Capture one item at a time',
            ),

            const SizedBox(height: 28),

            // TAKE PHOTO BUTTON
            SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(_isPicking ? 'Opening camera...' : 'Take a photo'),
              ),
            ),

            const SizedBox(height: 12),

            // GALLERY BUTTON
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from gallery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.forest, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}
