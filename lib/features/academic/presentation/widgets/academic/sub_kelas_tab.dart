import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/utils/responsive.dart';
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
import 'package:eduaccess/features/academic/domain/entities/class_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/sub_class_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

class SubKelasTab extends ConsumerStatefulWidget {
  const SubKelasTab({super.key});

  @override
  ConsumerState<SubKelasTab> createState() => _SubKelasTabState();
}

class _SubKelasTabState extends ConsumerState<SubKelasTab> {
  bool _isSubmitting = false;
  String _filterClassId = 'all';

  Future<void> _create(List<ClassEntity> allClasses) async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final allSchools = needsSchoolPicker
        ? (ref.read(dashboardSchoolsProvider).valueOrNull ?? [])
        : <DashboardSchool>[];
    String? dialogSchoolId = activeSchool?.id;
    String? selectedClassId = needsSchoolPicker ? null : (allClasses.isNotEmpty ? allClasses.first.id : null);

    if (!needsSchoolPicker && allClasses.isEmpty) {
      _showInfo('Kelas Belum Ada', 'Tambahkan kelas terlebih dahulu.');
      return;
    }

    final nameCtrl = TextEditingController();

    String? resultClassId;
    String? resultName;
    String? resultSchoolId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) {
          final filteredClasses = needsSchoolPicker && dialogSchoolId != null
              ? allClasses.where((c) => c.schoolId == dialogSchoolId).toList()
              : needsSchoolPicker ? <ClassEntity>[] : allClasses;
          return AppDialog(
            title: 'Tambah Sub-Kelas',
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              if (needsSchoolPicker) ...[
                AppDropdown<String?>(
                  label: 'Sekolah',
                  hint: 'Pilih sekolah',
                  value: dialogSchoolId,
                  items: allSchools.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
                  onChanged: (v) => setD(() { dialogSchoolId = v; selectedClassId = null; }),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (filteredClasses.isNotEmpty)
                AppDropdown<String>(
                  label: 'Kelas',
                  value: selectedClassId ?? filteredClasses.first.id,
                  items: filteredClasses.map((c) => AppDropdownItem(value: c.id, label: c.name)).toList(),
                  onChanged: (v) { if (v != null) setD(() => selectedClassId = v); },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    needsSchoolPicker ? 'Pilih sekolah untuk melihat kelas' : 'Belum ada kelas tersedia',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(label: 'Nama Sub-Kelas', controller: nameCtrl, hint: 'Contoh: IPA 1'),
            ]),
            actions: [
              AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
              AppButton.primary(label: 'Simpan', onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                if (needsSchoolPicker && dialogSchoolId == null) return;
                final usedClasses = needsSchoolPicker && dialogSchoolId != null
                    ? allClasses.where((c) => c.schoolId == dialogSchoolId).toList()
                    : allClasses;
                final classId = selectedClassId ?? (usedClasses.isNotEmpty ? usedClasses.first.id : null);
                if (classId == null) return;
                resultClassId = classId;
                resultName = name;
                resultSchoolId = isSuperadmin ? dialogSchoolId : null;
                Navigator.of(ctx).pop();
              }),
            ],
          );
        },
      ),
    );
    final classId = resultClassId;
    final name = resultName;
    if (classId == null || name == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createSubClass(classId, name, schoolId: resultSchoolId);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subClassesProvider);
      ref.invalidate(classroomsProvider); // cascade: classrooms reference sub-classes
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(SubClassEntity sub, List<ClassEntity> classes) async {
    final nameCtrl = TextEditingController(text: sub.name);
    var selectedClassId = sub.classId;
    String? resultName;
    String? resultClassId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Sub-Kelas',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppDropdown<String>(
              label: 'Kelas',
              value: selectedClassId,
              items: classes.map((c) => AppDropdownItem(value: c.id, label: c.name)).toList(),
              onChanged: (v) { if (v != null) setD(() => selectedClassId = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Nama Sub-Kelas', controller: nameCtrl, hint: 'Contoh: IPA 1'),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              resultName = name;
              resultClassId = selectedClassId;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    final name = resultName;
    final classId = resultClassId;
    if (name == null || classId == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateSubClass(sub.id, classId, name);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subClassesProvider);
      ref.invalidate(classroomsProvider); // cascade: classrooms reference sub-classes
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(SubClassEntity sub) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Sub-Kelas',
      message: 'Sub-kelas "${sub.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteSubClass(sub.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(subClassesProvider);
      ref.invalidate(classroomsProvider); // cascade: classrooms reference sub-classes
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  void _showInfo(String title, String msg) => showDialog<void>(
    context: context,
    builder: (ctx) => AppDialog(
      title: title,
      content: Text(msg, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700)),
      actions: [AppButton.primary(label: 'Tutup', onPressed: () => Navigator.of(ctx).pop())],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final subClassesAsync = ref.watch(subClassesProvider);
    final classesAsync = ref.watch(classesProvider);
    final levelsAsync = ref.watch(levelsProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final classes = classesAsync.valueOrNull ?? [];
    final levels = levelsAsync.valueOrNull ?? [];

    final filtered = subClassesAsync.valueOrNull == null
        ? <SubClassEntity>[]
        : _filterClassId == 'all'
            ? subClassesAsync.valueOrNull!
            : subClassesAsync.valueOrNull!.where((s) => s.classId == _filterClassId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isCompact)
          Column(children: [
            _classFilter(classes),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                AppRefreshButton(
                  onRefresh: () async {
                    await ref.read(cacheStoreProvider).clean();
                    ref.invalidate(subClassesProvider);
                    ref.invalidate(classesProvider);
                    ref.invalidate(levelsProvider);
                    ref.invalidate(classroomsProvider); // cascade
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.accent(
                    label: 'Tambah Sub-Kelas',
                    prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                    onPressed: _isSubmitting ? null : () => _create(classes),
                  ),
                ),
              ],
            ),
          ])
        else
          Row(children: [
            SizedBox(width: 260, child: _classFilter(classes)),
            const Spacer(),
            AppRefreshButton(
              onRefresh: () async {
                await ref.read(cacheStoreProvider).clean();
                ref.invalidate(subClassesProvider);
                ref.invalidate(classesProvider);
                ref.invalidate(levelsProvider);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton.accent(
              label: 'Tambah Sub-Kelas',
              prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              onPressed: _isSubmitting ? null : () => _create(classes),
            ),
          ]),
        const SizedBox(height: AppSpacing.md),
        subClassesAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (_) => AppCard(
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
                      DataColumn(label: SizedBox(width: 180, child: Text('Nama Sub-Kelas'))),
                      DataColumn(label: SizedBox(width: 160, child: Text('Kelas'))),
                      DataColumn(label: SizedBox(width: 140, child: Text('Jenjang'))),
                      DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                    ],
                    rows: filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final sub = entry.value;
                      final kelasName = classes.where((c) => c.id == sub.classId).firstOrNull?.name ?? '-';
                      final levelId = classes.where((c) => c.id == sub.classId).firstOrNull?.educationLevelId ?? '';
                      final levelName = levels.where((l) => l.id == levelId).firstOrNull?.name ?? '-';
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                        DataCell(SizedBox(width: 180, child: Text(sub.name, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 160, child: Text(kelasName, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 140, child: Text(levelName, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 100, child: _actions(
                          onEdit: () => _edit(sub, classes),
                          onDelete: () => _delete(sub),
                        ))),
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

  Widget _classFilter(List<ClassEntity> classes) => AppDropdown<String>(
    label: 'Filter Kelas',
    value: _filterClassId,
    items: [
      const AppDropdownItem(value: 'all', label: 'Semua Kelas'),
      ...classes.map((c) => AppDropdownItem(value: c.id, label: c.name)),
    ],
    onChanged: (v) { if (v != null) setState(() => _filterClassId = v); },
  );

  Widget _actions({required VoidCallback onEdit, required VoidCallback onDelete}) =>
    Row(children: [
      _actionBtn(Icons.edit_outlined, AppColors.warning, onEdit),
      const SizedBox(width: AppSpacing.sm),
      _actionBtn(Icons.delete_outline_rounded, AppColors.error, onDelete),
    ]);

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 34, height: 34,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(borderRadius: AppRadius.mdAll, onTap: onTap, child: Icon(icon, color: AppColors.white, size: 18)),
    ),
  );
}
