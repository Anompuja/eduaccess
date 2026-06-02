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
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/core/widgets/app_dropdown.dart';
import 'package:eduaccess/features/academic/domain/entities/academic_year_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';
class TahunAjaranTab extends ConsumerStatefulWidget {
  const TahunAjaranTab({super.key});

  @override
  ConsumerState<TahunAjaranTab> createState() => _TahunAjaranTabState();
}

class _TahunAjaranTabState extends ConsumerState<TahunAjaranTab> {
  bool _isSubmitting = false;

  String _formatDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<DateTime?> _pickDate(BuildContext context, {DateTime? initial}) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

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
    final descCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    String? resultName;
    String? resultDesc;
    String? resultSchoolId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Tahun Ajaran',
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
            AppTextField(label: 'Nama Tahun Ajaran', controller: nameCtrl, hint: 'Contoh: 2024/2025'),
            const SizedBox(height: AppSpacing.md),
            _datePicker(label: 'Tanggal Mulai', value: startDate, onTap: () async {
              final d = await _pickDate(ctx, initial: startDate);
              if (d != null) setD(() => startDate = d);
            }),
            const SizedBox(height: AppSpacing.md),
            _datePicker(label: 'Tanggal Selesai', value: endDate, onTap: () async {
              final d = await _pickDate(ctx, initial: endDate ?? startDate);
              if (d != null) setD(() => endDate = d);
            }),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Deskripsi (opsional)', controller: descCtrl, hint: 'Catatan tahun ajaran'),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty || startDate == null || endDate == null) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              resultName = name;
              resultDesc = descCtrl.text.trim();
              resultSchoolId = isSuperadmin ? dialogSchoolId : null;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    descCtrl.dispose();

    final name = resultName;
    if (name == null || startDate == null || endDate == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createAcademicYear(
        name, _formatIso(startDate!), _formatIso(endDate!), resultDesc ?? '',
        schoolId: resultSchoolId);
      ref.invalidate(academicYearsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(AcademicYearEntity ay) async {
    final nameCtrl = TextEditingController(text: ay.name);
    final descCtrl = TextEditingController(text: ay.description);
    DateTime? startDate = ay.startDate;
    DateTime? endDate = ay.endDate;
    String? resultName;
    String? resultDesc;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Tahun Ajaran',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppTextField(label: 'Nama Tahun Ajaran', controller: nameCtrl, hint: 'Contoh: 2024/2025'),
            const SizedBox(height: AppSpacing.md),
            _datePicker(label: 'Tanggal Mulai', value: startDate, onTap: () async {
              final d = await _pickDate(ctx, initial: startDate);
              if (d != null) setD(() => startDate = d);
            }),
            const SizedBox(height: AppSpacing.md),
            _datePicker(label: 'Tanggal Selesai', value: endDate, onTap: () async {
              final d = await _pickDate(ctx, initial: endDate ?? startDate);
              if (d != null) setD(() => endDate = d);
            }),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Deskripsi (opsional)', controller: descCtrl, hint: 'Catatan tahun ajaran'),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty || startDate == null || endDate == null) return;
              resultName = name;
              resultDesc = descCtrl.text.trim();
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    descCtrl.dispose();

    final name = resultName;
    if (name == null || startDate == null || endDate == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateAcademicYear(
        ay.id, name, _formatIso(startDate!), _formatIso(endDate!), resultDesc ?? '');
      ref.invalidate(academicYearsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _activate(AcademicYearEntity ay) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Aktifkan Tahun Ajaran',
      message: 'Aktifkan "${ay.name}" sebagai tahun ajaran aktif? Tahun ajaran lain akan dinonaktifkan.',
      confirmLabel: 'Aktifkan',
      isDanger: false,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).activateAcademicYear(ay.id);
      ref.invalidate(academicYearsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(AcademicYearEntity ay) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Tahun Ajaran',
      message: 'Tahun ajaran "${ay.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteAcademicYear(ay.id);
      ref.invalidate(academicYearsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  Widget _datePicker({required String label, required DateTime? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 2),
            Text(
              value != null ? _formatDisplay(value) : 'Pilih tanggal',
              style: AppTextStyles.bodyMd.copyWith(color: value != null ? AppColors.neutral900 : AppColors.neutral300),
            ),
          ])),
          const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.neutral500),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(academicYearsProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Align(
          alignment: Alignment.centerRight,
          child: AppButton.accent(
            label: 'Tambah Tahun Ajaran',
            prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
            onPressed: _isSubmitting ? null : _create,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (years) => AppCard(
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
                      DataColumn(label: SizedBox(width: 180, child: Text('Nama'))),
                      DataColumn(label: SizedBox(width: 120, child: Text('Mulai'))),
                      DataColumn(label: SizedBox(width: 120, child: Text('Selesai'))),
                      DataColumn(label: SizedBox(width: 100, child: Text('Status'))),
                      DataColumn(label: SizedBox(width: 160, child: Text('Aksi'))),
                    ],
                    rows: years.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ay = entry.value;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                        DataCell(SizedBox(width: 180, child: Text(ay.name, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 120, child: Text(_formatDisplay(ay.startDate)))),
                        DataCell(SizedBox(width: 120, child: Text(_formatDisplay(ay.endDate)))),
                        DataCell(Align(
                          alignment: Alignment.centerLeft,
                          child: ay.isActive
                            ? const AppBadge(label: 'Aktif', status: BadgeStatus.active)
                            : const AppBadge(label: 'Nonaktif', status: BadgeStatus.muted),
                        )),
                        DataCell(SizedBox(width: 160, child: Row(children: [
                          if (!ay.isActive)
                            _actionBtn(Icons.check_circle_outline, AppColors.success, () => _activate(ay)),
                          if (!ay.isActive) const SizedBox(width: AppSpacing.xs),
                          _actionBtn(Icons.edit_outlined, AppColors.warning, () => _edit(ay)),
                          const SizedBox(width: AppSpacing.xs),
                          _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(ay)),
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
