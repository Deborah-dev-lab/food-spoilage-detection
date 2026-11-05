import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'add_produce_screen.dart';

enum StockCondition { fresh, inspect, spoiled, unassessed }

class VendorStockItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime addedDate;
  final StockCondition condition;
  final String? notes;

  const VendorStockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.addedDate,
    required this.condition,
    this.notes,
  });

  String get quantityLabel {
    final formatted = quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(1);
    return '$formatted $unit';
  }
}

class VendorInventoryScreen extends StatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  State<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends State<VendorInventoryScreen> {
  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;
  static const Color amber = Color(0xFF93621B);
  static const Color red = Color(0xFFA43232);

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  // SAMPLE INVENTORY ONLY.
  // These records are not saved to a database.
  final List<VendorStockItem> _items = [
    VendorStockItem(
      id: 'STK001',
      name: 'Tomatoes',
      category: 'Vegetable',
      quantity: 15,
      unit: 'kg',
      addedDate: DateTime(2026, 11, 1),
      condition: StockCondition.fresh,
      notes: 'Sample stock entry.',
    ),
    VendorStockItem(
      id: 'STK002',
      name: 'Bananas',
      category: 'Fruit',
      quantity: 8,
      unit: 'bunches',
      addedDate: DateTime(2026, 11, 2),
      condition: StockCondition.inspect,
      notes: 'Check for visible signs of deterioration.',
    ),
    VendorStockItem(
      id: 'STK003',
      name: 'Apples',
      category: 'Fruit',
      quantity: 20,
      unit: 'pieces',
      addedDate: DateTime(2026, 11, 3),
      condition: StockCondition.fresh,
    ),
    VendorStockItem(
      id: 'STK004',
      name: 'Mangoes',
      category: 'Fruit',
      quantity: 12,
      unit: 'pieces',
      addedDate: DateTime(2026, 11, 3),
      condition: StockCondition.unassessed,
    ),
    VendorStockItem(
      id: 'STK005',
      name: 'Bell Peppers',
      category: 'Vegetable',
      quantity: 6,
      unit: 'kg',
      addedDate: DateTime(2026, 11, 4),
      condition: StockCondition.spoiled,
      notes: 'Sample suspected spoiled stock.',
    ),
  ];

  final List<String> _filters = const [
    'All',
    'Fresh',
    'Inspect',
    'Spoiled',
    'Not assessed',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _conditionLabel(StockCondition condition) {
    switch (condition) {
      case StockCondition.fresh:
        return 'Fresh';
      case StockCondition.inspect:
        return 'Inspect';
      case StockCondition.spoiled:
        return 'Spoiled';
      case StockCondition.unassessed:
        return 'Not assessed';
    }
  }

  Color _conditionColor(StockCondition condition) {
    switch (condition) {
      case StockCondition.fresh:
        return const Color(0xFF287C50);
      case StockCondition.inspect:
        return amber;
      case StockCondition.spoiled:
        return red;
      case StockCondition.unassessed:
        return muted;
    }
  }

  Color _conditionBackground(StockCondition condition) {
    switch (condition) {
      case StockCondition.fresh:
        return const Color(0xFFE5F3E8);
      case StockCondition.inspect:
        return const Color(0xFFFFF0D8);
      case StockCondition.spoiled:
        return const Color(0xFFFCE4E4);
      case StockCondition.unassessed:
        return const Color(0xFFF0F1EE);
    }
  }

  IconData _produceIcon(String category) {
    return category == 'Fruit' ? Icons.spa_outlined : Icons.eco_outlined;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  List<VendorStockItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      final matchesFilter =
          _selectedFilter == 'All' ||
          _conditionLabel(item.condition) == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _openAddProduce() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProduceScreen()),
    );
  }

  void _showPrototypeMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action will be connected during the '
          'inventory database integration.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openItemDetails(VendorStockItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(23, 24, 23, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: sage,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        _produceIcon(item.category),
                        color: forest,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: forest,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.id,
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _detailRow('Category', item.category),
                _detailRow('Quantity', item.quantityLabel),
                _detailRow('Date recorded', _formatDate(item.addedDate)),
                _detailRow(
                  'Recorded condition',
                  _conditionLabel(item.condition),
                ),
                if (item.notes != null) _detailRow('Notes', item.notes!),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: sage,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Text(
                    'This is demonstration inventory data. '
                    'The recorded condition is not a verified '
                    'CNN result or a food-safety guarantee.',
                    style: TextStyle(color: forest, fontSize: 12, height: 1.6),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showPrototypeMessage('Edit stock');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forest,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit stock'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: forest,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: forest, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: forest,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(VendorStockItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openItemDetails(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: sage,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _produceIcon(item.category),
                    color: forest,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: forest,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${item.quantityLabel}  •  ${item.category}',
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _conditionBackground(item.condition),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _conditionLabel(item.condition),
                          style: TextStyle(
                            color: _conditionColor(item.condition),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: forest),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final attentionCount = _items
        .where(
          (item) =>
              item.condition == StockCondition.inspect ||
              item.condition == StockCondition.spoiled,
        )
        .length;

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'Produce inventory',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduce,
        backgroundColor: forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add produce',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),
          children: [
            const Text(
              'YOUR STOCK',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Know what you\nhave in stock.',
              style: TextStyle(
                color: forest,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Review produce records and identify '
              'items that may need closer inspection.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                _summaryCard(
                  value: '${_items.length}',
                  label: 'Stock entries',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  value: '$attentionCount',
                  label: 'Need attention',
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: 23),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search produce...',
                hintStyle: const TextStyle(color: muted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: forest),
                filled: true,
                fillColor: Colors.white,
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
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final selected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: sage,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: selected ? forest : AppTheme.border,
                      ),
                      labelStyle: TextStyle(
                        color: forest,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Stock records',
                    style: TextStyle(
                      color: forest,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${filtered.length} items',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 13),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, color: forest, size: 39),
                    SizedBox(height: 12),
                    Text(
                      'No matching produce',
                      style: TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Try a different search or filter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map(_buildStockCard),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sage,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: forest),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'These are sample stock records. '
                      'Adding produce does not update this '
                      'list yet. Permanent inventory storage '
                      'will be implemented during database integration.',
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
