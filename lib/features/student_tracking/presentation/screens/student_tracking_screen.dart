import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
<<<<<<< HEAD
import '../../domain/entities/student_study_entity.dart';
import '../providers/student_tracking_providers.dart';
class StudentTrackingScreen extends ConsumerStatefulWidget {
  const StudentTrackingScreen({super.key});

  @override
  ConsumerState<StudentTrackingScreen> createState() => _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends ConsumerState<StudentTrackingScreen> {
  String _query = '';
  String _yearFilter = 'all';
  String _statusFilter = 'all';

  List<StudentStudyEntity> _filter(List<StudentStudyEntity> rows) {
    return rows.where((row) {
      final q = _query;
      final queryMatch = q.isEmpty ||
          row.studentName.toLowerCase().contains(q) ||
          row.nis.toLowerCase().contains(q) ||
          row.fullClassName.toLowerCase().contains(q);
      final yearMatch = _yearFilter == 'all' || row.academicYearName == _yearFilter;
      final statusMatch = _statusFilter == 'all' || row.status == _statusFilter;
      return queryMatch && yearMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final asyncStudies = ref.watch(studentStudiesProvider);
=======
import '../../data/datasources/student_tracking_dummy_data.dart';
import '../../data/models/student_tracking_entities.dart';
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Text('Tracking Siswa', style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pantau riwayat penempatan kelas dan status enrolmen siswa per tahun ajaran.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          asyncStudies.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmptyState(message: e.toString().replaceFirst('Exception: ', '')),
              ),
            ),
            data: (allRows) {
              final years = allRows.map((e) => e.academicYearName).where((e) => e.isNotEmpty).toSet().toList()..sort();
              final rows = _filter(allRows);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(isCompact, years),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTableCard(rows),
                ],
              );
            },
          ),
=======
          Text(
            'Tracking Siswa',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pantau riwayat akademik, kehadiran, dan progres siswa per semester (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFilters(isCompact, semesters, years),
          const SizedBox(height: AppSpacing.lg),
          _buildTableCard(rows),
          const SizedBox(height: AppSpacing.lg),
          _buildHistoryCard(selected),
>>>>>>> dev-vedo
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildFilters(bool isMobile, List<String> years) {
    final yearDropdown = AppDropdown<String>(
      label: 'Tahun Ajaran',
      value: _yearFilter,
      items: [
        const AppDropdownItem<String>(value: 'all', label: 'Semua Tahun'),
        ...years.map((e) => AppDropdownItem<String>(value: e, label: e)),
      ],
      onChanged: (value) => setState(() => _yearFilter = value ?? 'all'),
    );
    final statusDropdown = AppDropdown<String>(
      label: 'Status',
      value: _statusFilter,
      items: const [
        AppDropdownItem<String>(value: 'all', label: 'Semua Status'),
        AppDropdownItem<String>(value: 'active', label: 'Aktif'),
        AppDropdownItem<String>(value: 'inactive', label: 'Tidak Aktif'),
        AppDropdownItem<String>(value: 'graduated', label: 'Lulus'),
        AppDropdownItem<String>(value: 'transferred', label: 'Pindah'),
      ],
      onChanged: (value) => setState(() => _statusFilter = value ?? 'all'),
    );

    if (isMobile) {
      return Column(
        children: [
          _buildSearchField(double.infinity),
          const SizedBox(height: AppSpacing.md),
          yearDropdown,
          const SizedBox(height: AppSpacing.md),
          statusDropdown,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 320, child: _buildSearchField(320)),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 220, child: yearDropdown),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 220, child: statusDropdown),
=======
  Widget _buildFilters(bool isMobile, List<String> semesters, List<String> years) {
    if (isMobile) {
      return Column(
        children: [
          _buildSearchField(width: double.infinity),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Semester',
            value: _semesterFilter,
            items: [
              const AppDropdownItem<String>(value: 'all', label: 'Semua Semester'),
              ...semesters.map((e) => AppDropdownItem<String>(value: e, label: e)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _semesterFilter = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: 'Tahun Ajaran',
            value: _yearFilter,
            items: [
              const AppDropdownItem<String>(value: 'all', label: 'Semua Tahun'),
              ...years.map((e) => AppDropdownItem<String>(value: e, label: e)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _yearFilter = value);
            },
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 320,
          child: _buildSearchField(width: 320),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 220,
          child: AppDropdown<String>(
            label: 'Semester',
            value: _semesterFilter,
            items: [
              const AppDropdownItem<String>(value: 'all', label: 'Semua Semester'),
              ...semesters.map((e) => AppDropdownItem<String>(value: e, label: e)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _semesterFilter = value);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 220,
          child: AppDropdown<String>(
            label: 'Tahun Ajaran',
            value: _yearFilter,
            items: [
              const AppDropdownItem<String>(value: 'all', label: 'Semua Tahun'),
              ...years.map((e) => AppDropdownItem<String>(value: e, label: e)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _yearFilter = value);
            },
          ),
        ),
>>>>>>> dev-vedo
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildSearchField(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pencarian', style: AppTextStyles.label.copyWith(color: AppColors.neutral700)),
=======
  Widget _buildSearchField({required double width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pencarian',
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
>>>>>>> dev-vedo
        const SizedBox(height: AppSpacing.xs),
        AppSearchBar(
          hint: 'Cari nama/NIS/kelas...',
          width: width,
          onSearch: (value) => setState(() => _query = value.toLowerCase().trim()),
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildTableCard(List<StudentStudyEntity> rows) {
=======
  Widget _buildTableCard(List<StudentTrackingRow> rows) {
>>>>>>> dev-vedo
    return AppCard(
      child: rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: AppEmptyState(message: 'Tidak ada data siswa untuk filter saat ini.'),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
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
<<<<<<< HEAD
=======
                        dividerThickness: 1,
>>>>>>> dev-vedo
                        headingTextStyle: AppTextStyles.label.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        dataTextStyle: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w500,
                        ),
                        columns: [
<<<<<<< HEAD
                          DataColumn(label: _header('No', 56)),
                          DataColumn(label: _header('Nama Siswa', 200)),
                          DataColumn(label: _header('NIS', 110)),
                          DataColumn(label: _header('Kelas', 150)),
                          DataColumn(label: _header('Tahun Ajaran', 130)),
                          DataColumn(label: _header('Status', 130)),
                          DataColumn(label: _header('Aksi', 130)),
                        ],
                        rows: rows.asMap().entries.map((entry) {
                          final i = entry.key;
                          final row = entry.value;
                          return DataRow(cells: [
                            DataCell(_cell('${i + 1}', 56)),
                            DataCell(_cell(row.studentName, 200)),
                            DataCell(_cell(row.nis.isEmpty ? '-' : row.nis, 110)),
                            DataCell(_cell(row.fullClassName, 150)),
                            DataCell(_cell(row.academicYearName, 130)),
                            DataCell(SizedBox(width: 130, child: Align(alignment: Alignment.centerLeft, child: _statusBadge(row.status)))),
                            DataCell(SizedBox(
                              width: 130,
                              child: TextButton(
                                onPressed: () => _openHistoryDialog(row),
                                child: const Text('Lihat Riwayat'),
                              ),
                            )),
                          ]);
=======
                          DataColumn(label: _tableHeader('No', width: 64)),
                          DataColumn(label: _tableHeader('Nama Siswa', width: 220)),
                          DataColumn(label: _tableHeader('NIS', width: 120)),
                          DataColumn(label: _tableHeader('Kelas', width: 130)),
                          DataColumn(label: _tableHeader('Nilai', width: 90)),
                          DataColumn(label: _tableHeader('Kehadiran', width: 110)),
                          DataColumn(label: _tableHeader('Status', width: 130)),
                          DataColumn(label: _tableHeader('Aksi', width: 130)),
                        ],
                        rows: rows.asMap().entries.map((entry) {
                          final index = entry.key;
                          final row = entry.value;
                          final isSelected = _selectedStudentId == row.id;

                          return DataRow(
                            selected: isSelected,
                            cells: [
                              DataCell(_cellBox('${index + 1}', width: 64)),
                              DataCell(_cellBox(row.name, width: 220)),
                              DataCell(_cellBox(row.nis, width: 120)),
                              DataCell(_cellBox(row.className, width: 130)),
                              DataCell(_cellBox(row.averageScore.toStringAsFixed(1), width: 90)),
                              DataCell(
                                _cellBox('${row.attendancePercent.toStringAsFixed(1)}%', width: 110),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _statusBadge(row.status),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 130,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() => _selectedStudentId = row.id);
                                      _openHistoryDialog(row);
                                    },
                                    child: const Text('Lihat Riwayat'),
                                  ),
                                ),
                              ),
                            ],
                          );
>>>>>>> dev-vedo
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

<<<<<<< HEAD
  Future<void> _openHistoryDialog(StudentStudyEntity row) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Riwayat ${row.studentName}',
        subtitle: 'NIS: ${row.nis.isEmpty ? '-' : row.nis}',
        maxWidth: 700,
        content: Consumer(
          builder: (context, ref, _) {
            final asyncHistory = ref.watch(studentHistoryProvider(row.studentId));
            return asyncHistory.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => AppEmptyState(message: e.toString().replaceFirst('Exception: ', '')),
              data: (history) {
                if (history.isEmpty) {
                  return const AppEmptyState(message: 'Belum ada riwayat enrolmen.');
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: history.map(_historyTile).toList(),
                );
              },
            );
          },
        ),
        actions: [
          AppButton.secondary(label: 'Tutup', onPressed: () => Navigator.of(dialogContext).pop()),
=======
  Widget _buildHistoryCard(StudentTrackingRow? selected) {
    if (selected == null) {
      return const AppCard(
        child: AppEmptyState(message: 'Pilih siswa untuk melihat riwayat akademik.'),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Akademik - ${selected.name}',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${selected.className} - ${selected.academicYear}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...selected.histories.map((history) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.period,
                      style: AppTextStyles.bodyMdSemiBold.copyWith(color: AppColors.neutral900),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${history.className} - Nilai: ${history.averageScore.toStringAsFixed(1)} - Kehadiran: ${history.attendancePercent.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      history.notes,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                    ),
                  ],
                ),
              ),
            );
          }),
>>>>>>> dev-vedo
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _historyTile(StudentStudyEntity h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${h.academicYearName} · ${h.fullClassName}',
                    style: AppTextStyles.bodyMdSemiBold.copyWith(color: AppColors.neutral900),
                  ),
                ),
                _statusBadge(h.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ruang: ${h.classroomName} · Terdaftar: ${h.enrollmentDate}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
=======
  Future<void> _openHistoryDialog(StudentTrackingRow row) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Riwayat ${row.name}',
        subtitle: '${row.className} - ${row.academicYear}',
        maxWidth: 700,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...row.histories.map((history) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(color: AppColors.neutral100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.period,
                        style: AppTextStyles.bodyMdSemiBold.copyWith(color: AppColors.neutral900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${history.className} - Nilai: ${history.averageScore.toStringAsFixed(1)} - Kehadiran: ${history.attendancePercent.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        history.notes,
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          AppButton.secondary(
            label: 'Tutup',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
>>>>>>> dev-vedo
      ),
    );
  }

<<<<<<< HEAD
  Widget _statusBadge(String status) {
    return switch (status) {
      'active' => const AppBadge(label: 'AKTIF', status: BadgeStatus.success),
      'inactive' => const AppBadge(label: 'TIDAK AKTIF', status: BadgeStatus.warning),
      'graduated' => const AppBadge(label: 'LULUS', status: BadgeStatus.info),
      'transferred' => const AppBadge(label: 'PINDAH', status: BadgeStatus.warning),
      _ => AppBadge(label: status.toUpperCase(), status: BadgeStatus.info),
    };
  }

  Widget _header(String label, double width) =>
      SizedBox(width: width, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis));

  Widget _cell(String text, double width) =>
      SizedBox(width: width, child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis));
=======
  Widget _statusBadge(TrackingStatus status) {
    return switch (status) {
      TrackingStatus.onTrack => const AppBadge(label: 'ON TRACK', status: BadgeStatus.success),
      TrackingStatus.needAttention =>
        const AppBadge(label: 'PERLU PERHATIAN', status: BadgeStatus.warning),
    };
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _cellBox(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
>>>>>>> dev-vedo
}
