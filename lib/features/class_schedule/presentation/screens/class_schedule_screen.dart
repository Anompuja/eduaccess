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
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/core/router/route_names.dart';
import 'package:eduaccess/features/academic/domain/entities/classroom_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/schedule_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/subject_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/class_schedule/domain/entities/class_schedule_entity.dart';
import 'package:eduaccess/features/class_schedule/presentation/providers/class_schedule_providers.dart';
import 'package:eduaccess/features/teachers/data/models/teacher_row_data.dart';

const _statusOptions = [
  AppDropdownItem(value: 'scheduled', label: 'Terjadwal'),
  AppDropdownItem(value: 'ongoing', label: 'Berlangsung'),
  AppDropdownItem(value: 'completed', label: 'Selesai'),
  AppDropdownItem(value: 'cancelled', label: 'Dibatalkan'),
];

// ── Form result ───────────────────────────────────────────────────────────────

class _FormResult {
  final String classroomId;
  final String subjectId;
  final String teacherId;    // auth.users UUID
  final String date;         // YYYY-MM-DD
  final String startTime;    // HH:MM
  final String endTime;      // HH:MM
  final String? startPeriodId;
  final String? endPeriodId;

  const _FormResult({
    required this.classroomId,
    required this.subjectId,
    required this.teacherId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.startPeriodId,
    this.endPeriodId,
  });
}

// ── Dialog form body ─────────────────────────────────────────────────────────

class _ScheduleFormBody extends ConsumerStatefulWidget {
  const _ScheduleFormBody({super.key});

  @override
  ConsumerState<_ScheduleFormBody> createState() => _ScheduleFormBodyState();
}

class _ScheduleFormBodyState extends ConsumerState<_ScheduleFormBody> {
  String? _classroomId;
  String? _subjectId;
  String? _teacherUserId;
  DateTime? _date;
  ScheduleEntity? _startPeriod;
  ScheduleEntity? _endPeriod;
  String? _validationError;

  String _dayOfWeek(DateTime d) => switch (d.weekday) {
    DateTime.monday => 'monday',
    DateTime.tuesday => 'tuesday',
    DateTime.wednesday => 'wednesday',
    DateTime.thursday => 'thursday',
    DateTime.friday => 'friday',
    DateTime.saturday => 'saturday',
    DateTime.sunday => 'sunday',
    _ => '',
  };

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<ScheduleEntity> _slotsForDay(List<ScheduleEntity> all) {
    if (_date == null) return all.where((s) => !s.isBreak).toList();
    final day = _dayOfWeek(_date!);
    return all.where((s) => s.dayOfWeek == day && !s.isBreak).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  void submit() {
    String? err;
    if (_classroomId == null) {
      err = 'Pilih ruang kelas terlebih dahulu.';
    } else if (_subjectId == null) {
      err = 'Pilih mata pelajaran terlebih dahulu.';
    } else if (_teacherUserId == null) {
      err = 'Pilih guru terlebih dahulu.';
    } else if (_date == null) {
      err = 'Pilih tanggal terlebih dahulu.';
    } else if (_startPeriod == null) {
      err = 'Pilih periode mulai. Pastikan hari yang dipilih memiliki jam pelajaran.';
    }

    if (err != null) {
      setState(() => _validationError = err);
      return;
    }

    final endPeriod = _endPeriod ?? _startPeriod!;
    Navigator.of(context).pop(_FormResult(
      classroomId: _classroomId!,
      subjectId: _subjectId!,
      teacherId: _teacherUserId!,
      date: _formatDate(_date!),
      startTime: _startPeriod!.startTime,
      endTime: endPeriod.endTime,
      startPeriodId: _startPeriod!.id,
      endPeriodId: endPeriod.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final classrooms = ref.watch(classroomsProvider).valueOrNull ?? <ClassroomEntity>[];
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? <SubjectEntity>[];
    final teachers = ref.watch(teachersForDropdownProvider).valueOrNull ?? <TeacherRowData>[];
    final allSlots = ref.watch(schedulesProvider).valueOrNull ?? <ScheduleEntity>[];
    final slots = _slotsForDay(allSlots);

    // Guard: if date changes and selected period no longer in day's slots, clear it
    if (_startPeriod != null && slots.every((s) => s.id != _startPeriod!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _startPeriod = null; _endPeriod = null; });
      });
    }
    if (_endPeriod != null && slots.every((s) => s.id != _endPeriod!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _endPeriod = null);
      });
    }

    final endSlots = _startPeriod == null
        ? slots
        : slots.where((s) => s.periodNumber >= _startPeriod!.periodNumber).toList();

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Validation error banner
      if (_validationError != null) ...[
        _infoBox(_validationError!, color: AppColors.error),
        const SizedBox(height: AppSpacing.md),
      ],
      // Classroom
      AppDropdown<String?>(
        label: 'Ruang Kelas',
        hint: classrooms.isEmpty ? 'Belum ada ruang kelas' : 'Pilih ruang kelas',
        value: classrooms.any((c) => c.id == _classroomId) ? _classroomId : null,
        items: classrooms.map((c) => AppDropdownItem<String?>(value: c.id, label: c.name)).toList(),
        onChanged: (v) => setState(() { _classroomId = v; _validationError = null; }),
      ),
      const SizedBox(height: AppSpacing.md),

      // Subject
      AppDropdown<String?>(
        label: 'Mata Pelajaran',
        hint: subjects.isEmpty ? 'Belum ada mata pelajaran' : 'Pilih mata pelajaran',
        value: subjects.any((s) => s.id == _subjectId) ? _subjectId : null,
        items: subjects.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
        onChanged: (v) => setState(() { _subjectId = v; _validationError = null; }),
      ),
      const SizedBox(height: AppSpacing.md),

      // Teacher — value = userId (auth.users UUID), label = name
      AppDropdown<String?>(
        label: 'Guru',
        hint: teachers.isEmpty ? 'Belum ada data guru' : 'Pilih guru',
        value: teachers.any((t) => t.userId == _teacherUserId) ? _teacherUserId : null,
        items: teachers.map((t) => AppDropdownItem<String?>(value: t.userId, label: t.name)).toList(),
        onChanged: (v) => setState(() { _teacherUserId = v; _validationError = null; }),
      ),
      const SizedBox(height: AppSpacing.md),

      // Date picker
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            setState(() {
              _date = picked;
              _startPeriod = null;
              _endPeriod = null;
              _validationError = null;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral300),
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tanggal',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                const SizedBox(height: 2),
                Text(
                  _date != null ? _formatDate(_date!) : 'Pilih tanggal',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: _date != null ? AppColors.neutral900 : AppColors.neutral300),
                ),
              ],
            )),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.neutral500),
          ]),
        ),
      ),
      const SizedBox(height: AppSpacing.md),

      // Period slots — connected to school_schedule_slots table
      if (allSlots.isEmpty) ...[
        _infoBox('Belum ada jam pelajaran. Tambah dulu di tab Jadwal.',
            color: AppColors.warning),
      ] else if (_date != null && slots.isEmpty) ...[
        _infoBox(
          'Tidak ada jam pelajaran untuk hari ${_dayLabel(_dayOfWeek(_date!))}. '
          'Jadwal kelas hanya bisa dibuat pada hari yang memiliki slot jam.',
          color: AppColors.warning,
        ),
      ] else ...[
        // Periode Mulai
        AppDropdown<String?>(
          label: 'Periode Mulai',
          hint: _date == null ? 'Pilih tanggal terlebih dahulu' : 'Pilih periode mulai',
          value: slots.any((s) => s.id == _startPeriod?.id) ? _startPeriod?.id : null,
          items: [
            const AppDropdownItem<String?>(value: null, label: 'Pilih'),
            ...slots.map((s) => AppDropdownItem<String?>(
              value: s.id,
              label: '${s.label}  •  ${s.startTime}–${s.endTime}',
            )),
          ],
          onChanged: _date == null ? null : (v) {
            setState(() {
              _startPeriod = v == null ? null : slots.firstWhere((s) => s.id == v);
              if (_endPeriod != null && _startPeriod != null &&
                  _endPeriod!.periodNumber < _startPeriod!.periodNumber) {
                _endPeriod = null;
              }
              _validationError = null;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Periode Selesai — untuk kelas yang mencakup lebih dari 1 jam pelajaran
        AppDropdown<String?>(
          label: 'Periode Selesai (opsional — untuk kelas lintas jam)',
          hint: _startPeriod == null ? 'Sama dengan periode mulai' : 'Pilih jika lebih dari 1 jam',
          value: endSlots.any((s) => s.id == _endPeriod?.id) ? _endPeriod?.id : null,
          items: [
            const AppDropdownItem<String?>(value: null, label: 'Sama dengan mulai'),
            ...endSlots.map((s) => AppDropdownItem<String?>(
              value: s.id,
              label: '${s.label}  •  ${s.startTime}–${s.endTime}',
            )),
          ],
          onChanged: _startPeriod == null
              ? null
              : (v) => setState(() =>
                  _endPeriod = v == null ? null : endSlots.firstWhere((s) => s.id == v)),
        ),

        // Time preview chip
        if (_startPeriod != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary700),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_startPeriod!.startTime} – ${(_endPeriod ?? _startPeriod!).endTime}',
                style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.primary700, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ],
      ],
    ]);
  }

  Widget _infoBox(String msg, {required Color color}) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppRadius.mdAll,
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline, size: 16, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(msg,
          style: AppTextStyles.bodySm.copyWith(color: color))),
    ]),
  );

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
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class ClassScheduleScreen extends ConsumerStatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  ConsumerState<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends ConsumerState<ClassScheduleScreen> {
  bool _isSubmitting = false;
  ClassScheduleFilter _filter = const ClassScheduleFilter();
  String? _selectedStatus;

  void _applyFilter() {
    setState(() {
      _filter = ClassScheduleFilter(status: _selectedStatus);
    });
  }

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;

    final formKey = GlobalKey<_ScheduleFormBodyState>();
    final result = await showDialog<_FormResult>(
      context: context,
      builder: (dialogCtx) => AppDialog(
        title: 'Tambah Jadwal Kelas',
        content: _ScheduleFormBody(key: formKey),
        actions: [
          AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(dialogCtx).pop()),
          AppButton.primary(label: 'Simpan', onPressed: () => formKey.currentState?.submit()),
        ],
      ),
    );

    if (result == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(classScheduleRepositoryProvider).createClassSchedule(
        classroomId: result.classroomId,
        subjectId: result.subjectId,
        teacherId: result.teacherId,
        date: result.date,
        startTime: result.startTime,
        endTime: result.endTime,
        startPeriodId: result.startPeriodId,
        endPeriodId: result.endPeriodId,
        schoolId: isSuperadmin ? activeSchool?.id : null,
      );
      await ref.read(cacheStoreProvider).clean();
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
        case 'start': await repo.startClassSchedule(cs.id);
        case 'complete': await repo.completeClassSchedule(cs.id);
        case 'cancel': await repo.cancelClassSchedule(cs.id);
      }
      await ref.read(cacheStoreProvider).clean();
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
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classSchedulesProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(classSchedulesProvider(_filter));
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final user = ref.watch(currentUserProvider);
    final canWrite = user?.role == UserRole.superadmin ||
        user?.role == UserRole.adminSekolah ||
        user?.role == UserRole.kepalaSekolah;
    final canControlSession = canWrite || user?.role == UserRole.guru;

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
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(children: [
              Expanded(
                child: AppDropdown<String?>(
                  label: 'Status',
                  hint: 'Semua status',
                  value: _selectedStatus,
                  items: _statusOptions
                      .map((o) => AppDropdownItem<String?>(value: o.value, label: o.label))
                      .toList(),
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
            loading: () => const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Center(
              child: Text(e.toString(),
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
            data: (schedules) {
              if (schedules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(children: [
                      Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.neutral300),
                      const SizedBox(height: AppSpacing.md),
                      Text('Belum ada jadwal kelas.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
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
                        headingTextStyle: AppTextStyles.label.copyWith(
                          color: AppColors.neutral700, fontWeight: FontWeight.w700),
                        dataTextStyle: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral900, fontWeight: FontWeight.w500),
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
                            DataCell(SizedBox(width: 120,
                              child: Text('${cs.startTime}–${cs.endTime}'))),
                            DataCell(SizedBox(width: 100, child: _statusBadge(cs.status))),
                            DataCell(SizedBox(width: 150,
                              child: _rowActions(cs, canWrite: canWrite, canControlSession: canControlSession))),
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

  Widget _rowActions(ClassScheduleEntity cs, {required bool canWrite, required bool canControlSession}) {
    return Row(children: [
      _actionBtn(Icons.visibility_outlined, AppColors.primary700,
        () => context.push(RouteNames.classScheduleDetail(cs.id))),
      const SizedBox(width: 4),
      if (cs.status == 'scheduled') ...[
        if (canControlSession) ...[
          _actionBtn(Icons.play_arrow_rounded, AppColors.success, () => _updateStatus(cs, 'start')),
          const SizedBox(width: 4),
        ],
        if (canWrite)
          _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(cs)),
      ],
      if (cs.status == 'ongoing') ...[
        if (canControlSession) ...[
          _actionBtn(Icons.check_circle_outline_rounded, AppColors.success,
            () => _updateStatus(cs, 'complete')),
          const SizedBox(width: 4),
          _actionBtn(Icons.cancel_outlined, AppColors.warning, () => _updateStatus(cs, 'cancel')),
        ],
      ],
    ]);
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 32, height: 32,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Icon(icon, color: AppColors.white, size: 16),
      ),
    ),
  );
}
