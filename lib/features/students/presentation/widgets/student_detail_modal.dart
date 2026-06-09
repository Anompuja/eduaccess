import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/linked_parent_data.dart';
import '../../data/models/student_row_data.dart';
import '../providers/students_provider.dart';
import 'link_parent_modal.dart';

Future<void> showStudentDetailModal(
  BuildContext context, {
  required StudentRowData data,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => StudentDetailModal(data: data),
  );
}

class StudentDetailModal extends ConsumerWidget {
  final StudentRowData data;

  const StudentDetailModal({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _ParentsSection(studentId: data.studentId),
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

// ── Parents section ───────────────────────────────────────────────────────────
class _ParentsSection extends ConsumerWidget {
  final String studentId;

  const _ParentsSection({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(studentParentsProvider(studentId));

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
                child: const Icon(
                  Icons.family_restroom_rounded,
                  color: AppColors.primary700,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'ORANG TUA',
                  style: AppTextStyles.bodyLgSemiBold.copyWith(
                    color: AppColors.neutral700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              AppButton.secondary(
                label: 'Tambah',
                prefixIcon: const Icon(Icons.add, size: 16),
                onPressed: () async {
                  await showLinkParentModal(context, studentId: studentId);
                  ref.invalidate(studentParentsProvider(studentId));
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          parentsAsync.when(
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (e, _) => Text(
              e.toString(),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
            ),
            data: (parents) {
              if (parents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'Belum ada orang tua yang ditautkan',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: parents
                    .map((p) => _ParentRow(
                          parent: p,
                          studentId: studentId,
                          onUnlinked: () =>
                              ref.invalidate(studentParentsProvider(studentId)),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParentRow extends ConsumerWidget {
  final LinkedParentData parent;
  final String studentId;
  final VoidCallback onUnlinked;

  const _ParentRow({
    required this.parent,
    required this.studentId,
    required this.onUnlinked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary300,
            child: Text(
              _initials(parent.name),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      parent.name,
                      style: AppTextStyles.bodyMdSemiBold.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    if (parent.isPrimary) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Utama',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${parent.email} · ${_relationshipLabel(parent.relationship)}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link_off_rounded, size: 20),
            color: AppColors.error,
            tooltip: 'Putuskan tautan',
            onPressed: () => _confirmUnlink(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUnlink(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Putuskan tautan?'),
        content: Text(
          'Apakah kamu yakin ingin melepas tautan ${parent.name} dari siswa ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Ya, putuskan',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(unlinkParentProvider((
        studentId: studentId,
        parentId: parent.parentId,
      )).future);
      onUnlinked();
    } catch (_) {
      // Error is silently absorbed — the provider will keep old state
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _relationshipLabel(String rel) => switch (rel) {
    'father' => 'Ayah',
    'mother' => 'Ibu',
    'guardian' => 'Wali',
    _ => 'Lainnya',
  };
}

// ── Shared section widget ──────────────────────────────────────────────────────
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
