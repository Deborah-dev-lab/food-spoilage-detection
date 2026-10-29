import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// =====================================================
// FRESHTRACK - ASSESSMENT FEEDBACK
// =====================================================

enum FeedbackChoice { helpful, notHelpful }

class FeedbackScreen extends StatefulWidget {
  final String? produceName;
  final String? assessmentStatus;

  const FeedbackScreen({super.key, this.produceName, this.assessmentStatus});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();

  FeedbackChoice? _selectedChoice;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_selectedChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Yes or No before submitting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Prototype only:
    // Feedback is held in memory for this screen.
    // No local database or cloud submission is active.

    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assessment feedback',
          style: TextStyle(
            color: AppTheme.forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _submitted ? _buildSuccessScreen() : _buildFeedbackForm(),
      ),
    );
  }

  // =====================================================
  // FEEDBACK FORM
  // =====================================================

  Widget _buildFeedbackForm() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      children: [
        // -----------------------------------------------
        // HEADER ICON
        // -----------------------------------------------

        Center(
          child: Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              color: AppTheme.sage,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 34,
              color: AppTheme.forest,
            ),
          ),
        ),

        const SizedBox(height: 26),

        // -----------------------------------------------
        // TITLE
        // -----------------------------------------------
        const Text(
          'Was this assessment\nhelpful?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppTheme.forest,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Your feedback helps us understand how '
          'useful and clear FreshTrack assessments are.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.muted),
        ),

        // -----------------------------------------------
        // ASSESSMENT DETAILS
        // -----------------------------------------------
        if (widget.produceName != null || widget.assessmentStatus != null) ...[
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: AppTheme.forest),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ASSESSMENT',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        [
                          if (widget.produceName != null) widget.produceName!,
                          if (widget.assessmentStatus != null)
                            widget.assessmentStatus!,
                        ].join(' • '),
                        softWrap: true,
                        style: const TextStyle(
                          color: AppTheme.forest,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 30),

        // -----------------------------------------------
        // FEEDBACK QUESTION
        // -----------------------------------------------
        const Text(
          'HOW WAS YOUR EXPERIENCE?',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
            color: AppTheme.muted,
          ),
        ),

        const SizedBox(height: 15),

        // -----------------------------------------------
        // YES / NO OPTIONS
        // Flexible height prevents bottom overflow.
        // -----------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            const SizedBox(width: 14),

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

        const SizedBox(height: 30),

        // -----------------------------------------------
        // OPTIONAL COMMENTS
        // -----------------------------------------------
        const Text(
          'Tell us more',
          style: TextStyle(
            color: AppTheme.forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'What worked well, or what could be improved? '
          'Your comments are optional.',
          style: TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.5),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _commentController,
          maxLines: 5,
          minLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Share your experience with this assessment...',
            hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: const BorderSide(color: AppTheme.forest, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // -----------------------------------------------
        // PROTOTYPE INFORMATION
        // -----------------------------------------------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.sage,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.forest,
                size: 22,
              ),

              SizedBox(width: 11),

              Expanded(
                child: Text(
                  'This feedback form is part of the '
                  'FreshTrack prototype. Responses are '
                  'not yet stored or transmitted.',
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

        const SizedBox(height: 27),

        // -----------------------------------------------
        // SUBMIT BUTTON
        // -----------------------------------------------
        SizedBox(
          height: 58,
          child: ElevatedButton.icon(
            onPressed: _submitFeedback,
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'Submit feedback',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Maybe later'),
        ),
      ],
    );
  }

  // =====================================================
  // SUBMISSION CONFIRMATION
  // =====================================================

  Widget _buildSuccessScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.sage,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 53,
                color: AppTheme.forest,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Thank you for\nsharing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.8,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Your response has been recorded '
              'for this preview session.\n\n'
              'Persistent feedback storage will '
              'be connected in a later stage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// RESPONSIVE FEEDBACK OPTION CARD
// =====================================================

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
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected ? AppTheme.forest : AppTheme.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: AppTheme.forest),

              const SizedBox(height: 10),

              Text(
                label,
                textAlign: TextAlign.center,
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
                softWrap: true,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
