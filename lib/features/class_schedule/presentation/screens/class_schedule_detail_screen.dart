import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduaccess/core/router/route_names.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/widgets/app_badge.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import 'package:eduaccess/core/widgets/app_dialog.dart';
import 'package:eduaccess/core/widgets/app_dropdown.dart';
import 'package:eduaccess/features/class_schedule/domain/entities/attendance_entity.dart';
import 'package:eduaccess/features/class_schedule/domain/entities/class_schedule_entity.dart';
import 'package:eduaccess/features/class_schedule/presentation/providers/class_schedule_providers.dart';

const _attendanceOptions = [
  AppDropdownItem(value: 'present', label: 'Hadir'),
  AppDropdownItem(value: 'sick', label: 'Sakit'),
  AppDropdownItem(value: 'permission', label: 'Izin'),
  AppDropdownItem(value: 'absent', label: 'Alpha'),
];

class ClassScheduleDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const ClassScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<ClassScheduleDetailScreen> createState() => _ClassScheduleDetailScreenState();
}

class _ClassScheduleDetailScreenState extends ConsumerState<ClassScheduleDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _editAttendance(AttendanceEntity att) async {
    var selectedStatus = att.status == 'scheduled' ? 'present' : att.status;
    final noteCtrl = TextEditingController(text: att.note);
    bool saved = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Kehadiran',
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppDropdown<String>(
              label: 'Status',
              value: selectedStatus,
              items: _attendanceOptions,
              onChanged: (v) { if (v != null) setD(() => selectedStatus = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ]),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
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
      await ref.read(classScheduleRepositoryProvider).updateAttendance(
        widget.scheduleId,
        att.studentId,
        status: selectedStatus,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      ref.invalidate(attendancesProvider(widget.scheduleId));
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
    final scheduleAsync = ref.watch(classScheduleDetailProvider(widget.scheduleId));
    final attendancesAsync = ref.watch(attendancesProvider(widget.scheduleId));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Detail Jadwal', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.neutral900,
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
        data: (cs) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _scheduleInfo(cs),
            const SizedBox(height: AppSpacing.lg),
            Text('Daftar Kehadiran', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
            const SizedBox(height: AppSpacing.md),
            attendancesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
              data: (attendances) => attendances.isEmpty
                  ? AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text('Belum ada data kehadiran.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
                      ),
                    )
                  : _attendanceTable(cs, attendances),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _scheduleInfo(ClassScheduleEntity cs) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Informasi Jadwal', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          _statusBadge(cs.status),
        ]),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        _infoRow('Tanggal', cs.date),
        _infoRow('Waktu', '${cs.startTime} – ${cs.endTime}'),
        if (cs.status == 'ongoing') ...[
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          AppButton.accent(
            label: 'Tampilkan QR Absensi',
            prefixIcon: const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.white),
            isFullWidth: true,
            onPressed: () => context.push(RouteNames.attendanceDisplay(widget.scheduleId)),
          ),
        ],
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _attendanceTable(ClassScheduleEntity cs, List<AttendanceEntity> attendances) {
    final canEdit = cs.status == 'ongoing';
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: AppSpacing.md,
              headingRowHeight: 48,
              dataRowMinHeight: 54,
              dataRowMaxHeight: 54,
              headingTextStyle: AppTextStyles.label.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w700),
              dataTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500),
              columns: [
                const DataColumn(label: SizedBox(width: 40, child: Text('No'))),
                const DataColumn(label: SizedBox(width: 200, child: Text('ID Siswa'))),
                const DataColumn(label: SizedBox(width: 110, child: Text('Status'))),
                const DataColumn(label: SizedBox(width: 140, child: Text('Catatan'))),
                if (canEdit) const DataColumn(label: SizedBox(width: 70, child: Text('Aksi'))),
              ],
              rows: attendances.asMap().entries.map((entry) {
                final i = entry.key;
                final att = entry.value;
                return DataRow(cells: [
                  DataCell(SizedBox(width: 40, child: Text('${i + 1}'))),
                  DataCell(SizedBox(width: 200, child: Text(att.studentId, overflow: TextOverflow.ellipsis))),
                  DataCell(SizedBox(width: 110, child: _attendanceBadge(att.status))),
                  DataCell(SizedBox(width: 140, child: Text(att.note.isEmpty ? '-' : att.note, overflow: TextOverflow.ellipsis))),
                  if (canEdit)
                    DataCell(SizedBox(width: 70, child: _actionBtn(Icons.edit_outlined, AppColors.warning, () => _editAttendance(att)))),
                ]);
              }).toList(),
            ),
          ),
        ),
      )),
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

  Widget _attendanceBadge(String status) => AppBadge(
    label: switch (status) {
      'present' => 'Hadir',
      'late' => 'Terlambat',
      'sick' => 'Sakit',
      'permission' => 'Izin',
      'absent' => 'Alpha',
      'scheduled' => 'Belum',
      _ => status,
    },
    status: switch (status) {
      'present' => BadgeStatus.success,
      'late' => BadgeStatus.warning,
      'sick' => BadgeStatus.warning,
      'permission' => BadgeStatus.info,
      'absent' => BadgeStatus.error,
      _ => BadgeStatus.info,
    },
  );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 34, height: 34,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: _isSubmitting ? null : onTap,
        child: Icon(icon, color: AppColors.white, size: 18),
      ),
    ),
  );
}
