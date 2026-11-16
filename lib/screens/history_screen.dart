import 'dart:io';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/assessment_storage.dart';
import '../theme/app_theme.dart';
import 'feedback_screen.dart';

// ============================================================
// FRESHTRACK — ASSESSMENT HISTORY WITH SQLITE FEEDBACK
// ============================================================

class HistoryRecord {
  final int id;
  final String name;
  final String status;
  final DateTime assessedAt;
  final String imagePath;
  final double? confidence;

  const HistoryRecord({
    required this.id,
    required this.name,
    required this.status,
    required this.assessedAt,
    required this.imagePath,
    required this.confidence,
  });

  factory HistoryRecord.fromDatabase(Map<String, dynamic> row) {
    final rawConfidence = row['confidence'];

    return HistoryRecord(
      id: (row['id'] as num).toInt(),
      name: row['produce_name']?.toString() ?? 'Unknown produce',
      status: row['freshness_status']?.toString() ?? 'uncertain',
      assessedAt:
          DateTime.tryParse(row['assessed_at']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      imagePath: row['image_path']?.toString() ?? '',
      confidence: rawConfidence is num
          ? rawConfidence.toDouble()
          : double.tryParse(rawConfidence?.toString() ?? ''),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<HistoryRecord> _records = [];

  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _loadError;

  static const filters = ['All', 'Fresh', 'Spoiling', 'Spoiled', 'Uncertain'];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SQLITE ASSESSMENT OPERATIONS
  // ============================================================

  Future<void> _loadAssessments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final rows = await AssessmentStorage.getAssessments();

      final records = rows
          .map((row) => HistoryRecord.fromDatabase(row))
          .toList();

      records.sort((a, b) => b.assessedAt.compareTo(a.assessedAt));

      if (!mounted) return;

      setState(() {
        _records = records;
        _isLoading = false;
      });

      debugPrint(
        'FRESHTRACK: Loaded ${records.length} assessments from SQLite',
      );
    } catch (error) {
      debugPrint('FRESHTRACK: History load failed: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Could not load your assessment history.';
      });
    }
  }

  Future<void> _deleteRecord(HistoryRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete assessment?'),
          content: Text(
            'Remove the saved assessment for ${record.name}? '
            'Any linked feedback will also be deleted. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFA34439)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await AssessmentStorage.deleteAssessment(record.id, record.imagePath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment deleted successfully')),
      );

      await _loadAssessments();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete assessment: $error')),
      );
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _normaliseStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'fresh':
        return 'Fresh';
      case 'spoiling':
        return 'Spoiling';
      case 'spoiled':
      case 'rotten':
        return 'Spoiled';
      case 'uncertain':
      case 'unknown':
        return 'Uncertain';
      default:
        return status.trim().isEmpty ? 'Uncertain' : status;
    }
  }

  List<HistoryRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return _records.where((record) {
      final status = _normaliseStatus(record.status);

      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter;

      final matchesSearch =
          record.name.toLowerCase().contains(query) ||
          status.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countStatus(String status) {
    return _records.where((record) {
      return _normaliseStatus(record.status) == status;
    }).length;
  }

  Color _statusColor(String status) {
    switch (_normaliseStatus(status)) {
      case 'Fresh':
        return const Color(0xFF28764A);
      case 'Spoiling':
        return const Color(0xFF94631B);
      case 'Spoiled':
        return const Color(0xFFA34439);
      case 'Uncertain':
        return const Color(0xFF6B638B);
      default:
        return AppTheme.muted;
    }
  }

  Color _statusBackground(String status) {
    switch (_normaliseStatus(status)) {
      case 'Fresh':
        return const Color(0xFFE6F3E9);
      case 'Spoiling':
        return const Color(0xFFFFF0D8);
      case 'Spoiled':
        return const Color(0xFFFBE5E2);
      case 'Uncertain':
        return const Color(0xFFEDEAF5);
      default:
        return AppTheme.sage;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatConfidence(double? confidence) {
    if (confidence == null || !confidence.isFinite) {
      return 'Not available';
    }

    final value = confidence.clamp(0.0, 1.0);

    return '${(value * 100).toStringAsFixed(1)}%';
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) {
      return _imageFallback();
    }

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imageFallback();
      },
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppTheme.sage,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppTheme.forest,
        size: 30,
      ),
    );
  }

  // ============================================================
  // ASSESSMENT DETAILS BOTTOM SHEET
  // ============================================================

  Future<void> _showRecordDetails(HistoryRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final status = _normaliseStatus(record.status);

        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.82,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forest,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'SAVED CNN ASSESSMENT',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 190,
                      child: _buildImage(record.imagePath),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _statusBackground(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Freshness classification',
                          style: TextStyle(
                            fontSize: 12,
                            color: _statusColor(status),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: _statusColor(status),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Model score: '
                          '${_formatConfidence(record.confidence)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.forest,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(record.assessedAt),
                  ),

                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: _formatTime(record.assessedAt),
                  ),

                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.tag_outlined,
                    label: 'Record ID',
                    value: '${record.id}',
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'FreshTrack uses image classification to '
                    'estimate visual freshness. The result is '
                    'not a definitive food safety test.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: AppTheme.muted,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // NEW: FEEDBACK SECTION
                  _AssessmentFeedbackSection(record: record),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _deleteRecord(record);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete assessment'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (mounted) {
      await _loadAssessments();
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final hasSearch =
        _searchController.text.trim().isNotEmpty || _selectedFilter != 'All';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.history_rounded,
            color: AppTheme.muted,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No matching assessments' : 'No assessments saved yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try another search or select a different filter.'
                : 'Your real CNN assessments will appear here '
                      'after you scan fruit or vegetables.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN HISTORY SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assessment history',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.forest,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh history',
            onPressed: _isLoading ? null : _loadAssessments,
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.forest),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAssessments,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              const Text(
                'YOUR FRESHNESS JOURNEY',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Every check,\nin one place.',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppTheme.forest,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Explore your saved assessments '
                'and revisit previous CNN results.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.muted,
                ),
              ),

              const SizedBox(height: 23),

              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final cardWidth = width >= 330
                      ? (width - 20) / 3
                      : (width - 10) / 2;

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SummaryCard(
                        width: cardWidth,
                        label: 'Total checks',
                        count: _records.length,
                        icon: Icons.analytics_outlined,
                        color: AppTheme.forest,
                        background: AppTheme.sage,
                      ),
                      _SummaryCard(
                        width: cardWidth,
                        label: 'Fresh',
                        count: _countStatus('Fresh'),
                        icon: Icons.check_circle_outline_rounded,
                        color: _statusColor('Fresh'),
                        background: _statusBackground('Fresh'),
                      ),
                      _SummaryCard(
                        width: cardWidth,
                        label: 'Spoiling',
                        count: _countStatus('Spoiling'),
                        icon: Icons.info_outline_rounded,
                        color: _statusColor('Spoiling'),
                        background: _statusBackground('Spoiling'),
                      ),
                      _SummaryCard(
                        width: cardWidth,
                        label: 'Spoiled',
                        count: _countStatus('Spoiled'),
                        icon: Icons.warning_amber_rounded,
                        color: _statusColor('Spoiled'),
                        background: _statusBackground('Spoiled'),
                      ),
                      _SummaryCard(
                        width: cardWidth,
                        label: 'Uncertain',
                        count: _countStatus('Uncertain'),
                        icon: Icons.help_outline_rounded,
                        color: _statusColor('Uncertain'),
                        background: _statusBackground('Uncertain'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search assessments...',
                  hintStyle: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.forest,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters.map((filter) {
                  final selected = _selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppTheme.forest,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppTheme.forest,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? AppTheme.forest : AppTheme.border,
                    ),
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                      ),
                    ),
                  ),
                  Text(
                    '${records.length} records',
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 45),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.forest),
                  ),
                )
              else if (_loadError != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFA34439),
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      Text(_loadError!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _loadAssessments,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (records.isEmpty)
                _buildEmptyState()
              else
                ...records.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryTile(
                      record: record,
                      onTap: () => _showRecordDetails(record),
                      status: _normaliseStatus(record.status),
                      statusColor: _statusColor(record.status),
                      statusBackground: _statusBackground(record.status),
                      image: _buildImage(record.imagePath),
                      date: _formatDate(record.assessedAt),
                      time: _formatTime(record.assessedAt),
                      confidence: _formatConfidence(record.confidence),
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'Assessments stored locally on this device',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NEW — SQLITE FEEDBACK SECTION
// ============================================================

class _AssessmentFeedbackSection extends StatefulWidget {
  final HistoryRecord record;

  const _AssessmentFeedbackSection({required this.record});

  @override
  State<_AssessmentFeedbackSection> createState() =>
      _AssessmentFeedbackSectionState();
}

class _AssessmentFeedbackSectionState
    extends State<_AssessmentFeedbackSection> {
  Map<String, dynamic>? _feedback;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await DatabaseHelper.instance.getFeedbackForAssessment(
        widget.record.id,
      );

      if (!mounted) return;

      setState(() {
        _feedback = rows.isEmpty ? null : rows.first;
        _loading = false;
      });
    } catch (error) {
      debugPrint('FRESHTRACK: Feedback load failed: $error');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load feedback.';
      });
    }
  }

  String _accuracyLabel(String? value) {
    switch (value) {
      case 'correct':
        return 'Correct';
      case 'partially_correct':
        return 'Partially correct';
      case 'incorrect':
        return 'Incorrect';
      default:
        return 'Not recorded';
    }
  }

  String _helpfulnessLabel(dynamic value) {
    if (value == 1) return 'Yes';
    if (value == 0) return 'No';

    return 'Not recorded';
  }

  String _dateLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();

    if (date == null) {
      return 'Not recorded';
    }

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }

  Future<void> _openFeedback() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          assessmentId: widget.record.id,
          produceName: widget.record.name,
          assessmentStatus: widget.record.status,
        ),
      ),
    );

    if (mounted) {
      await _loadFeedback();
    }
  }

  Widget _buildFeedbackDetails() {
    final feedback = _feedback!;

    final actualProduce = feedback['actual_produce']?.toString().trim() ?? '';

    final actualCondition =
        feedback['actual_condition']?.toString().trim() ?? '';

    final comments = feedback['comments']?.toString().trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF28764A),
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Feedback submitted',
                style: TextStyle(
                  color: AppTheme.forest,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _FeedbackValue(
          label: 'Prediction accuracy',
          value: _accuracyLabel(feedback['prediction_accuracy']?.toString()),
        ),

        _FeedbackValue(
          label: 'Was the assessment helpful?',
          value: _helpfulnessLabel(feedback['is_helpful']),
        ),

        if (actualProduce.isNotEmpty)
          _FeedbackValue(label: 'Actual produce', value: actualProduce),

        if (actualCondition.isNotEmpty)
          _FeedbackValue(
            label: 'Actual freshness condition',
            value: actualCondition,
          ),

        if (comments.isNotEmpty)
          _FeedbackValue(label: 'Additional comments', value: comments),

        _FeedbackValue(
          label: 'Submitted on',
          value: _dateLabel(feedback['submitted_at']),
        ),

        const SizedBox(height: 5),

        const Text(
          'Your feedback is saved locally on this device.',
          style: TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: AppTheme.forest,
                size: 23,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Assessment feedback',
                  style: TextStyle(
                    color: AppTheme.forest,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppTheme.forest),
              ),
            )
          else if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadFeedback, child: const Text('Retry')),
          ] else if (_feedback == null) ...[
            const Text(
              'You have not submitted feedback for this assessment.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  'Give feedback',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ] else
            _buildFeedbackDetails(),
        ],
      ),
    );
  }
}

// ============================================================
// FEEDBACK DETAIL ROW
// ============================================================

class _FeedbackValue extends StatelessWidget {
  final String label;
  final String value;

  const _FeedbackValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final double width;
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.width,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HISTORY TILE
// ============================================================

class _HistoryTile extends StatelessWidget {
  final HistoryRecord record;
  final VoidCallback onTap;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final Widget image;
  final String date;
  final String time;
  final String confidence;

  const _HistoryTile({
    required this.record,
    required this.onTap,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.image,
    required this.date,
    required this.time,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(width: 55, height: 64, child: image),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Model score: $confidence',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              SizedBox(
                width: 76,
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.muted,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ASSESSMENT DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.forest, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.forest,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
