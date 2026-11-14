import 'dart:io';

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
  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;
  static const Color border = AppTheme.border;

  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  String _filter = 'All';
  bool _loading = true;
  String? _error;

  static const List<String> _filters = [
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

  String _status(Map<String, dynamic> row) {
    final raw = (row['freshness_status'] ?? '').toString().trim().toLowerCase();

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

  String _quantity(Map<String, dynamic> row) {
    final raw = row['quantity'];

    final value = raw is num
        ? raw.toDouble()
        : double.tryParse(raw?.toString() ?? '');

    if (value == null) return 'Not provided';

    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    final unit = row['unit']?.toString() ?? '';

    return '$amount $unit'.trim();
  }

  String _date(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty) return 'Not provided';

    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return 'Not provided';

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  int? _itemId(Map<String, dynamic> item) {
    final raw = item['id'];
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  List<Map<String, dynamic>> get _visible {
    final query = _search.text.trim().toLowerCase();

    return _items.where((item) {
      final name = (item['produce_name'] ?? '').toString().toLowerCase();
      final category = (item['category'] ?? '').toString().toLowerCase();

      final matchesSearch = name.contains(query) || category.contains(query);

      final matchesFilter = _filter == 'All' || _status(item) == _filter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _countStatus(String status) {
    return _items.where((item) => _status(item) == status).length;
  }

  int get _attentionCount => _countStatus('Inspect') + _countStatus('Spoiled');

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddProduceScreen()));

    if (mounted) await _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = _itemId(item);

    if (id == null) {
      _message('Unable to identify this stock record.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Delete stock entry?',
          style: TextStyle(color: forest, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Remove ${item['produce_name'] ?? 'this produce'} '
          'from your inventory? This action cannot be undone.',
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
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteInventory(id);
      await _load();
      _message('Stock entry deleted.');
    } catch (error) {
      _message('Unable to delete stock: $error');
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final id = _itemId(item);

    if (id == null) {
      _message('Unable to identify this stock record.');
      return;
    }

    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: item['produce_name']?.toString() ?? '',
    );

    final quantityController = TextEditingController(
      text: item['quantity']?.toString() ?? '',
    );

    final notesController = TextEditingController(
      text: item['notes']?.toString() ?? '',
    );

    var category = item['category']?.toString() ?? 'Other';
    if (!['Fruit', 'Vegetable', 'Other'].contains(category)) {
      category = 'Other';
    }

    var unit = item['unit']?.toString() ?? 'kg';
    if (!['kg', 'pieces', 'bunches', 'crates'].contains(unit)) {
      unit = 'kg';
    }

    var status = _status(item);
    var saving = false;
    var saved = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.ivory,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, updateSheet) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    15,
                    22,
                    MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sheetHandle(),
                          const SizedBox(height: 19),
                          const Text(
                            'Edit stock entry',
                            style: TextStyle(
                              color: forest,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Update the details of your produce.',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: nameController,
                            maxLength: 60,
                            decoration: _fieldDecoration(
                              'Produce name',
                              Icons.eco_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a produce name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: _fieldDecoration(
                              'Category',
                              Icons.category_outlined,
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _fieldDecoration(
                              'Quantity',
                              Icons.scale_outlined,
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
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: _fieldDecoration(
                              'Unit',
                              Icons.straighten_outlined,
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
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: _fieldDecoration(
                              'Recorded condition',
                              Icons.fact_check_outlined,
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
                            'This condition is manually recorded. '
                            'It is not a CNN prediction.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 17),
                          TextFormField(
                            controller: notesController,
                            maxLength: 300,
                            maxLines: 3,
                            decoration: _fieldDecoration(
                              'Additional notes',
                              Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      updateSheet(() {
                                        saving = true;
                                      });

                                      try {
                                        await DatabaseHelper.instance
                                            .updateInventory(id, {
                                              'produce_name': nameController
                                                  .text
                                                  .trim(),
                                              'category': category,
                                              'quantity': double.parse(
                                                quantityController.text.trim(),
                                              ),
                                              'unit': unit,
                                              'freshness_status':
                                                  status == 'Not assessed'
                                                  ? 'unassessed'
                                                  : status.toLowerCase(),
                                              'notes':
                                                  notesController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : notesController.text.trim(),
                                            });

                                        saved = true;

                                        if (sheetContext.mounted) {
                                          Navigator.pop(sheetContext);
                                        }
                                      } catch (error) {
                                        if (sheetContext.mounted) {
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
                                      }
                                    },
                              icon: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(
                                saving ? 'Saving...' : 'Save changes',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: forest,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
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
      await Future<void>.delayed(const Duration(milliseconds: 350));

      nameController.dispose();
      quantityController.dispose();
      notesController.dispose();
    }

    if (saved && mounted) {
      await _load();
      _message('Stock entry updated successfully.');
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: forest),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: forest, width: 1.5),
      ),
    );
  }

  Future<void> _details(Map<String, dynamic> item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final status = _status(item);

        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _produceImage(
                      item,
                      width: double.infinity,
                      height: 165,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item['produce_name']?.toString() ?? 'Produce',
                    style: const TextStyle(
                      color: forest,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _statusBadge(status),
                  const SizedBox(height: 22),
                  const Text(
                    'Stock information',
                    style: TextStyle(
                      color: forest,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _detailRow(
                    'Category',
                    item['category']?.toString() ?? 'Other',
                  ),
                  _detailRow('Quantity', _quantity(item)),
                  _detailRow('Condition', status),
                  _detailRow('Date added', _date(item['date_added'])),
                  _detailRow('Purchase date', _date(item['purchase_date'])),
                  if ((item['notes'] ?? '').toString().trim().isNotEmpty)
                    _detailRow('Notes', item['notes'].toString()),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: sage,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: forest,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The condition shown is a manually '
                            'recorded observation, not a CNN '
                            'prediction or verified food safety result.',
                            style: TextStyle(
                              color: forest,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _edit(item);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit stock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _delete(item);
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFA43232),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            width: 115,
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

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 43,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFD8DFD5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _produceImage(
    Map<String, dynamic> item, {
    double width = 76,
    double height = 76,
  }) {
    final path = (item['image_path'] ?? item['photo_path'] ?? '').toString();

    final category = item['category']?.toString().toLowerCase() ?? '';

    final fallback = Container(
      width: width,
      height: height,
      color: sage,
      alignment: Alignment.center,
      child: Icon(
        category == 'fruit' ? Icons.spa_outlined : Icons.eco_outlined,
        color: forest,
        size: height > 100 ? 45 : 30,
      ),
    );

    if (path.isEmpty) return fallback;

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 24),
            const SizedBox(height: 16),
            Text(
              _loading || _error != null ? '--' : '$value',
              style: TextStyle(
                color: foreground,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inventoryCard(Map<String, dynamic> item) {
    final status = _status(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: () => _details(item),
          borderRadius: BorderRadius.circular(21),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _produceImage(item),
                ),
                const SizedBox(width: 13),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_quantity(item)} • '
                        '${item['category'] ?? 'Other'}',
                        maxLines: 2,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 9),
                      _statusBadge(status),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.chevron_right_rounded, color: forest),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search fruits or vegetables...',
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: forest),
        suffixIcon: _search.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _search.clear();
                  setState(() {});
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: forest, width: 1.5),
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = _filter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
              selectedColor: sage,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? forest : border),
              labelStyle: TextStyle(
                color: forest,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState() {
    final noInventory = _items.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: sage,
              shape: BoxShape.circle,
            ),
            child: Icon(
              noInventory
                  ? Icons.inventory_2_outlined
                  : Icons.search_off_rounded,
              color: forest,
              size: 32,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            noInventory ? 'Your inventory is empty' : 'No matching produce',
            style: const TextStyle(
              color: forest,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noInventory
                ? 'Start by adding fruits or vegetables '
                      'to your local stock records.'
                : 'Try changing your search or '
                      'selecting a different condition.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 15),
          if (noInventory)
            TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add produce'),
            )
          else
            TextButton(
              onPressed: () {
                _search.clear();
                setState(() {
                  _filter = 'All';
                });
              },
              child: const Text('Clear filters'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

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
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
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
        backgroundColor: forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add produce',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: forest,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 105),
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
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Review your produce records, track '
                'quantities and identify stock that '
                'needs attention.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _summaryCard(
                    label: 'Stock entries',
                    value: _items.length,
                    icon: Icons.inventory_2_outlined,
                    background: sage,
                    foreground: forest,
                  ),
                  const SizedBox(width: 11),
                  _summaryCard(
                    label: 'Need attention',
                    value: _attentionCount,
                    icon: Icons.warning_amber_rounded,
                    background: const Color(0xFFFFF0D8),
                    foreground: const Color(0xFF93621B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF287C50),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Entries marked Fresh',
                        style: TextStyle(
                          color: forest,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _loading || _error != null
                          ? '--'
                          : '${_countStatus('Fresh')}',
                      style: const TextStyle(
                        color: forest,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 27),
              const Text(
                'Find your produce',
                style: TextStyle(
                  color: forest,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _searchField(),
              const SizedBox(height: 15),
              _filterChips(),
              const SizedBox(height: 26),
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
                    _loading || _error != null
                        ? '--'
                        : '${visible.length} items',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: CircularProgressIndicator(color: forest),
                  ),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: forest,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      const Text('Could not load your inventory.'),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (visible.isEmpty)
                _emptyState()
              else
                ...visible.map(_inventoryCard),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Inventory records are stored locally '
                  'on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
