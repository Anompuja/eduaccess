import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:eduaccess/core/router/route_names.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/class_schedule/domain/entities/class_schedule_entity.dart';
import 'package:eduaccess/features/class_schedule/presentation/providers/class_schedule_providers.dart';

const _statusOptions = [
  AppDropdownItem(value: 'scheduled', label: 'Terjadwal'),
  AppDropdownItem(value: 'ongoing', label: 'Berlangsung'),
  AppDropdownItem(value: 'completed', label: 'Selesai'),
  AppDropdownItem(value: 'cancelled', label: 'Dibatalkan'),
];

class ClassScheduleScreen extends ConsumerStatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  ConsumerState<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends ConsumerState<ClassScheduleScreen> {
  bool _isSubmitting = false;
  ClassScheduleFilter _filter = const ClassScheduleFilter();
  String? _selectedStatus;
  String? _selectedDate;

  void _applyFilter() {
    setState(() {
      _filter = ClassScheduleFilter(
        status: _selectedStatus,
        date: _selectedDate,
      );
    });
  }

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;

    final classrooms = ref.read(classroomsProvider).valueOrNull ?? [];
    final subjects = ref.read(subjectsProvider).valueOrNull ?? [];

    if (classrooms.isEmpty || subjects.isEmpty) {
      _showError('Pastikan data kelas dan mata pelajaran sudah tersedia.');
      return;
    }

    String? selectedClassroom = classrooms.isNotEmpty ? classrooms.first.id : null;
    String? selectedSubject = subjects.isNotEmpty ? subjects.first.id : null;
    final teacherCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final startTimeCtrl = TextEditingController();
    final endTimeCtrl = TextEditingController();
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Jadwal Kelas',
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AppDropdown<String?>(
                label: 'Kelas',
                hint: 'Pilih kelas',
                value: selectedClassroom,
                items: classrooms.map((c) => AppDropdownItem<String?>(value: c.id, label: c.name)).toList(),
                onChanged: (v) => setD(() => selectedClassroom = v),
              ),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<String?>(
                label: 'Mata Pelajaran',
                hint: 'Pilih mata pelajaran',
                value: selectedSubject,
                items: subjects.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
                onChanged: (v) => setD(() => selectedSubject = v),
              ),
              const SizedBox(height: AppSpacing.md),
              _textField(ctrl: teacherCtrl, label: 'ID Guru', hint: 'UUID guru'),
              const SizedBox(height: AppSpacing.md),
              _dateField(ctx: ctx, ctrl: dateCtrl, label: 'Tanggal'),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Expanded(child: _timeField(ctx: ctx, ctrl: startTimeCtrl, label: 'Jam Mulai')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _timeField(ctx: ctx, ctrl: endTimeCtrl, label: 'Jam Selesai')),
              ]),
            ]),
          ),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              if (selectedClassroom == null || selectedSubject == null) return;
              if (teacherCtrl.text.trim().isEmpty || dateCtrl.text.trim().isEmpty) return;
              if (startTimeCtrl.text.trim().isEmpty || endTimeCtrl.text.trim().isEmpty) return;
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
      await ref.read(classScheduleRepositoryProvider).createClassSchedule(
        classroomId: selectedClassroom!,
        subjectId: selectedSubject!,
        teacherId: teacherCtrl.text.trim(),
        date: dateCtrl.text.trim(),
        startTime: startTimeCtrl.text.trim(),
        endTime: endTimeCtrl.text.trim(),
        schoolId: isSuperadmin ? activeSchool?.id : null,
      );
      ref.invalidate(classSchedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateStatus(ClassScheduleEntity cs, String action) async {
    final repo = ref.read(classScheduleRepositoryProvider);
    setState(() => _isSubmitting = true);
    try {
      switch (action) {
        case 'start':
          await repo.startClassSchedule(cs.id);
        case 'complete':
          await repo.completeClassSchedule(cs.id);
        case 'cancel':
          await repo.cancelClassSchedule(cs.id);
      }
      ref.invalidate(classSchedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(ClassScheduleEntity cs) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Jadwal',
      message: 'Jadwal tanggal ${cs.date} (${cs.startTime}–${cs.endTime}) akan dihapus.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(classScheduleRepositoryProvider).deleteClassSchedule(cs.id);
      ref.invalidate(classSchedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  Widget _textField({required TextEditingController ctrl, required String label, String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _dateField({required BuildContext ctx, required TextEditingController ctrl, required String label}) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'YYYY-MM-DD',
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  Widget _timeField({required BuildContext ctx, required TextEditingController ctrl, required String label}) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:MM',
        suffixIcon: const Icon(Icons.access_time_outlined, size: 18),
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onTap: () async {
        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
        if (t != null) {
          ctrl.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(classSchedulesProvider(_filter));
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final user = ref.watch(currentUserProvider);
    final canWrite = user?.role == UserRole.superadmin || user?.role == UserRole.adminSekolah || user?.role == UserRole.kepalaSekolah;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Jadwal Kelas', style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
            const Spacer(),
            if (canWrite)
              AppButton.accent(
                label: 'Tambah Jadwal',
                prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                onPressed: _isSubmitting ? null : _create,
              ),
          ]),
          const SizedBox(height: AppSpacing.md),
          // Filter bar
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(children: [
              Expanded(
                child: AppDropdown<String?>(
                  label: 'Status',
                  hint: 'Semua status',
                  value: _selectedStatus,
                  items: _statusOptions.map((o) => AppDropdownItem<String?>(value: o.value, label: o.label)).toList(),
                  onChanged: (v) { setState(() => _selectedStatus = v); _applyFilter(); },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (_selectedStatus != null)
                TextButton.icon(
                  onPressed: () { setState(() => _selectedStatus = null); _applyFilter(); },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Reset'),
                ),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          asyncData.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
            data: (schedules) {
              if (schedules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(children: [
                      Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.neutral300),
                      const SizedBox(height: AppSpacing.md),
                      Text('Belum ada jadwal kelas.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
                    ]),
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
                        dataRowMinHeight: isCompact ? 54 : 58,
                        dataRowMaxHeight: isCompact ? 54 : 58,
                        headingTextStyle: AppTextStyles.label.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w700),
                        dataTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500),
                        columns: const [
                          DataColumn(label: SizedBox(width: 40, child: Text('No'))),
                          DataColumn(label: SizedBox(width: 100, child: Text('Tanggal'))),
                          DataColumn(label: SizedBox(width: 120, child: Text('Waktu'))),
                          DataColumn(label: SizedBox(width: 100, child: Text('Status'))),
                          DataColumn(label: SizedBox(width: 150, child: Text('Aksi'))),
                        ],
                        rows: schedules.asMap().entries.map((entry) {
                          final i = entry.key;
                          final cs = entry.value;
                          return DataRow(cells: [
                            DataCell(SizedBox(width: 40, child: Text('${i + 1}'))),
                            DataCell(SizedBox(width: 100, child: Text(cs.date))),
                            DataCell(SizedBox(width: 120, child: Text('${cs.startTime}–${cs.endTime}'))),
                            DataCell(SizedBox(width: 100, child: _statusBadge(cs.status))),
                            DataCell(SizedBox(width: 150, child: _rowActions(cs, canWrite))),
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
      ),
    );
  }

  Widget _statusBadge(String status) => AppBadge(
    label: switch (status) {
      'scheduled' => 'Terjadwal',
      'ongoing' => 'Berlangsung',
      'completed' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      _ => status,
    },
    status: switch (status) {
      'scheduled' => BadgeStatus.info,
      'ongoing' => BadgeStatus.warning,
      'completed' => BadgeStatus.success,
      'cancelled' => BadgeStatus.error,
      _ => BadgeStatus.info,
    },
  );

  Widget _rowActions(ClassScheduleEntity cs, bool canWrite) {
    return Row(children: [
      _actionBtn(Icons.visibility_outlined, AppColors.primary700, () => context.push(RouteNames.classScheduleDetail(cs.id))),
      const SizedBox(width: 4),
      if (canWrite && cs.status == 'scheduled') ...[
        _actionBtn(Icons.play_arrow_rounded, AppColors.success, () => _updateStatus(cs, 'start')),
        const SizedBox(width: 4),
        _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(cs)),
      ],
      if (cs.status == 'ongoing') ...[
        _actionBtn(Icons.check_circle_outline_rounded, AppColors.success, () => _updateStatus(cs, 'complete')),
        const SizedBox(width: 4),
        if (canWrite)
          _actionBtn(Icons.cancel_outlined, AppColors.error, () => _updateStatus(cs, 'cancel')),
      ],
    ]);
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 32, height: 32,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(borderRadius: AppRadius.mdAll, onTap: onTap, child: Icon(icon, color: AppColors.white, size: 16)),
    ),
  );
}
