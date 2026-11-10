import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';

enum FeedbackChoice { helpful, notHelpful }

enum PredictionAccuracy { correct, partiallyCorrect, incorrect }

enum ActualCondition { fresh, spoiling, spoiled, unsure }

class FeedbackScreen extends StatefulWidget {
  final int? assessmentId;
  final String? produceName;
  final String? assessmentStatus;

  const FeedbackScreen({
    super.key,
    this.assessmentId,
    this.produceName,
    this.assessmentStatus,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;

  final TextEditingController _commentController = TextEditingController();

  final TextEditingController _actualProduceController =
      TextEditingController();

  PredictionAccuracy? _predictionAccuracy;
  FeedbackChoice? _selectedChoice;
  ActualCondition? _actualCondition;

  Map<String, dynamic>? _assessment;

  bool _loading = true;
  bool _saving = false;
  bool _submitted = false;
  bool _alreadySubmitted = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _actualProduceController.dispose();
    super.dispose();
  }

  String _displayProduce(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return 'Not specified';
    }

    return text
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        );
  }

  String get _predictedProduce {
    return _displayProduce(
      _assessment?['produce_name']?.toString() ?? widget.produceName,
    );
  }

  String get _predictedCondition {
    final value =
        _assessment?['freshness_status']?.toString() ?? widget.assessmentStatus;

    if (value == null || value.trim().isEmpty) {
      return 'Not specified';
    }

    return value.trim();
  }

  bool get _showCorrections {
    return _predictionAccuracy == PredictionAccuracy.incorrect ||
        _predictionAccuracy == PredictionAccuracy.partiallyCorrect;
  }

  bool get _canSubmit {
    return !_loading &&
        !_saving &&
        !_submitted &&
        !_alreadySubmitted &&
        _loadError == null &&
        _assessment != null &&
        widget.assessmentId != null;
  }

  Future<void> _loadAssessment() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _loadError = null;
    });

    final id = widget.assessmentId;

    if (id == null) {
      setState(() {
        _loading = false;
        _loadError =
            'This screen was opened without a saved '
            'assessment ID. Please open feedback from '
            'a saved assessment.';
      });
      return;
    }

    try {
      final assessment = await DatabaseHelper.instance.getAssessmentById(id);

      if (assessment == null) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _loadError =
              'This assessment could not be found in '
              'your local history.';
        });
        return;
      }

      final existing = await DatabaseHelper.instance.hasFeedbackForAssessment(
        id,
      );

      if (!mounted) return;

      setState(() {
        _assessment = assessment;
        _alreadySubmitted = existing;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError =
            'Unable to load this assessment. '
            'Please try again.';
      });
    }
  }

  String _accuracyValue(PredictionAccuracy accuracy) {
    switch (accuracy) {
      case PredictionAccuracy.correct:
        return 'correct';
      case PredictionAccuracy.partiallyCorrect:
        return 'partially_correct';
      case PredictionAccuracy.incorrect:
        return 'incorrect';
    }
  }

  String? _actualConditionValue() {
    switch (_actualCondition) {
      case ActualCondition.fresh:
        return 'fresh';
      case ActualCondition.spoiling:
        return 'spoiling';
      case ActualCondition.spoiled:
        return 'spoiled';
      case ActualCondition.unsure:
        return 'unsure';
      case null:
        return null;
    }
  }

  Future<void> _submitFeedback() async {
    if (!_canSubmit) return;

    FocusScope.of(context).unfocus();

    if (_predictionAccuracy == null) {
      _showMessage('Please rate the prediction accuracy.');
      return;
    }

    if (_selectedChoice == null) {
      _showMessage('Please indicate whether the result was helpful.');
      return;
    }

    final id = widget.assessmentId!;

    setState(() {
      _saving = true;
    });

    try {
      final existing = await DatabaseHelper.instance.hasFeedbackForAssessment(
        id,
      );

      if (existing) {
        if (!mounted) return;

        setState(() {
          _saving = false;
          _alreadySubmitted = true;
        });
        return;
      }

      final accuracy = _predictionAccuracy!;
      final isCorrect = accuracy == PredictionAccuracy.correct ? 1 : 0;

      final actualProduce = _showCorrections
          ? _actualProduceController.text.trim()
          : '';

      final actualCondition = _showCorrections ? _actualConditionValue() : null;

      final comments = _commentController.text.trim();

      await DatabaseHelper.instance.insertFeedback({
        'assessment_id': id,
        'is_correct': isCorrect,
        'prediction_accuracy': _accuracyValue(accuracy),
        'actual_produce': actualProduce.isEmpty ? null : actualProduce,
        'actual_condition': actualCondition,
        'is_helpful': _selectedChoice == FeedbackChoice.helpful ? 1 : 0,
        'comments': comments.isEmpty ? null : comments,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() {
        _saving = false;
        _submitted = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Could not save feedback. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
          const SizedBox(height: 14),
          _FeedbackDetailRow(
            label: 'Assessment ID',
            value: widget.assessmentId?.toString() ?? '—',
          ),
          const SizedBox(height: 15),
          const Text(
            'These details come from the saved '
            'assessment you are reviewing.',
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

  Widget _buildStorageNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storage_rounded, color: forest, size: 23),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Your feedback will be saved locally '
              'on this device using SQLite. '
              'It is linked to the selected assessment '
              'and does not require an internet connection. '
              'Submitting feedback does not automatically '
              'retrain the CNN model.',
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
        _buildStorageNotice(),
        const SizedBox(height: 25),
        SizedBox(
          height: 57,
          child: ElevatedButton.icon(
            onPressed: _canSubmit ? _submitFeedback : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
              disabledBackgroundColor: forest.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _saving ? 'Saving feedback...' : 'Submit feedback',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Maybe later'),
        ),
      ],
    );
  }

  Widget _buildStatusScreen({
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    VoidCallback? onButtonPressed,
  }) {
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
              child: Icon(icon, color: forest, size: 52),
            ),
            const SizedBox(height: 26),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.7),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton.icon(
                onPressed: onButtonPressed ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
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
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator(color: forest));
    } else if (_submitted) {
      body = _buildStatusScreen(
        icon: Icons.check_circle_outline_rounded,
        title: 'Thank you for\nsharing!',
        message:
            'Your feedback has been saved successfully '
            'to the FreshTrack database on this device.\n\n'
            'It is linked to assessment '
            '#${widget.assessmentId}.',
        buttonLabel: 'Back to assessment',
      );
    } else if (_alreadySubmitted) {
      body = _buildStatusScreen(
        icon: Icons.verified_outlined,
        title: 'Feedback already\nsubmitted',
        message:
            'Feedback has already been recorded for '
            'this assessment. No additional response '
            'has been saved.',
        buttonLabel: 'Go back',
      );
    } else if (_loadError != null) {
      body = _buildStatusScreen(
        icon: Icons.info_outline_rounded,
        title: 'Assessment\nunavailable',
        message: _loadError!,
        buttonLabel: 'Go back',
      );
    } else {
      body = _buildFeedbackForm();
    }

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
      body: SafeArea(child: body),
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
