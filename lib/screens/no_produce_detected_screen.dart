import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';

class NoProduceDetectedScreen extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onRetry;
  final bool isUncertain;

  const NoProduceDetectedScreen({
    super.key,
    this.imagePath,
    this.onRetry,
    this.isUncertain = false,
  });

  static const Color forest = AppTheme.forest;
  static const Color sage = AppTheme.sage;
  static const Color muted = AppTheme.muted;
  static const Color border = AppTheme.border;

  void _returnHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _retry(BuildContext context) {
    if (onRetry != null) {
      onRetry!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final title = isUncertain
        ? 'We couldn\'t identify\nthis produce clearly.'
        : 'No supported produce\nidentified.';

    final description = isUncertain
        ? 'The image could not be identified with enough '
              'confidence. Try capturing another photograph '
              'with better lighting and a clearer view.'
        : 'FreshTrack could not reliably identify a '
              'supported fruit or vegetable in this image. '
              'Try another photograph with the produce '
              'clearly visible.';

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'Image assessment',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSESSMENT RESULT',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: sage,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imagePath != null && imagePath!.trim().isNotEmpty
                          ? Image.file(
                              File(imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _imagePlaceholder();
                              },
                            )
                          : _imagePlaceholder(),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0D8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF93621B),
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Assessment unavailable',
                            style: TextStyle(
                              color: Color(0xFF93621B),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 17),

                    Text(
                      title,
                      style: const TextStyle(
                        color: forest,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.7,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Text(
                      description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _tipsCard(),

                    const SizedBox(height: 22),

                    const Text(
                      'FreshTrack uses image-based classification '
                      'to assess supported produce. An unclear '
                      'result should not be treated as confirmation '
                      'of freshness or food safety.',
                      style: TextStyle(color: muted, fontSize: 11, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),

            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_search_outlined, color: forest, size: 68),
        SizedBox(height: 14),
        Text(
          'Image could not be assessed',
          style: TextStyle(
            color: forest,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: forest, size: 23),
              SizedBox(width: 10),
              Text(
                'Tips for a better scan',
                style: TextStyle(
                  color: forest,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 17),
          _TipRow(
            number: '01',
            text: 'Place the fruit or vegetable in good lighting.',
          ),
          SizedBox(height: 13),
          _TipRow(
            number: '02',
            text: 'Keep the produce clearly visible and in focus.',
          ),
          SizedBox(height: 13),
          _TipRow(
            number: '03',
            text: 'Avoid cluttered backgrounds and multiple objects.',
          ),
        ],
      ),
    );
  }

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        21,
        14,
        21,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _retry(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try another photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _returnHome(context),
              child: const Text(
                'Return to home',
                style: TextStyle(color: forest, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String number;
  final String text;

  const _TipRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 31,
          height: 31,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.sage,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
