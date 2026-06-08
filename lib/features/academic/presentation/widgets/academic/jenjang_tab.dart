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
import 'package:eduaccess/core/widgets/app_text_field.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/widgets/app_refresh_button.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/core/widgets/app_dropdown.dart';
import 'package:eduaccess/features/academic/domain/entities/education_level_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

class JenjangTab extends ConsumerStatefulWidget {
  const JenjangTab({super.key});

  @override
  ConsumerState<JenjangTab> createState() => _JenjangTabState();
}

class _JenjangTabState extends ConsumerState<JenjangTab> {
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
    final controller = TextEditingController();
    String? resultName;
    String? resultSchoolId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Jenjang',
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
            AppTextField(label: 'Nama Jenjang', controller: controller, hint: 'Contoh: SD, SMP, SMA'),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              resultName = name;
              resultSchoolId = isSuperadmin ? dialogSchoolId : null;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    final name = resultName;
    if (name == null || !mounted) {
      controller.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createLevel(name, schoolId: resultSchoolId);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(levelsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(EducationLevelEntity level) async {
    final controller = TextEditingController(text: level.name);
    final saved = await _showDialog(
      title: 'Edit Jenjang',
      content: AppTextField(label: 'Nama Jenjang', controller: controller, hint: 'Contoh: SD, SMP, SMA'),
    );
    final name = controller.text.trim();
    if (!saved || name.isEmpty || !mounted) {
      controller.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateLevel(level.id, name);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(levelsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(EducationLevelEntity level, List<dynamic> classes) async {
    final hasClasses = classes.any((c) => (c as dynamic).educationLevelId == level.id);
    if (hasClasses) {
      _showInfo('Jenjang Tidak Bisa Dihapus', 'Masih ada kelas yang terhubung ke jenjang ini. Hapus kelas terlebih dahulu.');
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Jenjang',
      message: 'Jenjang "${level.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteLevel(level.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(levelsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showDialog({required String title, required Widget content}) async {
    bool saved = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        actions: [
          AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
          AppButton.primary(
            label: 'Simpan',
            onPressed: () {
              saved = true;
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    return saved;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: Text(message, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700)),
        actions: [AppButton.primary(label: 'Tutup', onPressed: () => Navigator.of(ctx).pop())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelsAsync = ref.watch(levelsProvider);
    final classesAsync = ref.watch(classesProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppRefreshButton(
                onRefresh: () async {
                  await ref.read(cacheStoreProvider).clean();
                  ref.invalidate(levelsProvider);
                  ref.invalidate(classesProvider);
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.accent(
                label: 'Tambah Jenjang',
                prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                onPressed: _isSubmitting ? null : _create,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          levelsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
            data: (levels) => AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
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
                          DataColumn(label: SizedBox(width: 200, child: Text('Nama Jenjang'))),
                          DataColumn(label: SizedBox(width: 150, child: Text('Jumlah Kelas'))),
                          DataColumn(label: SizedBox(width: 120, child: Text('Status'))),
                          DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                        ],
                        rows: levels.asMap().entries.map((entry) {
                          final i = entry.key;
                          final level = entry.value;
                          final classCount = classesAsync.valueOrNull?.where((c) => c.educationLevelId == level.id).length ?? 0;
                          return DataRow(cells: [
                            DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                            DataCell(SizedBox(width: 200, child: Text(level.name, overflow: TextOverflow.ellipsis))),
                            DataCell(SizedBox(width: 150, child: Text('$classCount kelas'))),
                            const DataCell(Align(alignment: Alignment.centerLeft, child: AppBadge(label: 'Aktif', status: BadgeStatus.active))),
                            DataCell(SizedBox(width: 100, child: _actions(
                              onEdit: () => _edit(level),
                              onDelete: () => _delete(level, classesAsync.valueOrNull ?? []),
                            ))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions({required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Row(children: [
      _actionBtn(Icons.edit_outlined, AppColors.warning, onEdit),
      const SizedBox(width: AppSpacing.sm),
      _actionBtn(Icons.delete_outline_rounded, AppColors.error, onDelete),
    ]);
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 34, height: 34,
      child: Material(
        color: color,
        borderRadius: AppRadius.mdAll,
        child: InkWell(borderRadius: AppRadius.mdAll, onTap: onTap, child: Icon(icon, color: AppColors.white, size: 18)),
      ),
    );
  }
}
