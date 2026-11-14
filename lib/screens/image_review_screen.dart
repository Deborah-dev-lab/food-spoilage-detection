import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cnn_inference_service.dart';
import '../theme/app_theme.dart';

import 'assessment_result_screen.dart';
import 'no_produce_detected_screen.dart';
import 'spoilage_alert_screen.dart';
import 'uncertain_result_screen.dart';

class ImageReviewScreen extends StatefulWidget {
  final String imagePath;

  const ImageReviewScreen({super.key, required this.imagePath});

  @override
  State<ImageReviewScreen> createState() => _ImageReviewScreenState();
}

class _ImageReviewScreenState extends State<ImageReviewScreen> {
  static const Color forest = AppTheme.forest;
  static const Color ivory = Color(0xFFF7F8F4);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color muted = AppTheme.muted;
  static const Color border = AppTheme.border;

  // Provisional confidence threshold.
  // This is not a validated non-produce detection threshold.
  static const double uncertainThreshold = 0.65;

  final ImagePicker _picker = ImagePicker();
  final CnnInferenceService _cnnService = CnnInferenceService();

  late String _imagePath;

  bool _isPickingImage = false;
  bool _isAnalysing = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  @override
  void dispose() {
    _cnnService.dispose();
    super.dispose();
  }

  Future<void> _changePhoto(ImageSource source) async {
    if (_isPickingImage || _isAnalysing) return;

    setState(() {
      _isPickingImage = true;
      _errorMessage = null;
    });

    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
          _errorMessage = null;
        });
      }
    } catch (error) {
      debugPrint('Image selection error: $error');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not open the selected image. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _showNoProduceScreen({
    required String imagePath,
    required bool isUncertain,
  }) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoProduceDetectedScreen(
          imagePath: imagePath,
          isUncertain: isUncertain,
          onRetry: () {
            if (!mounted) return;

            // Close the result screen and return to
            // this review screen, where the user can
            // retake or select another photograph.
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _analyseImage() async {
    if (_isAnalysing || _isPickingImage) return;

    final analysedImagePath = _imagePath;

    setState(() {
      _isAnalysing = true;
      _errorMessage = null;
    });

    try {
      final file = File(analysedImagePath);

      if (!await file.exists()) {
        throw const FileSystemException(
          'The selected image could not be found.',
        );
      }

      final imageBytes = await file.readAsBytes();

      if (imageBytes.isEmpty) {
        throw const FormatException('The selected image is empty.');
      }

      final prediction = await _cnnService.predict(imageBytes);

      if (!mounted) return;

      final label = prediction.label.trim();
      final confidence = prediction.confidence;

      if (label.isEmpty ||
          !confidence.isFinite ||
          confidence < 0 ||
          confidence > 1) {
        await _showNoProduceScreen(
          imagePath: analysedImagePath,
          isUncertain: true,
        );
        return;
      }

      // A low-confidence prediction is inconclusive.
      // It does not establish that no produce is present.
      if (confidence < uncertainThreshold) {
        await _showNoProduceScreen(
          imagePath: analysedImagePath,
          isUncertain: true,
        );
        return;
      }

      final normalizedLabel = label.toLowerCase();

      // This mapping follows the naming convention in
      // your existing implementation. It should be checked
      // against the actual labels.txt file.
      final isSpoiled =
          normalizedLabel.contains('rotten') ||
          normalizedLabel.contains('spoiled') ||
          normalizedLabel.contains('bad');

      if (isSpoiled) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SpoilageAlertScreen(
              imagePath: analysedImagePath,
              produceName: label,
              confidence: confidence,
              isDemo: false,
            ),
          ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AssessmentResultScreen(
              imagePath: analysedImagePath,
              result: AssessmentResult(
                produceName: label,
                status: FreshnessStatus.fresh,
                confidence: confidence,
                isDemo: false,
              ),
            ),
          ),
        );
      }
    } catch (error) {
      debugPrint('CNN analysis error: $error');

      if (!mounted) return;

      setState(() {
        _errorMessage =
            'We could not analyse this photo. '
            'Please try again or select another image.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalysing = false;
        });
      }
    }
  }

  Future<void> _showDemoOptions() async {
    if (_isAnalysing || _isPickingImage) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ivory,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Demo result screens',
                  style: TextStyle(
                    color: forest,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These are simulated results for '
                  'interface testing only. They do not '
                  'represent a real CNN assessment.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: forest,
                  ),
                  title: const Text('Fresh result'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.of(context).push(
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
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Spoilage alert'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SpoilageAlertScreen(
                          imagePath: _imagePath,
                          produceName: 'Selected produce (demo)',
                          confidence: 0.94,
                          isDemo: true,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.orange),
                  title: const Text('Uncertain result'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UncertainResultScreen(
                          imagePath: _imagePath,
                          produceName: 'Selected produce (demo)',
                          confidence: 0.48,
                          isDemo: true,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.image_search_outlined,
                    color: forest,
                  ),
                  title: const Text('No produce / inconclusive screen'),
                  subtitle: const Text(
                    'Preview the new assessment-unavailable UI',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showNoProduceScreen(
                      imagePath: _imagePath,
                      isUncertain: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          height: 280,
          width: double.infinity,
          child: Image.file(
            File(_imagePath),
            key: ValueKey(_imagePath),
            fit: BoxFit.contain,
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
      ),
    );
  }

  Widget _buildPhotoActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalysing || _isPickingImage
                ? null
                : () => _changePhoto(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Retake'),
            style: OutlinedButton.styleFrom(
              foregroundColor: forest,
              side: const BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalysing || _isPickingImage
                ? null
                : () => _changePhoto(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: forest,
              side: const BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo quality checklist',
            style: TextStyle(
              color: forest,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          _ChecklistItem(icon: Icons.wb_sunny_outlined, text: 'Good lighting'),
          _ChecklistItem(
            icon: Icons.center_focus_strong_rounded,
            text: 'Clear focus',
          ),
          _ChecklistItem(
            icon: Icons.crop_free_rounded,
            text: 'One main item in the image',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE5E2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFA34439),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFA34439),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyseButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _isAnalysing || _isPickingImage ? null : _analyseImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: forest,
          foregroundColor: Colors.white,
          disabledBackgroundColor: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: _isAnalysing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome_outlined),
        label: Text(
          _isAnalysing ? 'Analysing image...' : 'Analyse freshness',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
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
          'Review your photo',
          style: TextStyle(
            color: forest,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(21, 15, 21, 30),
          children: [
            const Text(
              'READY TO ANALYSE?',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Looking good?',
              style: TextStyle(
                color: forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure your produce is clearly visible '
              'before continuing.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 22),
            _buildPhotoPreview(),
            const SizedBox(height: 15),
            _buildPhotoActions(),
            const SizedBox(height: 24),
            _buildChecklist(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 18),
              _buildErrorMessage(),
            ],
            const SizedBox(height: 24),
            _buildAnalyseButton(),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _isAnalysing || _isPickingImage
                  ? null
                  : _showDemoOptions,
              child: const Text(
                'Preview demo result screens',
                style: TextStyle(
                  color: forest,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'AI predictions are based on visible appearance '
              'and do not guarantee food safety.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChecklistItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.forest, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.forest,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
