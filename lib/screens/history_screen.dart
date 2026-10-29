import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// =====================================================
// FRESHTRACK - ASSESSMENT HISTORY
// =====================================================

// Demonstration data model.
// Replace with locally stored assessment records later.

class HistoryRecord {
  final String name;
  final String status;
  final String date;
  final String time;
  final String imagePath;
  final double confidence;
  final IconData fallbackIcon;

  const HistoryRecord({
    required this.name,
    required this.status,
    required this.date,
    required this.time,
    required this.imagePath,
    required this.confidence,
    required this.fallbackIcon,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  final List<HistoryRecord> _records = const [
    HistoryRecord(
      name: 'Red Apple',
      status: 'Fresh',
      date: '24 October 2026',
      time: '10:30 AM',
      imagePath: 'assets/images/apple.jpg',
      confidence: 0.91,
      fallbackIcon: Icons.apple,
    ),
    HistoryRecord(
      name: 'Banana',
      status: 'Spoiling',
      date: '23 October 2026',
      time: '2:15 PM',
      imagePath: 'assets/images/banana.jpg',
      confidence: 0.84,
      fallbackIcon: Icons.eco_outlined,
    ),
    HistoryRecord(
      name: 'Tomato',
      status: 'Spoiled',
      date: '22 October 2026',
      time: '9:40 AM',
      imagePath: 'assets/images/tomato.jpg',
      confidence: 0.88,
      fallbackIcon: Icons.local_florist_outlined,
    ),
    HistoryRecord(
      name: 'Orange',
      status: 'Fresh',
      date: '21 October 2026',
      time: '4:20 PM',
      imagePath: 'assets/images/orange.jpg',
      confidence: 0.93,
      fallbackIcon: Icons.circle_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return _records.where((record) {
      final matchesFilter =
          _selectedFilter == 'All' || record.status == _selectedFilter;

      final matchesSearch =
          record.name.toLowerCase().contains(query) ||
          record.status.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countStatus(String status) {
    return _records.where((record) => record.status == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Fresh':
        return const Color(0xFF28764A);
      case 'Spoiling':
        return const Color(0xFF94631B);
      case 'Spoiled':
        return const Color(0xFFA34439);
      default:
        return AppTheme.muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Fresh':
        return const Color(0xFFE6F3E9);
      case 'Spoiling':
        return const Color(0xFFFFF0D8);
      case 'Spoiled':
        return const Color(0xFFFBE5E2);
      default:
        return AppTheme.sage;
    }
  }

  void _showRecordDetails(HistoryRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              18,
              22,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 8),
                const Text(
                  'DEMONSTRATION ASSESSMENT',
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
                    height: 175,
                    child: Image.asset(
                      record.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.sage,
                          child: Icon(
                            record.fallbackIcon,
                            size: 60,
                            color: AppTheme.forest,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _statusBackground(record.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Freshness classification',
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor(record.status),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: _statusColor(record.status),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Demo confidence: '
                        '${(record.confidence * 100).toStringAsFixed(0)}%',
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
                  value: record.date,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: record.time,
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is sample assessment data for '
                  'interface testing. It is not a real '
                  'CNN prediction or a saved scan.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 20),
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
        );
      },
    );
  }

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
      ),
      body: SafeArea(
        child: ListView(
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
              'Explore your assessment records '
              'and revisit previous results.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 23),

            // ===========================================
            // SUMMARY COUNTERS
            // Wrap avoids horizontal RenderFlex overflow.
            // ===========================================
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final cardWidth = availableWidth >= 330
                    ? (availableWidth - 20) / 3
                    : (availableWidth - 10) / 2;

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
                      color: const Color(0xFF28764A),
                      background: const Color(0xFFE6F3E9),
                    ),
                    _SummaryCard(
                      width: cardWidth,
                      label: 'Spoiling',
                      count: _countStatus('Spoiling'),
                      icon: Icons.info_outline_rounded,
                      color: const Color(0xFF94631B),
                      background: const Color(0xFFFFF0D8),
                    ),
                    _SummaryCard(
                      width: cardWidth,
                      label: 'Spoiled',
                      count: _countStatus('Spoiled'),
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFA34439),
                      background: const Color(0xFFFBE5E2),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // ===========================================
            // SEARCH
            // ===========================================
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search assessments...',
                hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: AppTheme.forest,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ===========================================
            // FILTER CHIPS
            // Wrap instead of Row prevents overflow.
            // ===========================================
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', 'Fresh', 'Spoiling', 'Spoiled'].map((filter) {
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
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 26),

            // ===========================================
            // ASSESSMENT LIST HEADER
            // ===========================================
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

            if (records.isEmpty)
              _buildEmptyState()
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryTile(
                    record: record,
                    onTap: () => _showRecordDetails(record),
                    statusColor: _statusColor(record.status),
                    statusBackground: _statusBackground(record.status),
                  ),
                ),
              ),

            const SizedBox(height: 14),

            const Center(
              child: Text(
                'Demo records • Local history coming later',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppTheme.muted, size: 40),
          SizedBox(height: 14),
          Text(
            'No matching assessments',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.forest,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try another search or select '
            'a different freshness filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

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

// =====================================================
// RESPONSIVE HISTORY RECORD TILE
// =====================================================

class _HistoryTile extends StatelessWidget {
  final HistoryRecord record;
  final VoidCallback onTap;
  final Color statusColor;
  final Color statusBackground;

  const _HistoryTile({
    required this.record,
    required this.onTap,
    required this.statusColor,
    required this.statusBackground,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // FOOD IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 55,
                  height: 64,
                  child: Image.asset(
                    record.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.sage,
                        child: Icon(
                          record.fallbackIcon,
                          color: AppTheme.forest,
                          size: 27,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // EXPANDED TEXT TAKES REMAINING SPACE
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      record.date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Demo • ${(record.confidence * 100).toStringAsFixed(0)}%',
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

              // FIXED-WIDTH STATUS AREA
              SizedBox(
                width: 66,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                          record.status,
                          maxLines: 1,
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

// =====================================================
// BOTTOM SHEET DETAIL ROW
// =====================================================

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
