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
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/features/academic/domain/entities/schedule_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

const _shiftTypes = [
  AppDropdownItem(value: 'morning', label: 'Pagi'),
  AppDropdownItem(value: 'afternoon', label: 'Siang'),
  AppDropdownItem(value: 'full_day', label: 'Seharian'),
];

class JadwalTab extends ConsumerStatefulWidget {
  const JadwalTab({super.key});

  @override
  ConsumerState<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends ConsumerState<JadwalTab> {
  bool _isSubmitting = false;

  Future<TimeOfDay?> _pickTime(BuildContext context, {TimeOfDay? initial}) async {
    return showTimePicker(context: context, initialTime: initial ?? TimeOfDay.now());
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
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
    var selectedShift = 'morning';
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Jadwal',
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
            AppDropdown<String>(
              label: 'Tipe Sesi',
              value: selectedShift,
              items: _shiftTypes,
              onChanged: (v) { if (v != null) setD(() => selectedShift = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            _timePicker(label: 'Jam Mulai', value: startTime, onTap: () async {
              final t = await _pickTime(ctx, initial: startTime);
              if (t != null) setD(() => startTime = t);
            }),
            const SizedBox(height: AppSpacing.md),
            _timePicker(label: 'Jam Selesai', value: endTime, onTap: () async {
              final t = await _pickTime(ctx, initial: endTime ?? startTime);
              if (t != null) setD(() => endTime = t);
            }),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              if (startTime == null || endTime == null) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              saved = true;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );

    if (!saved || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createSchedule(
        selectedShift, _formatTime(startTime!), _formatTime(endTime!),
        schoolId: isSuperadmin ? dialogSchoolId : null);
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(ScheduleEntity schedule) async {
    var selectedShift = _shiftTypes.any((s) => s.value == schedule.shiftType) ? schedule.shiftType : 'morning';
    TimeOfDay? startTime = _parseTime(schedule.startTime);
    TimeOfDay? endTime = _parseTime(schedule.endTime);
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Jadwal',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppDropdown<String>(
              label: 'Tipe Sesi',
              value: selectedShift,
              items: _shiftTypes,
              onChanged: (v) { if (v != null) setD(() => selectedShift = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            _timePicker(label: 'Jam Mulai', value: startTime, onTap: () async {
              final t = await _pickTime(ctx, initial: startTime);
              if (t != null) setD(() => startTime = t);
            }),
            const SizedBox(height: AppSpacing.md),
            _timePicker(label: 'Jam Selesai', value: endTime, onTap: () async {
              final t = await _pickTime(ctx, initial: endTime ?? startTime);
              if (t != null) setD(() => endTime = t);
            }),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              if (startTime == null || endTime == null) return;
              saved = true;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );

    if (!saved || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateSchedule(
        schedule.id, selectedShift, _formatTime(startTime!), _formatTime(endTime!));
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(ScheduleEntity schedule) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Jadwal',
      message: 'Jadwal "${_shiftLabel(schedule.shiftType)} (${schedule.startTime} – ${schedule.endTime})" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteSchedule(schedule.id);
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  String _shiftLabel(String shift) => switch (shift) {
    'morning' => 'Pagi',
    'afternoon' => 'Siang',
    'full_day' => 'Seharian',
    _ => shift,
  };

  BadgeStatus _shiftBadge(String shift) => switch (shift) {
    'morning' => BadgeStatus.info,
    'afternoon' => BadgeStatus.warning,
    _ => BadgeStatus.success,
  };

  Widget _timePicker({required String label, required TimeOfDay? value, required VoidCallback onTap}) {
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
              value != null ? value.format(context) : 'Pilih jam',
              style: AppTextStyles.bodyMd.copyWith(color: value != null ? AppColors.neutral900 : AppColors.neutral300),
            ),
          ])),
          const Icon(Icons.access_time_outlined, size: 18, color: AppColors.neutral500),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(schedulesProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Align(
          alignment: Alignment.centerRight,
          child: AppButton.accent(
            label: 'Tambah Jadwal',
            prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
            onPressed: _isSubmitting ? null : _create,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (schedules) => AppCard(
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
                      DataColumn(label: SizedBox(width: 130, child: Text('Tipe Sesi'))),
                      DataColumn(label: SizedBox(width: 110, child: Text('Jam Mulai'))),
                      DataColumn(label: SizedBox(width: 110, child: Text('Jam Selesai'))),
                      DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                    ],
                    rows: schedules.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                        DataCell(Align(alignment: Alignment.centerLeft, child: AppBadge(label: _shiftLabel(s.shiftType), status: _shiftBadge(s.shiftType)))),
                        DataCell(SizedBox(width: 110, child: Text(s.startTime))),
                        DataCell(SizedBox(width: 110, child: Text(s.endTime))),
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
