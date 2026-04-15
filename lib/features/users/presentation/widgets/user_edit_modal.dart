import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/user_row_data.dart';

Future<void> showUserEditModal(
  BuildContext context, {
  required UserRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => UserEditModal(data: data),
  );
}

class UserEditModal extends StatefulWidget {
  final UserRowData data;

  const UserEditModal({super.key, required this.data});

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;
  late String _statusValue;

  static const List<String> _statusOptions = ['Aktif', 'Nonaktif'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _emailCtrl = TextEditingController(text: widget.data.email);
    _roleCtrl = TextEditingController(text: widget.data.role);
    _phoneCtrl = TextEditingController(text: widget.data.phone);
    _statusValue = _statusOptions.contains(widget.data.status)
        ? widget.data.status
        : _statusOptions.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Data User',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'UI form edit saja, belum ada logic simpan perubahan.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.neutral700,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final oneColumn = constraints.maxWidth < 620;
                    final fieldWidth = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2;

                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Nama User',
                            hint: 'Masukkan nama user',
                            controller: _nameCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Email',
                            hint: 'Masukkan email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Role',
                            hint: 'Contoh: Admin / Staff / Guru',
                            controller: _roleCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'No. Telepon',
                            hint: 'Masukkan nomor telepon',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _dropdownField(
                            label: 'Status',
                            value: _statusValue,
                            items: _statusOptions,
                            onChanged: (v) => setState(() => _statusValue = v),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: 'Batal',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton.primary(
                    label: 'Simpan Perubahan',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          decoration: const InputDecoration(),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ],
    );
  }
}
