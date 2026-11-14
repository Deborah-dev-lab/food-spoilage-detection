import 'dart:io';

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
  static const Color border = AppTheme.border;

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

  int get _freshCount {
    return _inventory.where((item) => _status(item) == 'Fresh').length;
  }

  String _quantityLabel(Map<String, dynamic> item) {
    final rawQuantity = item['quantity'];
    final number = rawQuantity is num
        ? rawQuantity.toDouble()
        : double.tryParse(rawQuantity?.toString() ?? '') ?? 0;

    final formatted = number == number.roundToDouble()
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(2);

    final unit = item['unit']?.toString() ?? '';

    return '$formatted $unit'.trim();
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

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (mounted) {
      await _loadInventory();
    }
  }

  Future<void> _startScan() {
    return _openPage(const CameraScreen());
  }

  Future<void> _openAddProduce() {
    return _openPage(const AddProduceScreen());
  }

  Future<void> _openInventory() {
    return _openPage(const VendorInventoryScreen());
  }

  Future<void> _openRecommendations() {
    return _openPage(const VendorRecommendationsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: forest,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
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
                    'Vendor Mode helps small-scale '
                    'produce sellers organise stock '
                    'and review image-based freshness '
                    'assessments.',
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
          color: forest,
          onRefresh: _loadInventory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            children: [
              _buildIntroduction(),
              const SizedBox(height: 24),
              _buildScanHero(),
              const SizedBox(height: 28),
              _buildStockOverview(),
              const SizedBox(height: 28),
              _buildManagementSection(),
              const SizedBox(height: 28),
              _buildInventorySection(),
              const SizedBox(height: 25),
              _buildSafetyReminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR VENDOR WORKSPACE',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Better stock.\nSmarter decisions.',
          style: TextStyle(
            color: forest,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Organise your produce, review visible '
          'freshness assessments and find practical '
          'ways to reduce food waste.',
          style: TextStyle(color: muted, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildScanHero() {
    return Container(
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            child: _VendorAssetImage(
              path: 'assets/images/learning/food_safety.jpg',
              height: 180,
              icon: Icons.camera_alt_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.center_focus_strong_rounded,
                      color: lime,
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'PRODUCE ASSESSMENT',
                      style: TextStyle(
                        color: lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Check your produce\nbefore the next sale.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Capture a photograph to assess '
                  'visible signs of freshness or spoilage.',
                  style: TextStyle(color: sage, fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Scan produce'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: forest,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Stock overview',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
        const SizedBox(height: 7),
        const Text(
          'A quick look at your recorded inventory.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.inventory_2_outlined,
                value: _loading || _error != null
                    ? '--'
                    : '${_inventory.length}',
                label: 'Stock entries',
                background: sage,
                foreground: forest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.warning_amber_rounded,
                value: _loading || _error != null ? '--' : '$_attentionCount',
                label: 'Need attention',
                background: const Color(0xFFFFF0D8),
                foreground: const Color(0xFF93621B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F3E8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF287C50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loading || _error != null ? '--' : '$_freshCount',
                      style: const TextStyle(
                        color: forest,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Entries marked Fresh',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.eco_outlined, color: forest),
            ],
          ),
        ),
      ],
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
          const SizedBox(height: 17),
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

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage your stock',
          style: TextStyle(
            color: forest,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Everything you need to organise your produce.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 15),
        _imageActionCard(
          imagePath: 'assets/images/learning/vegetable_drying.jpg',
          icon: Icons.add_box_outlined,
          title: 'Add produce',
          subtitle: 'Record a new stock entry',
          onTap: _openAddProduce,
        ),
        const SizedBox(height: 12),
        _imageActionCard(
          imagePath: 'assets/images/learning/dried_mangoes.jpg',
          icon: Icons.inventory_2_outlined,
          title: 'View inventory',
          subtitle: 'Review and update stock records',
          onTap: _openInventory,
        ),
        const SizedBox(height: 12),
        _imageActionCard(
          imagePath: 'assets/images/learning/value_addition.jpg',
          icon: Icons.tips_and_updates_outlined,
          title: 'Recommendations',
          subtitle: 'Practical produce handling guidance',
          onTap: _openRecommendations,
        ),
      ],
    );
  }

  Widget _imageActionCard({
    required String imagePath,
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
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 85,
                  height: 83,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: sage,
                        child: Icon(icon, color: forest, size: 29),
                      );
                    },
                  ),
                ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
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
              const SizedBox(width: 7),
              const Icon(Icons.arrow_forward_rounded, color: forest, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Inventory preview',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: _openInventory,
              child: const Text(
                'View all',
                style: TextStyle(color: forest, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInventoryPreview(),
        if (!_loading && _error == null && _inventory.isNotEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Showing ${_inventory.length < 3 ? _inventory.length : 3} '
              'of ${_inventory.length} stock entries',
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ),
        ],
      ],
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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: forest, size: 32),
            const SizedBox(height: 10),
            const Text(
              'Unable to load your inventory.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadInventory,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_inventory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, color: forest, size: 39),
            const SizedBox(height: 12),
            const Text(
              'No produce added yet',
              style: TextStyle(
                color: forest,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
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

    final preview = _inventory.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          for (int index = 0; index < preview.length; index++) ...[
            _inventoryTile(preview[index]),
            if (index < preview.length - 1)
              const Divider(height: 1, color: border),
          ],
        ],
      ),
    );
  }

  Widget _inventoryTile(Map<String, dynamic> item) {
    final status = _status(item);
    final category = item['category']?.toString() ?? 'Other';
    final produceName = item['produce_name']?.toString() ?? 'Produce';

    final imagePath = (item['image_path'] ?? item['photo_path'] ?? '')
        .toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 54,
              height: 54,
              child: _inventoryImage(imagePath, category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produceName,
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
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: _statusBackground(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryImage(String imagePath, String category) {
    final fallback = Container(
      color: sage,
      child: Icon(
        category.toLowerCase() == 'fruit'
            ? Icons.spa_outlined
            : Icons.eco_outlined,
        color: forest,
        size: 26,
      ),
    );

    if (imagePath.isEmpty) return fallback;

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      width: 54,
      height: 54,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  Widget _buildSafetyReminder() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety_outlined, color: forest, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'FreshTrack supports visual freshness '
              'checks, but a photograph cannot confirm '
              'that food is safe to sell or eat. '
              'Always inspect stock and follow '
              'appropriate food-handling practices.',
              style: TextStyle(color: forest, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorAssetImage extends StatelessWidget {
  final String path;
  final double height;
  final IconData icon;

  const _VendorAssetImage({
    required this.path,
    required this.height,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          color: AppTheme.sage,
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.forest, size: 48),
        );
      },
    );
  }
}
