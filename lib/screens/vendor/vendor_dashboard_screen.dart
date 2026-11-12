import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../camera_screen.dart';
import 'add_produce_screen.dart';
import 'vendor_inventory_screen.dart';
import 'vendor_recommendations_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color sage = AppTheme.sage;
  static const Color muted = AppTheme.muted;

  List<Map<String, dynamic>> _inventory = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final records = await DatabaseHelper.instance.getInventory();

      if (!mounted) return;

      setState(() {
        _inventory = records;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _status(Map<String, dynamic> item) {
    final raw = (item['freshness_status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    switch (raw) {
      case 'fresh':
        return 'Fresh';
      case 'inspect':
      case 'spoiling':
      case 'uncertain':
        return 'Inspect';
      case 'spoiled':
      case 'rotten':
        return 'Spoiled';
      default:
        return 'Not assessed';
    }
  }

  int get _attentionCount {
    return _inventory.where((item) {
      final status = _status(item);
      return status == 'Inspect' || status == 'Spoiled';
    }).length;
  }

  String _quantityLabel(Map<String, dynamic> item) {
    final value = (item['quantity'] as num).toDouble();

    final formatted = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();

    return '$formatted ${item['unit']}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Fresh':
        return const Color(0xFF287C50);
      case 'Inspect':
        return const Color(0xFF93621B);
      case 'Spoiled':
        return const Color(0xFFA43232);
      default:
        return muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Fresh':
        return const Color(0xFFE5F3E8);
      case 'Inspect':
        return const Color(0xFFFFF0D8);
      case 'Spoiled':
        return const Color(0xFFFCE4E4);
      default:
        return const Color(0xFFF0F1EE);
    }
  }

  Future<void> _startScan() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (mounted) await _loadInventory();
  }

  Future<void> _openAddProduce() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProduceScreen()),
    );

    if (mounted) await _loadInventory();
  }

  Future<void> _openInventory() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const VendorInventoryScreen()),
    );

    if (mounted) await _loadInventory();
  }

  Future<void> _openRecommendations() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const VendorRecommendationsScreen()),
    );

    if (mounted) await _loadInventory();
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: forest,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 25),
          const SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: sage,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: forest, size: 24),
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
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: forest,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inventoryPreview(Map<String, dynamic> item) {
    final status = _status(item);
    final category = item['category']?.toString() ?? 'Other';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: sage,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              category == 'Fruit' ? Icons.spa_outlined : Icons.eco_outlined,
              color: forest,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['produce_name']?.toString() ?? 'Produce',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _quantityLabel(item),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBackground(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryPreview() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator(color: forest)),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          const Text(
            'Unable to load your inventory.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadInventory, child: const Text('Try again')),
        ],
      );
    }

    if (_inventory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, color: forest, size: 38),
            const SizedBox(height: 12),
            const Text(
              'No produce added yet',
              style: TextStyle(
                color: forest,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Add your first stock entry to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openAddProduce,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add produce'),
            ),
          ],
        ),
      );
    }

    // The database returns newest records first.
    // Show the three most recent entries.
    final preview = _inventory.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < preview.length; index++) ...[
            _inventoryPreview(preview[index]),
            if (index < preview.length - 1)
              const Divider(height: 1, color: AppTheme.border),
          ],
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
        title: const Text(
          'Vendor workspace',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _loading ? null : _loadInventory,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'About vendor mode',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'FreshTrack Vendor',
                applicationVersion: 'Prototype',
                children: const [
                  Text(
                    'Vendor Mode helps small-scale produce '
                    'sellers organise stock and review '
                    'image-based freshness assessments.',
                  ),
                ],
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInventory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
            children: [
              const Text(
                'YOUR VENDOR WORKSPACE',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Keep your stock\nin check.',
                style: TextStyle(
                  color: forest,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Track your produce, review assessments '
                'and make informed stock decisions.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 23),

              // SCAN PRODUCE
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: forest,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.center_focus_strong_rounded,
                          color: lime,
                          size: 29,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'PRODUCE ASSESSMENT',
                          style: TextStyle(
                            color: lime,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Check your produce\nbefore the next sale.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Capture an image to receive a '
                      'CNN-based visual assessment.',
                      style: TextStyle(color: sage, fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _startScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lime,
                          foregroundColor: forest,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text(
                          'Scan produce',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // STOCK OVERVIEW
              Row(
                children: [
                  Expanded(child: _sectionTitle('Stock overview')),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sage,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LOCAL DATA',
                      style: TextStyle(
                        color: forest,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.inventory_2_outlined,
                      value: _loading ? '...' : '${_inventory.length}',
                      label: 'Stock entries',
                      background: sage,
                      foreground: forest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.warning_amber_rounded,
                      value: _loading ? '...' : '$_attentionCount',
                      label: 'Need attention',
                      background: const Color(0xFFFFF0D8),
                      foreground: const Color(0xFF93621B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // MANAGE STOCK
              _sectionTitle('Manage your stock'),
              const SizedBox(height: 14),

              _actionCard(
                icon: Icons.add_box_outlined,
                title: 'Add produce',
                subtitle: 'Record a new stock entry',
                onTap: _openAddProduce,
              ),
              const SizedBox(height: 11),

              _actionCard(
                icon: Icons.inventory_2_outlined,
                title: 'View inventory',
                subtitle: 'Review and update stock records',
                onTap: _openInventory,
              ),
              const SizedBox(height: 11),

              _actionCard(
                icon: Icons.tips_and_updates_outlined,
                title: 'Recommendations',
                subtitle: 'Guidance for handling produce',
                onTap: _openRecommendations,
              ),

              const SizedBox(height: 26),

              // INVENTORY PREVIEW
              Row(
                children: [
                  Expanded(child: _sectionTitle('Inventory preview')),
                  TextButton(
                    onPressed: _openInventory,
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildInventoryPreview(),

              if (!_loading && _error == null && _inventory.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Showing ${_inventory.length < 3 ? _inventory.length : 3} '
                  'of ${_inventory.length} stock entries',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],

              const SizedBox(height: 24),

              // SAFETY REMINDER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: sage,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: forest,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'FreshTrack supports visual checks, '
                        'but a photograph cannot establish '
                        'whether food is safe to sell or eat. '
                        'Always inspect stock and follow '
                        'appropriate food-handling practices.',
                        style: TextStyle(
                          color: forest,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
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
