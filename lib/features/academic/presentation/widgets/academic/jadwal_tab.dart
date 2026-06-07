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
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/widgets/app_refresh_button.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/features/academic/domain/entities/schedule_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

const _dayOptions = [
  AppDropdownItem(value: 'monday', label: 'Senin'),
  AppDropdownItem(value: 'tuesday', label: 'Selasa'),
  AppDropdownItem(value: 'wednesday', label: 'Rabu'),
  AppDropdownItem(value: 'thursday', label: 'Kamis'),
  AppDropdownItem(value: 'friday', label: 'Jumat'),
  AppDropdownItem(value: 'saturday', label: 'Sabtu'),
];

const _dayFilterOptions = [
  ('all', 'Semua'),
  ('monday', 'Senin'),
  ('tuesday', 'Selasa'),
  ('wednesday', 'Rabu'),
  ('thursday', 'Kamis'),
  ('friday', 'Jumat'),
  ('saturday', 'Sabtu'),
];

class JadwalTab extends ConsumerStatefulWidget {
  const JadwalTab({super.key});

  @override
  ConsumerState<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends ConsumerState<JadwalTab> {
  bool _isSubmitting = false;
  String _selectedDay = 'all';

  String _dayLabel(String day) => switch (day) {
    'monday' => 'Senin',
    'tuesday' => 'Selasa',
    'wednesday' => 'Rabu',
    'thursday' => 'Kamis',
    'friday' => 'Jumat',
    'saturday' => 'Sabtu',
    'sunday' => 'Minggu',
    _ => day,
  };

  TimeOfDay? _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<TimeOfDay?> _pickTime(BuildContext context, {TimeOfDay? initial}) =>
      showTimePicker(context: context, initialTime: initial ?? TimeOfDay.now());

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final allSchools = needsSchoolPicker
        ? (ref.read(dashboardSchoolsProvider).valueOrNull ?? [])
        : <DashboardSchool>[];

    String? dialogSchoolId = activeSchool?.id;
    String selectedDay = _selectedDay == 'all' ? 'monday' : _selectedDay;
    final periodCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool isBreak = false;
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Jam Pelajaran',
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                label: 'Hari',
                value: selectedDay,
                items: _dayOptions,
                onChanged: (v) { if (v != null) setD(() => selectedDay = v); },
              ),
              const SizedBox(height: AppSpacing.md),
              _textField(ctrl: periodCtrl, label: 'Nomor Jam', hint: 'contoh: 1', keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.md),
              _textField(ctrl: labelCtrl, label: 'Label', hint: 'contoh: Jam 1 atau Istirahat'),
              const SizedBox(height: AppSpacing.md),
              _timePicker(ctx: ctx, label: 'Jam Mulai', value: startTime, onTap: () async {
                final t = await _pickTime(ctx, initial: startTime);
                if (t != null) setD(() => startTime = t);
              }),
              const SizedBox(height: AppSpacing.md),
              _timePicker(ctx: ctx, label: 'Jam Selesai', value: endTime, onTap: () async {
                final t = await _pickTime(ctx, initial: endTime ?? startTime);
                if (t != null) setD(() => endTime = t);
              }),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Switch(
                  value: isBreak,
                  onChanged: (v) => setD(() => isBreak = v),
                  activeThumbColor: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Jam Istirahat', style: AppTextStyles.bodyMd),
              ]),
            ]),
          ),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              if (startTime == null || endTime == null) return;
              if (periodCtrl.text.trim().isEmpty || labelCtrl.text.trim().isEmpty) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              saved = true;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );

    if (!saved || !mounted) {
      periodCtrl.dispose();
      labelCtrl.dispose();
      return;
    }
    final period = int.tryParse(periodCtrl.text.trim());
    if (period == null) {
      periodCtrl.dispose();
      labelCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    periodCtrl.dispose();
    labelCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createSchedule(
        dayOfWeek: selectedDay,
        periodNumber: period,
        label: labelCtrl.text.trim(),
        startTime: _formatTime(startTime!),
        endTime: _formatTime(endTime!),
        isBreak: isBreak,
        schoolId: isSuperadmin ? dialogSchoolId : null,
      );
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(ScheduleEntity s) async {
    String selectedDay = s.dayOfWeek;
    final periodCtrl = TextEditingController(text: '${s.periodNumber}');
    final labelCtrl = TextEditingController(text: s.label);
    TimeOfDay? startTime = _parseTime(s.startTime);
    TimeOfDay? endTime = _parseTime(s.endTime);
    bool isBreak = s.isBreak;
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Jam Pelajaran',
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AppDropdown<String>(
                label: 'Hari',
                value: selectedDay,
                items: _dayOptions,
                onChanged: (v) { if (v != null) setD(() => selectedDay = v); },
              ),
              const SizedBox(height: AppSpacing.md),
              _textField(ctrl: periodCtrl, label: 'Nomor Jam', hint: 'contoh: 1', keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.md),
              _textField(ctrl: labelCtrl, label: 'Label', hint: 'contoh: Jam 1 atau Istirahat'),
              const SizedBox(height: AppSpacing.md),
              _timePicker(ctx: ctx, label: 'Jam Mulai', value: startTime, onTap: () async {
                final t = await _pickTime(ctx, initial: startTime);
                if (t != null) setD(() => startTime = t);
              }),
              const SizedBox(height: AppSpacing.md),
              _timePicker(ctx: ctx, label: 'Jam Selesai', value: endTime, onTap: () async {
                final t = await _pickTime(ctx, initial: endTime ?? startTime);
                if (t != null) setD(() => endTime = t);
              }),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Switch(
                  value: isBreak,
                  onChanged: (v) => setD(() => isBreak = v),
                  activeThumbColor: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Jam Istirahat', style: AppTextStyles.bodyMd),
              ]),
            ]),
          ),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              if (startTime == null || endTime == null) return;
              if (periodCtrl.text.trim().isEmpty || labelCtrl.text.trim().isEmpty) return;
              saved = true;
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );

    if (!saved || !mounted) {
      periodCtrl.dispose();
      labelCtrl.dispose();
      return;
    }
    final period = int.tryParse(periodCtrl.text.trim());
    if (period == null) {
      periodCtrl.dispose();
      labelCtrl.dispose();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    periodCtrl.dispose();
    labelCtrl.dispose();
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateSchedule(
        s.id,
        dayOfWeek: selectedDay,
        periodNumber: period,
        label: labelCtrl.text.trim(),
        startTime: _formatTime(startTime!),
        endTime: _formatTime(endTime!),
        isBreak: isBreak,
      );
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(ScheduleEntity s) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Jam Pelajaran',
      message: 'Jam "${s.label} (${s.startTime}–${s.endTime})" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteSchedule(s.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(schedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  Widget _textField({required TextEditingController ctrl, required String label, String? hint, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _timePicker({required BuildContext ctx, required String label, required TimeOfDay? value, required VoidCallback onTap}) {
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
              value != null ? value.format(ctx) : 'Pilih jam',
              style: AppTextStyles.bodyMd.copyWith(color: value != null ? AppColors.neutral900 : AppColors.neutral300),
            ),
          ])),
          const Icon(Icons.access_time_outlined, size: 18, color: AppColors.neutral500),
        ]),
      ),
    );
  }

  bool get _canWrite {
    final role = ref.read(currentUserProvider)?.role;
    return role == UserRole.superadmin ||
        role == UserRole.adminSekolah ||
        role == UserRole.kepalaSekolah;
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(schedulesProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final canWrite = _canWrite;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _dayFilterOptions.map((opt) {
                final isSelected = _selectedDay == opt.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(opt.$2),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedDay = opt.$1),
                    selectedColor: AppColors.primary700,
                    labelStyle: AppTextStyles.label.copyWith(
                      color: isSelected ? AppColors.white : AppColors.neutral700,
                    ),
                  ),
                );
              }).toList()),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppRefreshButton(
            onRefresh: () async {
              await ref.read(cacheStoreProvider).clean();
              ref.invalidate(schedulesProvider);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          if (canWrite)
            AppButton.accent(
              label: 'Tambah',
              prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              onPressed: _isSubmitting ? null : _create,
            ),
        ]),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (all) {
            final schedules = _selectedDay == 'all'
                ? all
                : all.where((s) => s.dayOfWeek == _selectedDay).toList();
            if (schedules.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text('Belum ada jam pelajaran.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
                ),
              );
            }
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                    child: DataTable(
                      columnSpacing: isCompact ? 12 : 20,
                      horizontalMargin: AppSpacing.md,
                      headingRowHeight: isCompact ? 42 : 48,
                      dataRowMinHeight: isCompact ? 50 : 54,
                      dataRowMaxHeight: isCompact ? 50 : 54,
                      headingTextStyle: AppTextStyles.label.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w700),
                      dataTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500),
                      columns: [
                        const DataColumn(label: SizedBox(width: 40, child: Text('No'))),
                        if (_selectedDay == 'all')
                          const DataColumn(label: SizedBox(width: 80, child: Text('Hari'))),
                        const DataColumn(label: SizedBox(width: 50, child: Text('Jam'))),
                        const DataColumn(label: SizedBox(width: 140, child: Text('Label'))),
                        const DataColumn(label: SizedBox(width: 90, child: Text('Mulai'))),
                        const DataColumn(label: SizedBox(width: 90, child: Text('Selesai'))),
                        const DataColumn(label: SizedBox(width: 100, child: Text('Jenis'))),
                        const DataColumn(label: SizedBox(width: 90, child: Text('Aksi'))),
                      ],
                      rows: schedules.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return DataRow(cells: [
                          DataCell(SizedBox(width: 40, child: Text('${i + 1}'))),
                          if (_selectedDay == 'all')
                            DataCell(SizedBox(width: 80, child: Text(_dayLabel(s.dayOfWeek)))),
                          DataCell(SizedBox(width: 50, child: Text('${s.periodNumber}'))),
                          DataCell(SizedBox(width: 140, child: Text(s.label))),
                          DataCell(SizedBox(width: 90, child: Text(s.startTime))),
                          DataCell(SizedBox(width: 90, child: Text(s.endTime))),
                          DataCell(SizedBox(width: 100, child: AppBadge(
                            label: s.isBreak ? 'Istirahat' : 'Pelajaran',
                            status: s.isBreak ? BadgeStatus.warning : BadgeStatus.info,
                          ))),
                          DataCell(SizedBox(width: 90, child: canWrite
                            ? Row(children: [
                                _actionBtn(Icons.edit_outlined, AppColors.warning, () => _edit(s)),
                                const SizedBox(width: AppSpacing.sm),
                                _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(s)),
                              ])
                            : const SizedBox.shrink())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              )),
            );
          },
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
