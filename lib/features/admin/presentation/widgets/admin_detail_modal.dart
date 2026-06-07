import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/admin_row_data.dart';

Future<void> showAdminDetailModal(
  BuildContext context, {
  required AdminRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AdminDetailModal(data: data),
  );
}

class AdminDetailModal extends StatelessWidget {
  final AdminRowData data;

  const AdminDetailModal({super.key, required this.data});

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
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Admin',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          data.nik,
                          style: AppTextStyles.bodySmSemiBold.copyWith(
                            color: AppColors.neutral500,
                            letterSpacing: 1.3,
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
              const SizedBox(height: AppSpacing.xl),
              _DetailSection(
                title: 'Profil',
                icon: Icons.admin_panel_settings_outlined,
                children: [
                  _DetailItem(label: 'Admin ID', value: data.adminId),
                  _DetailItem(
                    label: 'School ID',
                    value: data.schoolId.isEmpty ? '-' : data.schoolId,
                  ),
                  _DetailItem(label: 'Nama', value: data.name),
                  _DetailItem(
                    label: 'Email',
                    value: data.email.isEmpty ? '-' : data.email,
                  ),
                  _DetailItem(
                    label: 'Username',
                    value: data.username.isEmpty ? '-' : data.username,
                  ),
                  _DetailItem(label: 'Phone Number', value: data.phoneNumber),
                  _DetailItem(label: 'Address', value: data.address),
                  _DetailItem(label: 'Jenis Kelamin', value: data.gender),
                  _DetailItem(label: 'Agama', value: data.religion),
                  _DetailItem(label: 'Tempat Lahir', value: data.birthPlace),
                  _DetailItem(label: 'Tanggal Lahir', value: data.birthDate),
                  _DetailItem(label: 'Foto KTP', value: data.ktpImagePath),
                  _DetailItem(label: 'NIK', value: data.nik),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailSection(
                title: 'Timeline',
                icon: Icons.schedule,
                children: [
                  _DetailItem(label: 'Dibuat Pada', value: data.createdAt),
                  _DetailItem(label: 'Diperbarui Pada', value: data.updatedAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DetailItem> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Icon(icon, color: AppColors.primary700, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.bodyLgSemiBold.copyWith(
                  color: AppColors.neutral700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isOneColumn = constraints.maxWidth < 640;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: children
                    .map(
                      (item) => SizedBox(
                        width: isOneColumn
                            ? constraints.maxWidth
                            : (constraints.maxWidth - AppSpacing.md) / 2,
                        child: _DetailField(item: item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final _DetailItem item;

  const _DetailField({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.neutral500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.value,
            style: AppTextStyles.bodyLgSemiBold.copyWith(
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});
}
