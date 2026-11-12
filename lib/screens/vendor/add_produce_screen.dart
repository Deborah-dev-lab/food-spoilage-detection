import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';

class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
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

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.forest, width: 1.5),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.forest,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final chosen = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select stock purchase date',
    );

    if (chosen != null && mounted) {
      setState(() => _purchaseDate = chosen);
    }
  }

  Future<void> _reviewAndSave() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final name = _name.text.trim();
    final quantity = double.parse(_quantity.text.trim());

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppTheme.forest,
                  size: 36,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Review stock entry',
                  style: TextStyle(
                    color: AppTheme.forest,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirm your stock details before saving '
                  'them to your local inventory.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                _previewRow('Produce', name),
                _previewRow('Category', _category),
                _previewRow('Quantity', '$quantity $_unit'),
                _previewRow(
                  'Purchase date',
                  _purchaseDate == null
                      ? 'Not provided'
                      : _date(_purchaseDate!),
                ),
                _previewRow('Condition', 'Not assessed'),
                if (_notes.text.trim().isNotEmpty)
                  _previewRow('Notes', _notes.text.trim()),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save to inventory'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.forest,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('Continue editing'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);

    try {
      await DatabaseHelper.instance.insertInventory({
        'produce_name': name,
        'category': _category,
        'quantity': quantity,
        'unit': _unit,
        'freshness_status': 'unassessed',
        'date_added': DateTime.now().toIso8601String(),
        'purchase_date': _purchaseDate?.toIso8601String(),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });

      if (!mounted) return;

      // Return true so VendorInventoryScreen knows
      // that a new record was successfully saved.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save stock: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Add produce'),
        backgroundColor: AppTheme.ivory,
        foregroundColor: AppTheme.forest,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(21, 18, 21, 35),
            children: [
              const Text(
                'NEW STOCK ENTRY',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'What are you\nadding today?',
                style: TextStyle(
                  color: AppTheme.forest,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Record your fruits and vegetables '
                'to organise your vendor inventory.',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              _label('Produce name *'),
              TextFormField(
                controller: _name,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('e.g. Tomatoes, Bananas, Mangoes'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the produce name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),
              _label('Produce category'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration('Select category'),
                items: const [
                  DropdownMenuItem(value: 'Fruit', child: Text('Fruit')),
                  DropdownMenuItem(
                    value: 'Vegetable',
                    child: Text('Vegetable'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),

              const SizedBox(height: 22),
              _label('Quantity *'),
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
                      decoration: _decoration('e.g. 15'),
                      validator: (value) {
                        final number = double.tryParse(value?.trim() ?? '');

                        if (number == null || !number.isFinite || number <= 0) {
                          return 'Enter a valid quantity.';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                          setState(() => _unit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              _label('Purchase date (optional)'),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppTheme.forest,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _purchaseDate == null
                              ? 'Select purchase date'
                              : _date(_purchaseDate!),
                          style: TextStyle(
                            color: _purchaseDate == null
                                ? AppTheme.muted
                                : AppTheme.forest,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_purchaseDate != null)
                        IconButton(
                          tooltip: 'Clear date',
                          onPressed: () {
                            setState(() => _purchaseDate = null);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.muted,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _label('Additional notes (optional)'),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('e.g. Purchased from local supplier'),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.sage,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.forest),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'New stock is marked Not assessed until '
                        'its condition is recorded. Entries are '
                        'stored locally on this device.',
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

              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _reviewAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving ? 'Saving...' : 'Review and save stock',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
