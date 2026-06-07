import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/utils/responsive.dart';
import 'package:eduaccess/core/widgets/app_badge.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import 'package:eduaccess/core/widgets/app_dialog.dart';
import 'package:eduaccess/core/widgets/app_dropdown.dart';
import 'package:eduaccess/core/widgets/app_text_field.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/widgets/app_refresh_button.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/features/academic/domain/entities/subject_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

const _categories = [
  AppDropdownItem(value: 'core', label: 'Inti'),
  AppDropdownItem(value: 'elective', label: 'Pilihan'),
  AppDropdownItem(value: 'extracurricular', label: 'Ekstrakurikuler'),
];

class MataPelajaranTab extends ConsumerStatefulWidget {
  const MataPelajaranTab({super.key});

  @override
  ConsumerState<MataPelajaranTab> createState() => _MataPelajaranTabState();
}

class _MataPelajaranTabState extends ConsumerState<MataPelajaranTab> {
  bool _isSubmitting = false;

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final allSchools = needsSchoolPicker
        ? (ref.read(dashboardSchoolsProvider).valueOrNull ?? [])
        : <DashboardSchool>[];
    String? dialogSchoolId = activeSchool?.id;
    final nameCtrl = TextEditingController();
    var selectedCategory = 'core';
    String? resultName;
    String? resultCategory;
    String? resultSchoolId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Mata Pelajaran',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            if (needsSchoolPicker) ...[
              AppDropdown<String?>(
                label: 'Sekolah',
                hint: 'Pilih sekolah',
                value: dialogSchoolId,
                items: allSchools.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
                onChanged: (v) => setD(() => dialogSchoolId = v),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppTextField(label: 'Nama Mata Pelajaran', controller: nameCtrl, hint: 'Contoh: Matematika'),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: 'Kategori',
              value: selectedCategory,
              items: _categories,
              onChanged: (v) { if (v != null) setD(() => selectedCategory = v); },
            ),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              resultName = name;
              resultCategory = selectedCategory;
              resultSchoolId = isSuperadmin ? dialogSchoolId : null;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    final name = resultName;
    if (name == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createSubject(name, resultCategory!, schoolId: resultSchoolId);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subjectsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(SubjectEntity subject) async {
    final nameCtrl = TextEditingController(text: subject.name);
    var selectedCategory = subject.category.isEmpty ? 'core' : subject.category;
    String? resultName;
    String? resultCategory;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Mata Pelajaran',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppTextField(label: 'Nama Mata Pelajaran', controller: nameCtrl, hint: 'Contoh: Matematika'),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: 'Kategori',
              value: selectedCategory,
              items: _categories,
              onChanged: (v) { if (v != null) setD(() => selectedCategory = v); },
            ),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              resultName = name;
              resultCategory = selectedCategory;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    final name = resultName;
    if (name == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateSubject(subject.id, name, resultCategory!);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subjectsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(SubjectEntity subject) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Mata Pelajaran',
      message: 'Mata pelajaran "${subject.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteSubject(subject.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subjectsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  BadgeStatus _categoryBadge(String category) => switch (category) {
    'core' => BadgeStatus.info,
    'elective' => BadgeStatus.warning,
    _ => BadgeStatus.muted,
  };

  String _categoryLabel(String category) => switch (category) {
    'core' => 'Inti',
    'elective' => 'Pilihan',
    'extracurricular' => 'Ekskul',
    _ => category,
  };

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(subjectsProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppRefreshButton(
              onRefresh: () async {
                await ref.read(cacheStoreProvider).clean();
                ref.invalidate(subjectsProvider);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton.accent(
              label: 'Tambah Mata Pelajaran',
              prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              onPressed: _isSubmitting ? null : _create,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (subjects) => AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                  child: DataTable(
                    columnSpacing: isCompact ? 12 : 24,
                    horizontalMargin: AppSpacing.md,
                    headingRowHeight: isCompact ? 42 : 48,
                    dataRowMinHeight: isCompact ? 50 : 54,
                    dataRowMaxHeight: isCompact ? 50 : 54,
                    headingTextStyle: AppTextStyles.label.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w700),
                    dataTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500),
                    columns: const [
                      DataColumn(label: SizedBox(width: 48, child: Text('No'))),
                      DataColumn(label: SizedBox(width: 220, child: Text('Nama Mata Pelajaran'))),
                      DataColumn(label: SizedBox(width: 130, child: Text('Kategori'))),
                      DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                    ],
                    rows: subjects.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                        DataCell(SizedBox(width: 220, child: Text(s.name, overflow: TextOverflow.ellipsis))),
                        DataCell(Align(alignment: Alignment.centerLeft, child: AppBadge(label: _categoryLabel(s.category), status: _categoryBadge(s.category)))),
                        DataCell(SizedBox(width: 100, child: Row(children: [
                          _actionBtn(Icons.edit_outlined, AppColors.warning, () => _edit(s)),
                          const SizedBox(width: AppSpacing.sm),
                          _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(s)),
                        ]))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 34, height: 34,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(borderRadius: AppRadius.mdAll, onTap: onTap, child: Icon(icon, color: AppColors.white, size: 18)),
    ),
  );
}
