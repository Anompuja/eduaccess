import 'package:flutter/material.dart';

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
import '../../data/datasources/student_tracking_dummy_data.dart';
import '../../data/models/student_tracking_entities.dart';

class StudentTrackingScreen extends StatefulWidget {
  const StudentTrackingScreen({super.key});

  @override
  State<StudentTrackingScreen> createState() => _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends State<StudentTrackingScreen> {
  String _query = '';
  String _semesterFilter = 'all';
  String _yearFilter = 'all';
  String? _selectedStudentId;

  List<StudentTrackingRow> get _filteredRows {
    return studentTrackingDummyRows.where((row) {
      final queryMatch = _query.isEmpty ||
          row.name.toLowerCase().contains(_query) ||
          row.nis.toLowerCase().contains(_query) ||
          row.className.toLowerCase().contains(_query);
      final semesterMatch = _semesterFilter == 'all' || row.semester == _semesterFilter;
      final yearMatch = _yearFilter == 'all' || row.academicYear == _yearFilter;
      return queryMatch && semesterMatch && yearMatch;
    }).toList();
  }

  StudentTrackingRow? get _selectedRow {
    final rows = _filteredRows;
    if (rows.isEmpty) return null;

    final match = rows.where((row) => row.id == _selectedStudentId).toList();
    if (match.isNotEmpty) return match.first;
    return rows.first;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final rows = _filteredRows;
    final selected = _selectedRow;
    final semesters = studentTrackingDummyRows.map((e) => e.semester).toSet().toList()..sort();
    final years = studentTrackingDummyRows.map((e) => e.academicYear).toSet().toList()..sort();

    return SingleChildScrollView(
      padding: isCompact ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

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
      ],
    );
  }

  Widget _buildSearchField({required double width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pencarian',
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppSearchBar(
          hint: 'Cari nama/NIS/kelas...',
          width: width,
          onSearch: (value) => setState(() => _query = value.toLowerCase().trim()),
        ),
      ],
    );
  }

  Widget _buildTableCard(List<StudentTrackingRow> rows) {
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
                        dividerThickness: 1,
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
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

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
        ],
      ),
    );
  }

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
      ),
    );
  }

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
}
