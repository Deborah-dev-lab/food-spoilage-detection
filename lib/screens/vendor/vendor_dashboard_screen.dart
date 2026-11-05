import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../camera_screen.dart';
import 'add_produce_screen.dart';
import 'vendor_inventory_screen.dart';
import 'vendor_recommendations_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color sage = AppTheme.sage;
  static const Color muted = AppTheme.muted;

  // =====================================================
  // NAVIGATION
  // =====================================================

  void _startScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _openAddProduce(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProduceScreen()),
    );
  }

  void _openInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VendorInventoryScreen()),
    );
  }

  void _openRecommendations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VendorRecommendationsScreen()),
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

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

  // =====================================================
  // SUMMARY CARD
  // =====================================================

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

  // =====================================================
  // ACTION CARD
  // =====================================================

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

  // =====================================================
  // INVENTORY PREVIEW ITEM
  // =====================================================

  Widget _inventoryPreview({
    required String name,
    required String quantity,
    required String status,
    required IconData icon,
    required Color statusColor,
    required Color statusBackground,
  }) {
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
            child: Icon(icon, color: forest, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  quantity,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
          children: [
            // ============================================
            // GREETING
            // ============================================

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

            // ============================================
            // SCAN PRODUCE CARD
            // ============================================
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
                      onPressed: () => _startScan(context),
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

            // ============================================
            // STOCK OVERVIEW
            // ============================================
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
                    'SAMPLE DATA',
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
                    value: '12',
                    label: 'Stock entries',
                    background: sage,
                    foreground: forest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    icon: Icons.warning_amber_rounded,
                    value: '3',
                    label: 'Need attention',
                    background: const Color(0xFFFFF0D8),
                    foreground: const Color(0xFF93621B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ============================================
            // MANAGE STOCK
            // ============================================
            _sectionTitle('Manage your stock'),

            const SizedBox(height: 14),

            // ADD PRODUCE - CONNECTED
            _actionCard(
              icon: Icons.add_box_outlined,
              title: 'Add produce',
              subtitle: 'Record a new stock entry',
              onTap: () => _openAddProduce(context),
            ),

            const SizedBox(height: 11),

            // VIEW INVENTORY - CONNECTED
            _actionCard(
              icon: Icons.inventory_2_outlined,
              title: 'View inventory',
              subtitle: 'Review and update stock records',
              onTap: () => _openInventory(context),
            ),

            const SizedBox(height: 11),

            // RECOMMENDATIONS - CONNECTED
            _actionCard(
              icon: Icons.tips_and_updates_outlined,
              title: 'Recommendations',
              subtitle: 'Guidance for handling produce',
              onTap: () => _openRecommendations(context),
            ),

            const SizedBox(height: 26),

            // ============================================
            // INVENTORY PREVIEW
            // ============================================
            Row(
              children: [
                Expanded(child: _sectionTitle('Inventory preview')),
                TextButton(
                  onPressed: () => _openInventory(context),
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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _inventoryPreview(
                    name: 'Tomatoes',
                    quantity: '15 kg',
                    status: 'Fresh',
                    icon: Icons.eco_outlined,
                    statusColor: const Color(0xFF287C50),
                    statusBackground: const Color(0xFFE5F3E8),
                  ),

                  const Divider(height: 1, color: AppTheme.border),

                  _inventoryPreview(
                    name: 'Bananas',
                    quantity: '8 bunches',
                    status: 'Inspect',
                    icon: Icons.spa_outlined,
                    statusColor: const Color(0xFF93621B),
                    statusBackground: const Color(0xFFFFF0D8),
                  ),

                  const Divider(height: 1, color: AppTheme.border),

                  _inventoryPreview(
                    name: 'Apples',
                    quantity: '20 pieces',
                    status: 'Fresh',
                    icon: Icons.apple_outlined,
                    statusColor: const Color(0xFF287C50),
                    statusBackground: const Color(0xFFE5F3E8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Illustrative stock records only. '
              'No inventory has been saved yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 11, height: 1.5),
            ),

            const SizedBox(height: 24),

            // ============================================
            // SAFETY REMINDER
            // ============================================
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
    );
  }
}
