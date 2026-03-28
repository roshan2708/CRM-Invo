import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/leads/lead_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../data/models/lead_model.dart';

class AddLeadView extends StatefulWidget {
  const AddLeadView({super.key});

  @override
  State<AddLeadView> createState() => _AddLeadViewState();
}

class _AddLeadViewState extends State<AddLeadView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();

  LeadStatus _selectedStatus = LeadStatus.newLead;
  DateTime _selectedDate = DateTime.now();
  bool _isEdit = false;
  String? _editId;

  final LeadController _ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    // If argument is a leadId string, it's an edit
    final arg = Get.arguments;
    if (arg is String) {
      final lead = _ctrl.getLeadById(arg);
      if (lead != null) {
        _isEdit = true;
        _editId = lead.id;
        _nameCtrl.text = lead.name;
        _phoneCtrl.text = lead.phone;
        _emailCtrl.text = lead.email;
        _notesCtrl.text = lead.notes;
        _companyCtrl.text = lead.company ?? '';
        _sourceCtrl.text = lead.source ?? '';
        _selectedStatus = lead.status;
        _selectedDate = lead.date;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    _companyCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit && _editId != null) {
      final existing = _ctrl.getLeadById(_editId!);
      if (existing != null) {
        _ctrl.updateLead(
          existing.copyWith(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            company: _companyCtrl.text.trim().isEmpty
                ? null
                : _companyCtrl.text.trim(),
            source: _sourceCtrl.text.trim().isEmpty
                ? null
                : _sourceCtrl.text.trim(),
            status: _selectedStatus,
            date: _selectedDate,
          ),
        );
      }
      Get.back();
      Get.snackbar(
        'Updated!',
        '${_nameCtrl.text.trim()} has been updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      _ctrl.addLead(
        LeadModel(
          id: 'l${DateTime.now().millisecondsSinceEpoch}',
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          company: _companyCtrl.text.trim().isEmpty
              ? null
              : _companyCtrl.text.trim(),
          source: _sourceCtrl.text.trim().isEmpty
              ? null
              : _sourceCtrl.text.trim(),
          status: _selectedStatus,
          date: _selectedDate,
          avatarIndex: DateTime.now().millisecond % 8,
        ),
      );
      Get.back();
      Get.snackbar(
        'Lead Added!',
        '${_nameCtrl.text.trim()} has been added.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: _isEdit ? 'Edit Lead' : 'Add New Lead'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.width * 0.04,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Full Name *',
                hint: 'Lead full name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              SizedBox(height: size.height * 0.025),
              CustomTextField(
                label: 'Phone *',
                hint: '+91 XXXXX XXXXX',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Phone is required'
                    : null,
              ),
              SizedBox(height: size.height * 0.025),
              CustomTextField(
                label: 'Email *',
                hint: 'email@example.com',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(
                    r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                  ).hasMatch(v.trim()))
                    return 'Invalid email';
                  return null;
                },
              ),
              SizedBox(height: size.height * 0.025),
              CustomTextField(
                label: 'Company',
                hint: 'Company name (optional)',
                controller: _companyCtrl,
                prefixIcon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: size.height * 0.025),
              CustomTextField(
                label: 'Lead Source',
                hint: 'e.g. LinkedIn, Website, Referral',
                controller: _sourceCtrl,
                prefixIcon: Icons.source_outlined,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: size.height * 0.025),
              // Status
              Text('Status', style: theme.textTheme.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LeadStatus.values.map((s) {
                  final sel = _selectedStatus == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStatus = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      child: Text(
                        s.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: sel
                              ? AppColors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: size.height * 0.025),
              // Date
              Text('Date', style: theme.textTheme.labelLarge),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.025),
              CustomTextField(
                label: 'Notes',
                hint: 'Any additional notes...',
                controller: _notesCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: size.height * 0.04),
              CustomButton(
                label: _isEdit ? 'Save Changes' : 'Add Lead',
                icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
                onPressed: _save,
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
