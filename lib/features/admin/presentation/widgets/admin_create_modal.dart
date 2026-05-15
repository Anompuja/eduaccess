import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

Future<void> showAdminCreateModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const AdminCreateModal(),
  );
}

class AdminCreateModal extends StatefulWidget {
  const AdminCreateModal({super.key});

  @override
  State<AdminCreateModal> createState() => _AdminCreateModalState();
}

class _AdminCreateModalState extends State<AdminCreateModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _nikCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _nikCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nikCtrl.dispose();
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
                          'Tambah Admin Baru',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'UI form create saja, belum ada logic simpan data.',
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
                            label: 'Nama',
                            hint: 'Masukkan nama admin',
                            controller: _nameCtrl,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Phone Number',
                            hint: 'Masukkan nomor telepon',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'Address',
                            hint: 'Masukkan alamat',
                            controller: _addressCtrl,
                            keyboardType: TextInputType.streetAddress,
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: AppTextField(
                            label: 'NIK',
                            hint: 'Masukkan NIK',
                            controller: _nikCtrl,
                            keyboardType: TextInputType.number,
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
                  AppButton.accent(
                    label: 'Simpan Admin',
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
}
