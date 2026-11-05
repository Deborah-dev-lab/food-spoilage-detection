import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum FeedbackChoice { helpful, notHelpful }

enum PredictionAccuracy { correct, partiallyCorrect, incorrect }

enum ActualCondition { fresh, spoiling, spoiled, unsure }

class FeedbackScreen extends StatefulWidget {
  final String? produceName;
  final String? assessmentStatus;

  const FeedbackScreen({super.key, this.produceName, this.assessmentStatus});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();

  final TextEditingController _actualProduceController =
      TextEditingController();

  PredictionAccuracy? _predictionAccuracy;
  FeedbackChoice? _selectedChoice;
  ActualCondition? _actualCondition;

  bool _submitted = false;

  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;

  String get _predictedProduce {
    final value = widget.produceName?.trim();

    if (value == null || value.isEmpty) {
      return 'Not specified';
    }

    return value
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        );
  }

  String get _predictedCondition {
    final value = widget.assessmentStatus?.trim();

    if (value == null || value.isEmpty) {
      return 'Not specified';
    }

    return value;
  }

  bool get _showCorrections =>
      _predictionAccuracy == PredictionAccuracy.incorrect ||
      _predictionAccuracy == PredictionAccuracy.partiallyCorrect;

  @override
  void dispose() {
    _commentController.dispose();
    _actualProduceController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    FocusScope.of(context).unfocus();

    if (_predictionAccuracy == null) {
      _showMessage('Please rate the prediction accuracy.');
      return;
    }

    if (_selectedChoice == null) {
      _showMessage('Please indicate whether the result was helpful.');
      return;
    }

    // UI prototype:
    // The feedback is not yet saved to a local database
    // or submitted to a remote server.
    //
    // Database integration will be added later.
    //
    // Planned fields:
    // predictedProduce
    // predictedCondition
    // predictionAccuracy
    // actualProduce
    // actualCondition
    // helpful
    // comments
    // createdAt

    setState(() {
      _submitted = true;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _sectionTitle({required String title, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: forest,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.6),
          ),
        ],
      ],
    );
  }

  Widget _buildAssessmentSummary() {
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
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: forest, size: 22),
              SizedBox(width: 10),
              Text(
                'Assessment summary',
                style: TextStyle(
                  color: forest,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FeedbackDetailRow(
            label: 'Predicted produce',
            value: _predictedProduce,
          ),
          const SizedBox(height: 14),
          _FeedbackDetailRow(
            label: 'Predicted condition',
            value: _predictedCondition,
          ),
          const SizedBox(height: 15),
          const Text(
            'These details come from the assessment '
            'you are reviewing.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: 'Was the prediction correct?',
          subtitle:
              'Tell us whether FreshTrack identified '
              'the produce and its condition accurately.',
        ),
        const SizedBox(height: 16),
        _FeedbackSelectionTile(
          icon: Icons.check_circle_outline_rounded,
          title: 'Yes, it was correct',
          subtitle: 'The produce and condition were identified correctly.',
          selected: _predictionAccuracy == PredictionAccuracy.correct,
          onTap: () {
            setState(() {
              _predictionAccuracy = PredictionAccuracy.correct;
              _actualProduceController.clear();
              _actualCondition = null;
            });
          },
        ),
        const SizedBox(height: 11),
        _FeedbackSelectionTile(
          icon: Icons.rule_rounded,
          title: 'Partially correct',
          subtitle: 'Some details were right, but others were not.',
          selected: _predictionAccuracy == PredictionAccuracy.partiallyCorrect,
          onTap: () {
            setState(() {
              _predictionAccuracy = PredictionAccuracy.partiallyCorrect;
            });
          },
        ),
        const SizedBox(height: 11),
        _FeedbackSelectionTile(
          icon: Icons.cancel_outlined,
          title: 'No, it was incorrect',
          subtitle: 'The produce or freshness condition was wrong.',
          selected: _predictionAccuracy == PredictionAccuracy.incorrect,
          onTap: () {
            setState(() {
              _predictionAccuracy = PredictionAccuracy.incorrect;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCorrectionSection() {
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
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: forest, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Help us correct the result',
                  style: TextStyle(
                    color: forest,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'If you know the actual produce or condition, '
            'you can provide it below. Both fields are optional.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Actual produce',
            style: TextStyle(
              color: forest,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _actualProduceController,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(hint: 'e.g. Orange, Banana, Tomato'),
          ),
          const SizedBox(height: 15),
          const Text(
            'Actual freshness condition',
            style: TextStyle(
              color: forest,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _conditionChip(label: 'Fresh', value: ActualCondition.fresh),
              _conditionChip(
                label: 'Spoiling',
                value: ActualCondition.spoiling,
              ),
              _conditionChip(label: 'Spoiled', value: ActualCondition.spoiled),
              _conditionChip(label: 'Not sure', value: ActualCondition.unsure),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conditionChip({
    required String label,
    required ActualCondition value,
  }) {
    final selected = _actualCondition == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _actualCondition = value;
        });
      },
      selectedColor: sage,
      backgroundColor: AppTheme.ivory,
      side: BorderSide(color: selected ? forest : AppTheme.border),
      labelStyle: TextStyle(
        color: forest,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    );
  }

  Widget _buildHelpfulnessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: 'Was this assessment helpful?',
          subtitle:
              'Even if the prediction was incorrect, '
              'was the information easy to understand?',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _FeedbackOption(
                icon: Icons.thumb_up_alt_outlined,
                label: 'Yes',
                subtitle: 'Helpful',
                selected: _selectedChoice == FeedbackChoice.helpful,
                onTap: () {
                  setState(() {
                    _selectedChoice = FeedbackChoice.helpful;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeedbackOption(
                icon: Icons.thumb_down_alt_outlined,
                label: 'No',
                subtitle: 'Not helpful',
                selected: _selectedChoice == FeedbackChoice.notHelpful,
                onTap: () {
                  setState(() {
                    _selectedChoice = FeedbackChoice.notHelpful;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: 'Anything else to share?',
          subtitle:
              'Tell us what worked well or what '
              'FreshTrack could improve. Optional.',
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _commentController,
          minLines: 4,
          maxLines: 6,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            hint:
                'e.g. The model identified my orange '
                'as a bell pepper...',
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: forest, width: 1.5),
      ),
    );
  }

  Widget _buildPrototypeNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: forest, size: 23),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Feedback collection is currently in '
              'prototype mode. Your responses are '
              'not yet saved or transmitted. '
              'Local storage will be connected '
              'during database integration.',
              style: TextStyle(color: forest, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        const Text(
          'HELP IMPROVE FRESHTRACK',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your feedback\nmatters.',
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
          'Help us understand how well FreshTrack '
          'performed on your produce assessment.',
          style: TextStyle(color: muted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 23),
        _buildAssessmentSummary(),
        const SizedBox(height: 27),
        _buildAccuracySection(),
        if (_showCorrections) ...[
          const SizedBox(height: 18),
          _buildCorrectionSection(),
        ],
        const SizedBox(height: 27),
        _buildHelpfulnessSection(),
        const SizedBox(height: 27),
        _buildCommentsSection(),
        const SizedBox(height: 18),
        _buildPrototypeNotice(),
        const SizedBox(height: 25),
        SizedBox(
          height: 57,
          child: ElevatedButton.icon(
            onPressed: _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'Submit feedback',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe later'),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(27),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: sage,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: forest,
                size: 52,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Thank you for\nsharing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: forest,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Your feedback was captured for '
              'this preview session.\n\n'
              'Permanent storage will be added '
              'when we integrate the FreshTrack database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 13, height: 1.7),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'Back to assessment',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: forest,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assessment feedback',
          style: TextStyle(
            color: forest,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _submitted ? _buildSuccessScreen() : _buildFeedbackForm(),
      ),
    );
  }
}

class _FeedbackDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _FeedbackDetailRow({required this.label, required this.value});

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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackSelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _FeedbackSelectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.sage : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.forest : AppTheme.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.forest, size: 26),
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
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppTheme.forest : AppTheme.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _FeedbackOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.sage : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 125),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.forest : AppTheme.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: AppTheme.forest),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.forest,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
