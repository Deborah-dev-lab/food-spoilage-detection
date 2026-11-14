import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';

class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color sage = AppTheme.sage;
  static const Color border = AppTheme.border;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _notes = TextEditingController();

  String _category = 'Fruit';
  String _unit = 'kg';
  DateTime? _purchaseDate;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatQuantity(double quantity) {
    return quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(2);
  }

  InputDecoration _decoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      prefixIcon: icon == null ? null : Icon(icon, color: forest, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFA43232)),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: forest,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFA43232),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: sage,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: forest, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: forest,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCard({
    required String category,
    required IconData icon,
    required String subtitle,
  }) {
    final selected = _category == category;

    return Expanded(
      child: InkWell(
        onTap: _saving
            ? null
            : () {
                setState(() {
                  _category = category;
                });
              },
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected ? sage : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? forest : border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: forest, size: 29),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? forest : muted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                category,
                style: const TextStyle(
                  color: forest,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select stock purchase date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: forest,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: forest,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _purchaseDate = selected;
      });
    }
  }

  Future<void> _reviewAndSave() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final quantity = double.parse(_quantity.text.trim());
    final category = _category;
    final unit = _unit;
    final purchaseDate = _purchaseDate;
    final notes = _notes.text.trim();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              23,
              17,
              23,
              25 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 43,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DFD5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: sage,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.fact_check_outlined,
                    color: forest,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Review your stock',
                  style: TextStyle(
                    color: forest,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Make sure everything looks correct '
                  'before adding this produce to your inventory.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 23),
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: AppTheme.ivory,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      _previewRow('Produce', name),
                      _previewRow('Category', category),
                      _previewRow(
                        'Quantity',
                        '${_formatQuantity(quantity)} $unit',
                      ),
                      _previewRow(
                        'Purchase date',
                        purchaseDate == null
                            ? 'Not provided'
                            : _date(purchaseDate),
                      ),
                      _previewRow('Condition', 'Not assessed'),
                      if (notes.isNotEmpty) _previewRow('Notes', notes),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sage,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: forest, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'New produce is recorded as '
                          'Not assessed. You can update its '
                          'condition later in Inventory.',
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
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext, true);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Confirm and save',
                      style: TextStyle(fontWeight: FontWeight.w800),
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
                const SizedBox(height: 7),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext, false);
                    },
                    child: const Text(
                      'Continue editing',
                      style: TextStyle(
                        color: forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _saving = true;
    });

    try {
      await DatabaseHelper.instance.insertInventory({
        'produce_name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'freshness_status': 'unassessed',
        'date_added': DateTime.now().toIso8601String(),
        'purchase_date': purchaseDate?.toIso8601String(),
        'notes': notes.isEmpty ? null : notes,
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save stock: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

  Widget _bottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        13,
        20,
        13 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _reviewAndSave,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward_rounded),
          label: Text(
            _saving ? 'Saving stock...' : 'Review stock entry',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
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
          'Add produce',
          style: TextStyle(
            color: forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
        ),
      ),
      bottomNavigationBar: _bottomAction(),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(21, 18, 21, 35),
            children: [
              const Text(
                'NEW STOCK ENTRY',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'What are you\nadding today?',
                style: TextStyle(
                  color: forest,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                'Add your produce details to keep your '
                'vendor inventory organised and up to date.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: forest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: sage,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              const Text(
                'STEP 1 OF 2  ·  ENTER DETAILS',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 28),
              _sectionTitle(
                'Produce details',
                'Tell us what you are adding.',
                Icons.eco_outlined,
              ),
              const SizedBox(height: 19),
              _label('Produce name', required: true),
              TextFormField(
                controller: _name,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'e.g. Tomatoes, Bananas, Mangoes',
                  icon: Icons.shopping_basket_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the produce name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _label('Produce category'),
              Row(
                children: [
                  _categoryCard(
                    category: 'Fruit',
                    icon: Icons.spa_outlined,
                    subtitle: 'Fruits and similar produce',
                  ),
                  const SizedBox(width: 12),
                  _categoryCard(
                    category: 'Vegetable',
                    icon: Icons.eco_outlined,
                    subtitle: 'Vegetables and greens',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _sectionTitle(
                'Stock quantity',
                'Record how much produce you have.',
                Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 18),
              _label('Quantity', required: true),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoration(
                        'e.g. 15',
                        icon: Icons.scale_outlined,
                      ),
                      validator: (value) {
                        final number = double.tryParse(value?.trim() ?? '');

                        if (number == null || !number.isFinite || number <= 0) {
                          return 'Enter a positive quantity.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      isExpanded: true,
                      decoration: _decoration('Unit'),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(
                          value: 'pieces',
                          child: Text('pieces'),
                        ),
                        DropdownMenuItem(
                          value: 'bunches',
                          child: Text('bunches'),
                        ),
                        DropdownMenuItem(
                          value: 'crates',
                          child: Text('crates'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _unit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _sectionTitle(
                'Purchase information',
                'Optional details about this stock.',
                Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 18),
              _label('Purchase date'),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: forest,
                        size: 21,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          _purchaseDate == null
                              ? 'Select purchase date'
                              : _date(_purchaseDate!),
                          style: TextStyle(
                            color: _purchaseDate == null ? muted : forest,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_purchaseDate != null)
                        IconButton(
                          tooltip: 'Clear purchase date',
                          onPressed: () {
                            setState(() {
                              _purchaseDate = null;
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: muted,
                            size: 19,
                          ),
                        )
                      else
                        const Icon(Icons.chevron_right_rounded, color: forest),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _label('Additional notes'),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'e.g. Purchased from local supplier',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 23),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: sage,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: forest, size: 23),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New stock is marked Not assessed until '
                        'its condition is manually recorded. '
                        'Your inventory is stored locally '
                        'on this device.',
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
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'FreshTrack · Vendor workspace',
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
