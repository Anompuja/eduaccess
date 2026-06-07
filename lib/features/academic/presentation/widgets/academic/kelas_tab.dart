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
import 'package:eduaccess/features/academic/domain/entities/education_level_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

class KelasTab extends ConsumerStatefulWidget {
  const KelasTab({super.key});

  @override
  ConsumerState<KelasTab> createState() => _KelasTabState();
}

class _KelasTabState extends ConsumerState<KelasTab> {
  bool _isSubmitting = false;
  String _filterLevelId = 'all';

  Future<void> _create(List<EducationLevelEntity> allLevels) async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final allSchools = needsSchoolPicker
        ? (ref.read(dashboardSchoolsProvider).valueOrNull ?? [])
        : <DashboardSchool>[];
    String? dialogSchoolId = activeSchool?.id;
    String? selectedLevelId = needsSchoolPicker ? null : (allLevels.isNotEmpty ? allLevels.first.id : null);

    if (!needsSchoolPicker && allLevels.isEmpty) {
      _showInfo('Jenjang Belum Ada', 'Tambahkan jenjang pendidikan terlebih dahulu.');
      return;
    }

    final nameCtrl = TextEditingController();

    String? resultLevelId;
    String? resultName;
    String? resultSchoolId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) {
          final filteredLevels = needsSchoolPicker && dialogSchoolId != null
              ? allLevels.where((l) => l.schoolId == dialogSchoolId).toList()
              : needsSchoolPicker ? <EducationLevelEntity>[] : allLevels;
          return AppDialog(
            title: 'Tambah Kelas',
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              if (needsSchoolPicker) ...[
                AppDropdown<String?>(
                  label: 'Sekolah',
                  hint: 'Pilih sekolah',
                  value: dialogSchoolId,
                  items: allSchools.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
                  onChanged: (v) => setD(() { dialogSchoolId = v; selectedLevelId = null; }),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (filteredLevels.isNotEmpty)
                AppDropdown<String>(
                  label: 'Jenjang',
                  value: selectedLevelId ?? filteredLevels.first.id,
                  items: filteredLevels.map((l) => AppDropdownItem(value: l.id, label: l.name)).toList(),
                  onChanged: (v) { if (v != null) setD(() => selectedLevelId = v); },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    needsSchoolPicker ? 'Pilih sekolah untuk melihat jenjang' : 'Belum ada jenjang tersedia',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(label: 'Nama Kelas', controller: nameCtrl, hint: 'Contoh: Kelas 10'),
            ]),
            actions: [
              AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
              AppButton.primary(label: 'Simpan', onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                if (needsSchoolPicker && dialogSchoolId == null) return;
                final usedLevels = needsSchoolPicker && dialogSchoolId != null
                    ? allLevels.where((l) => l.schoolId == dialogSchoolId).toList()
                    : allLevels;
                final levelId = selectedLevelId ?? (usedLevels.isNotEmpty ? usedLevels.first.id : null);
                if (levelId == null) return;
                resultLevelId = levelId;
                resultName = name;
                resultSchoolId = isSuperadmin ? dialogSchoolId : null;
                Navigator.of(ctx).pop();
              }),
            ],
          );
        },
      ),
    );
    final levelId = resultLevelId;
    final name = resultName;
    if (levelId == null || name == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createClass(levelId, name, schoolId: resultSchoolId);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(ClassEntity kelas, List<EducationLevelEntity> levels) async {
    final nameCtrl = TextEditingController(text: kelas.name);
    var selectedLevelId = kelas.educationLevelId;
    String? resultName;
    String? resultLevelId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Kelas',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppDropdown<String>(
              label: 'Jenjang',
              value: selectedLevelId,
              items: levels.map((l) => AppDropdownItem(value: l.id, label: l.name)).toList(),
              onChanged: (v) { if (v != null) setD(() => selectedLevelId = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Nama Kelas', controller: nameCtrl, hint: 'Contoh: Kelas 10'),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              resultName = name;
              resultLevelId = selectedLevelId;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    final name = resultName;
    final levelId = resultLevelId;
    if (name == null || levelId == null || !mounted) {
      nameCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    nameCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateClass(kelas.id, levelId, name);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(ClassEntity kelas, List<dynamic> subClasses) async {
    final hasSubs = subClasses.any((s) => (s as dynamic).classId == kelas.id);
    if (hasSubs) {
      _showInfo('Kelas Tidak Bisa Dihapus', 'Masih ada sub-kelas yang terhubung. Hapus sub-kelas terlebih dahulu.');
      return;
    }
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Kelas',
      message: 'Kelas "${kelas.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteClass(kelas.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classesProvider);
      if (_filterLevelId == kelas.id) setState(() => _filterLevelId = 'all');
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
    final classesAsync = ref.watch(classesProvider);
    final levelsAsync = ref.watch(levelsProvider);
    final subClassesAsync = ref.watch(subClassesProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final levels = levelsAsync.valueOrNull ?? [];

    final filtered = classesAsync.valueOrNull == null
        ? <ClassEntity>[]
        : _filterLevelId == 'all'
            ? classesAsync.valueOrNull!
            : classesAsync.valueOrNull!.where((c) => c.educationLevelId == _filterLevelId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isCompact)
          Column(children: [
            _levelFilter(levels),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                AppRefreshButton(
                  onRefresh: () async {
                    await ref.read(cacheStoreProvider).clean();
                    ref.invalidate(classesProvider);
                    ref.invalidate(levelsProvider);
                    ref.invalidate(subClassesProvider);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.accent(
                    label: 'Tambah Kelas',
                    prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                    onPressed: _isSubmitting ? null : () => _create(levels),
                  ),
                ),
              ],
            ),
          ])
        else
          Row(children: [
            SizedBox(width: 260, child: _levelFilter(levels)),
            const Spacer(),
            AppRefreshButton(
              onRefresh: () async {
                await ref.read(cacheStoreProvider).clean();
                ref.invalidate(classesProvider);
                ref.invalidate(levelsProvider);
                ref.invalidate(subClassesProvider);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton.accent(
              label: 'Tambah Kelas',
              prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              onPressed: _isSubmitting ? null : () => _create(levels),
            ),
          ]),
        const SizedBox(height: AppSpacing.md),
        classesAsync.when(
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
                      DataColumn(label: SizedBox(width: 200, child: Text('Nama Kelas'))),
                      DataColumn(label: SizedBox(width: 160, child: Text('Jenjang'))),
                      DataColumn(label: SizedBox(width: 150, child: Text('Sub-Kelas'))),
                      DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                    ],
                    rows: filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final kelas = entry.value;
                      final levelName = levels.where((l) => l.id == kelas.educationLevelId).firstOrNull?.name ?? '-';
                      final subCount = subClassesAsync.valueOrNull?.where((s) => s.classId == kelas.id).length ?? 0;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                        DataCell(SizedBox(width: 200, child: Text(kelas.name, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 160, child: Text(levelName, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 150, child: Text('$subCount sub-kelas'))),
                        DataCell(SizedBox(width: 100, child: _actions(
                          onEdit: () => _edit(kelas, levels),
                          onDelete: () => _delete(kelas, subClassesAsync.valueOrNull ?? []),
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

  Widget _levelFilter(List<EducationLevelEntity> levels) => AppDropdown<String>(
    label: 'Filter Jenjang',
    value: _filterLevelId,
    items: [
      const AppDropdownItem(value: 'all', label: 'Semua Jenjang'),
      ...levels.map((l) => AppDropdownItem(value: l.id, label: l.name)),
    ],
    onChanged: (v) { if (v != null) setState(() => _filterLevelId = v); },
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
