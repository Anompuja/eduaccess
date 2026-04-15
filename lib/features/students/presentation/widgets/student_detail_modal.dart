import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/student_row_data.dart';

Future<void> showStudentDetailModal(
  BuildContext context, {
  required StudentRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StudentDetailModal(data: data),
  );
}

class StudentDetailModal extends StatelessWidget {
  final StudentRowData data;

  const StudentDetailModal({super.key, required this.data});

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
                          'Detail Siswa',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          data.email.toUpperCase(),
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
                icon: Icons.badge_outlined,
                children: [
                  _DetailItem(label: 'Student ID', value: data.studentId),
                  _DetailItem(label: 'Nama', value: data.name),
                  _DetailItem(label: 'NIS', value: data.nis),
                  _DetailItem(label: 'NISN', value: data.nisn),
                  _DetailItem(label: 'Email', value: data.email),
                  _DetailItem(label: 'Telepon', value: data.phone),
                  _DetailItem(label: 'Kelas', value: data.studentClass),
                  _DetailItem(label: 'Status', value: data.status),
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
