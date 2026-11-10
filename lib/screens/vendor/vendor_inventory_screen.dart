import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import 'add_produce_screen.dart';

class VendorInventoryScreen extends StatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  State<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends State<VendorInventoryScreen> {
  final _search = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  String _filter = 'All';
  bool _loading = true;
  String? _error;

  static const _filters = [
    'All',
    'Fresh',
    'Inspect',
    'Spoiled',
    'Not assessed',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _status(Map<String, dynamic> row) {
    final value = (row['freshness_status'] ?? '').toString().toLowerCase();

    switch (value) {
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Fresh':
        return const Color(0xFF287C50);
      case 'Inspect':
        return const Color(0xFF93621B);
      case 'Spoiled':
        return const Color(0xFFA43232);
      default:
        return AppTheme.muted;
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

  String _quantity(Map<String, dynamic> row) {
    final n = (row['quantity'] as num).toDouble();

    final amount = n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

    return '$amount ${row['unit']}';
  }

  String _date(String? value) {
    final parsed = DateTime.tryParse(value ?? '')?.toLocal();

    if (parsed == null) return 'Not provided';

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  List<Map<String, dynamic>> get _visible {
    final query = _search.text.trim().toLowerCase();

    return _items.where((row) {
      final name = (row['produce_name'] ?? '').toString().toLowerCase();

      final category = (row['category'] ?? '').toString().toLowerCase();

      final matchesText = name.contains(query) || category.contains(query);

      final matchesFilter = _filter == 'All' || _status(row) == _filter;

      return matchesText && matchesFilter;
    }).toList();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await DatabaseHelper.instance.getInventory();

      if (!mounted) return;

      setState(() {
        _items = rows;
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

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProduceScreen()),
    );

    if (saved == true && mounted) {
      await _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete stock?'),
          content: Text(
            'Remove ${item['produce_name']} from inventory? '
            'This cannot be undone.',
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
                style: TextStyle(color: Color(0xFFA43232)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteInventory(
        (item['id'] as num).toInt(),
      );

      if (!mounted) return;

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock deleted successfully')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final form = GlobalKey<FormState>();

    final name = TextEditingController(text: item['produce_name'].toString());

    final quantity = TextEditingController(
      text: (item['quantity'] as num).toString(),
    );

    final notes = TextEditingController(text: item['notes']?.toString() ?? '');

    var category = (item['category'] ?? 'Other').toString();

    if (!['Fruit', 'Vegetable', 'Other'].contains(category)) {
      category = 'Other';
    }

    var unit = item['unit'].toString();

    if (!['kg', 'pieces', 'bunches', 'crates'].contains(unit)) {
      unit = 'kg';
    }

    var status = _status(item);
    var saving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.ivory,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, updateSheet) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit stock',
                            style: TextStyle(
                              color: AppTheme.forest,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: name,
                            maxLength: 60,
                            decoration: const InputDecoration(
                              labelText: 'Produce name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Produce name is required';
                              }
                              return null;
                            },
                          ),

                          DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            items: ['Fruit', 'Vegetable', 'Other']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              updateSheet(() {
                                category = value ?? category;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: quantity,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            validator: (value) {
                              final number = double.tryParse(
                                value?.trim() ?? '',
                              );

                              if (number == null ||
                                  !number.isFinite ||
                                  number <= 0) {
                                return 'Enter a positive quantity';
                              }

                              return null;
                            },
                          ),

                          DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: ['kg', 'pieces', 'bunches', 'crates']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              updateSheet(() {
                                unit = value ?? unit;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: const InputDecoration(
                              labelText: 'Recorded condition',
                            ),
                            items:
                                ['Not assessed', 'Fresh', 'Inspect', 'Spoiled']
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              updateSheet(() {
                                status = value ?? status;
                              });
                            },
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'This condition is recorded manually. '
                            'It is not a CNN prediction.',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: notes,
                            maxLength: 300,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Additional notes',
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      if (!form.currentState!.validate()) {
                                        return;
                                      }

                                      updateSheet(() {
                                        saving = true;
                                      });

                                      try {
                                        await DatabaseHelper.instance
                                            .updateInventory(
                                              (item['id'] as num).toInt(),
                                              {
                                                'produce_name': name.text
                                                    .trim(),
                                                'category': category,
                                                'quantity': double.parse(
                                                  quantity.text.trim(),
                                                ),
                                                'unit': unit,
                                                'freshness_status':
                                                    status == 'Not assessed'
                                                    ? 'unassessed'
                                                    : status.toLowerCase(),
                                                'notes':
                                                    notes.text.trim().isEmpty
                                                    ? null
                                                    : notes.text.trim(),
                                              },
                                            );

                                        if (!sheetContext.mounted) {
                                          return;
                                        }

                                        Navigator.pop(sheetContext);

                                        await _load();
                                      } catch (error) {
                                        if (!sheetContext.mounted) {
                                          return;
                                        }

                                        ScaffoldMessenger.of(sheetContext)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Update failed: $error',
                                                ),
                                              ),
                                            );

                                        updateSheet(() {
                                          saving = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.forest,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                saving ? 'Saving...' : 'Save changes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      // Wait for the bottom-sheet exit animation
      // before disposing its form controllers.
      await Future<void>.delayed(const Duration(milliseconds: 350));

      name.dispose();
      quantity.dispose();
      notes.dispose();
    }
  }

  void _details(Map<String, dynamic> item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(23),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['produce_name'].toString(),
                  style: const TextStyle(
                    fontSize: 23,
                    color: AppTheme.forest,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                _detailRow('Category', '${item['category'] ?? 'Other'}'),
                _detailRow('Quantity', _quantity(item)),
                _detailRow('Condition', _status(item)),
                _detailRow('Date added', _date(item['date_added']?.toString())),
                _detailRow(
                  'Purchase date',
                  _date(item['purchase_date']?.toString()),
                ),
                if ((item['notes'] ?? '').toString().isNotEmpty)
                  _detailRow('Notes', item['notes'].toString()),
                const SizedBox(height: 10),
                const Text(
                  'The recorded condition is manually entered '
                  'and is not a verified food safety result.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _edit(item);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _delete(item);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.forest,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _counter(String label, int value, IconData icon) {
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
            Icon(icon, color: AppTheme.forest, size: 22),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: const TextStyle(
                color: AppTheme.forest,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final status = _status(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _details(item),
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
                    color: AppTheme.sage,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['category'] == 'Fruit'
                        ? Icons.spa_outlined
                        : Icons.eco_outlined,
                    color: AppTheme.forest,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['produce_name'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.forest,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_quantity(item)}  •  '
                        '${item['category'] ?? 'Other'}',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.forest),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    final attention = _items.where((item) {
      final status = _status(item);

      return status == 'Inspect' || status == 'Spoiled';
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Produce inventory'),
        backgroundColor: AppTheme.ivory,
        foregroundColor: AppTheme.forest,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh inventory',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add produce',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),
            children: [
              const Text(
                'YOUR STOCK',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Know what you\nhave in stock.',
                style: TextStyle(
                  color: AppTheme.forest,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Review produce records and identify '
                'items that need attention.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 21),

              Row(
                children: [
                  _counter(
                    'Stock entries',
                    _items.length,
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(width: 12),
                  _counter(
                    'Need attention',
                    attention,
                    Icons.warning_amber_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 23),

              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search produce...',
                  hintStyle: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.forest,
                  ),
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
                ),
              ),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final selected = _filter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _filter = filter;
                          });
                        },
                        selectedColor: AppTheme.sage,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected ? AppTheme.forest : AppTheme.border,
                        ),
                        labelStyle: TextStyle(
                          color: AppTheme.forest,
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
                        color: AppTheme.forest,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${visible.length} items',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(35),
                    child: CircularProgressIndicator(color: AppTheme.forest),
                  ),
                )
              else if (_error != null)
                Column(
                  children: [
                    Text('Could not load inventory: $_error'),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                )
              else if (visible.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: AppTheme.forest,
                        size: 39,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _items.isEmpty
                            ? 'No stock added yet'
                            : 'No matching produce',
                        style: const TextStyle(
                          color: AppTheme.forest,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _items.isEmpty
                            ? 'Tap Add produce to create your '
                                  'first local inventory record.'
                            : 'Try a different search or filter.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...visible.map(_card),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'Inventory stored locally on this device',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
