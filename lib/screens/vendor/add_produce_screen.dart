import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'Fruit';
  String _unit = 'kg';
  DateTime? _purchaseDate;

  static const forest = AppTheme.forest;
  static const muted = AppTheme.muted;
  static const sage = AppTheme.sage;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: const BorderSide(color: forest, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          color: forest,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? today,
      firstDate: DateTime(2020),
      lastDate: today,
      helpText: 'Select stock purchase date',
    );

    if (selected != null && mounted) {
      setState(() => _purchaseDate = selected);
    }
  }

  void _previewEntry() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(sheetContext).viewInsets.bottom + 25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2_outlined, color: forest, size: 36),
                const SizedBox(height: 14),
                const Text(
                  'Stock entry preview',
                  style: TextStyle(
                    color: forest,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Review your information below. '
                  'This is a prototype preview and '
                  'has not been saved.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 22),
                _previewRow('Produce', name),
                _previewRow('Category', _category),
                _previewRow('Quantity', '$quantity $_unit'),
                _previewRow(
                  'Purchase date',
                  _purchaseDate == null
                      ? 'Not provided'
                      : _formatDate(_purchaseDate!),
                ),
                if (_notesController.text.trim().isNotEmpty)
                  _previewRow('Notes', _notesController.text.trim()),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forest,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue editing',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'What are you\nadding today?',
                style: TextStyle(
                  color: forest,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                'Record your fruits and vegetables '
                'to organise your vendor inventory.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 28),

              _fieldLabel('Produce name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: _decoration('e.g. Tomatoes, Bananas, Mangoes'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the produce name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              _fieldLabel('Produce category'),
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
              const SizedBox(height: 23),

              _fieldLabel('Quantity *'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoration('e.g. 15'),
                      validator: (value) {
                        final quantity = double.tryParse(value?.trim() ?? '');

                        if (quantity == null ||
                            !quantity.isFinite ||
                            quantity <= 0) {
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
              const SizedBox(height: 23),

              _fieldLabel('Purchase date (optional)'),
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
                      const Icon(Icons.calendar_month_outlined, color: forest),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _purchaseDate == null
                              ? 'Select purchase date'
                              : _formatDate(_purchaseDate!),
                          style: TextStyle(
                            color: _purchaseDate == null ? muted : forest,
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
                            color: muted,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _fieldLabel('Additional notes (optional)'),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'e.g. Purchased from local supplier this morning',
                ),
              ),
              const SizedBox(height: 15),

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
                        'Stock entries are not yet stored. '
                        'We will connect this form to the '
                        'local inventory database in a later phase.',
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
              const SizedBox(height: 25),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _previewEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text(
                    'Review stock entry',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
