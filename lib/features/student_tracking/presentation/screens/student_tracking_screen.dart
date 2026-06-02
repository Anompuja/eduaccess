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
import '../../domain/entities/student_study_entity.dart';
import '../providers/student_tracking_providers.dart';

class StudentTrackingScreen extends ConsumerStatefulWidget {
  const StudentTrackingScreen({super.key});

  @override
  ConsumerState<StudentTrackingScreen> createState() =>
      _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends ConsumerState<StudentTrackingScreen> {
  String _query = '';
  String _yearFilter = 'all';
  String _statusFilter = 'all';

  List<StudentStudyEntity> _filter(List<StudentStudyEntity> rows) {
    return rows.where((row) {
      final query = _query;
      final queryMatch =
          query.isEmpty ||
          row.studentName.toLowerCase().contains(query) ||
          row.nis.toLowerCase().contains(query) ||
          row.fullClassName.toLowerCase().contains(query) ||
          row.academicYearName.toLowerCase().contains(query);
      final yearMatch =
          _yearFilter == 'all' || row.academicYearName == _yearFilter;
      final statusMatch = _statusFilter == 'all' || row.status == _statusFilter;
      return queryMatch && yearMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final asyncStudies = ref.watch(studentStudiesProvider);

    return SingleChildScrollView(
      padding: isCompact
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Siswa',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
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
            error: (error, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmptyState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            ),
            data: (allRows) {
              final years =
                  allRows
                      .map((row) => row.academicYearName)
                      .where((year) => year.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
              final filteredRows = _filter(allRows);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(isCompact, years),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTableCard(filteredRows),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile, List<String> years) {
    final yearDropdown = AppDropdown<String>(
      label: 'Tahun Ajaran',
      value: _yearFilter,
      items: [
        const AppDropdownItem<String>(value: 'all', label: 'Semua Tahun'),
        ...years.map(
          (year) => AppDropdownItem<String>(value: year, label: year),
        ),
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
          _buildSearchField(width: double.infinity),
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
        SizedBox(width: 320, child: _buildSearchField(width: 320)),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 220, child: yearDropdown),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 220, child: statusDropdown),
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
          onSearch: (value) =>
              setState(() => _query = value.toLowerCase().trim()),
        ),
      ],
    );
  }

  Widget _buildTableCard(List<StudentStudyEntity> rows) {
    return AppCard(
      child: rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: AppEmptyState(
                message: 'Tidak ada data siswa untuk filter saat ini.',
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    Responsive.isMobile(context) ||
                    Responsive.isTablet(context);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: AppColors.neutral100),
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
                          DataColumn(label: _header('No', 56)),
                          DataColumn(label: _header('Nama Siswa', 200)),
                          DataColumn(label: _header('NIS', 110)),
                          DataColumn(label: _header('Kelas', 150)),
                          DataColumn(label: _header('Tahun Ajaran', 130)),
                          DataColumn(label: _header('Status', 130)),
                          DataColumn(label: _header('Aksi', 130)),
                        ],
                        rows: rows.asMap().entries.map((entry) {
                          final index = entry.key;
                          final row = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(_cell('${index + 1}', 56)),
                              DataCell(_cell(row.studentName, 200)),
                              DataCell(
                                _cell(row.nis.isEmpty ? '-' : row.nis, 110),
                              ),
                              DataCell(_cell(row.fullClassName, 150)),
                              DataCell(_cell(row.academicYearName, 130)),
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
                                    onPressed: () => _openHistoryDialog(row),
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

  Future<void> _openHistoryDialog(StudentStudyEntity row) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Riwayat ${row.studentName}',
        subtitle: 'NIS: ${row.nis.isEmpty ? '-' : row.nis}',
        maxWidth: 700,
        content: Consumer(
          builder: (context, ref, _) {
            final asyncHistory = ref.watch(
              studentHistoryProvider(row.studentId),
            );
            return asyncHistory.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => AppEmptyState(
                message: error.toString().replaceFirst('Exception: ', ''),
              ),
              data: (history) {
                if (history.isEmpty) {
                  return const AppEmptyState(
                    message: 'Belum ada riwayat enrolmen.',
                  );
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
          AppButton.secondary(
            label: 'Tutup',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(StudentStudyEntity history) {
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
                    '${history.academicYearName} · ${history.fullClassName}',
                    style: AppTextStyles.bodyMdSemiBold.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                _statusBadge(history.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ruang: ${history.classroomName} · Terdaftar: ${history.enrollmentDate}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'active' => const AppBadge(label: 'AKTIF', status: BadgeStatus.success),
      'inactive' => const AppBadge(
        label: 'TIDAK AKTIF',
        status: BadgeStatus.warning,
      ),
      'graduated' => const AppBadge(label: 'LULUS', status: BadgeStatus.info),
      'transferred' => const AppBadge(
        label: 'PINDAH',
        status: BadgeStatus.warning,
      ),
      _ => AppBadge(label: status.toUpperCase(), status: BadgeStatus.info),
    };
  }

  Widget _header(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _cell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
