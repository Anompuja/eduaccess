import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/students_dummy_data.dart';
import '../../data/models/student_row_data.dart';
import '../widgets/student_create_modal.dart';
import '../widgets/student_delete_modal.dart';
import '../widgets/student_detail_modal.dart';
import '../widgets/student_edit_modal.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _levelFilter = 'Semua Level';
  String _classFilter = 'Semua Kelas';
  String _subClassFilter = 'Semua Sub-Kelas';
  int _page = 1;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 700;
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredRows = studentDummyRows.where((e) {
      return query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.nis.contains(query);
    }).toList();

    const rowsPerPage = 5;
    final totalPages = filteredRows.isEmpty
        ? 1
        : ((filteredRows.length + rowsPerPage - 1) / rowsPerPage).floor();
    final safePage = _page < 1 ? 1 : (_page > totalPages ? totalPages : _page);
    final startIndex = (safePage - 1) * rowsPerPage;
    final pagedRows = filteredRows.skip(startIndex).take(rowsPerPage).toList();

    return SingleChildScrollView(
      padding: isSmallScreen
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Siswa',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    // const SizedBox(height: AppSpacing.sm),
                    // Text(
                    //   'UI awal daftar siswa dengan filter, pencarian, dan pagination.',
                    //   style: AppTextStyles.bodyMd.copyWith(
                    //     color: AppColors.neutral500,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Cari nama / email / NIS / NISN',
                  hint: 'Contoh: dina atau 2024001',
                  controller: _searchCtrl,
                  prefixIcon: Icons.search,
                  onChanged: (_) => setState(() => _page = 1),
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Education Level',
                  _levelFilter,
                  const ['Semua Level', 'SD', 'SMP', 'SMA'],
                  (v) => setState(() {
                    _levelFilter = v;
                    _page = 1;
                  }),
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Kelas',
                  _classFilter,
                  const ['Semua Kelas', 'X', 'XI', 'XII'],
                  (v) => setState(() {
                    _classFilter = v;
                    _page = 1;
                  }),
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Sub-Kelas',
                  _subClassFilter,
                  const ['Semua Sub-Kelas', 'IPA 1', 'IPA 2', 'IPS 1'],
                  (v) => setState(() {
                    _subClassFilter = v;
                    _page = 1;
                  }),
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: 50,
                  isFullWidth: true,
                  label: 'Tambah Siswa',
                  prefixIcon: const Icon(
                    Icons.person_add_alt_1,
                    size: 18,
                    color: AppColors.white,
                  ),
                  onPressed: _openStudentCreateModal,
                ),
              ],
            )
          else
            Wrap(
              runSpacing: AppSpacing.md,
              spacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 320,
                  child: AppTextField(
                    label: 'Cari nama / email / NIS / NISN',
                    hint: 'Contoh: dina atau 2024001',
                    controller: _searchCtrl,
                    prefixIcon: Icons.search,
                    onChanged: (_) => setState(() => _page = 1),
                  ),
                ),
                _dropdown(
                  'Education Level',
                  _levelFilter,
                  const ['Semua Level', 'SD', 'SMP', 'SMA'],
                  (v) => setState(() {
                    _levelFilter = v;
                    _page = 1;
                  }),
                ),
                _dropdown(
                  'Kelas',
                  _classFilter,
                  const ['Semua Kelas', 'X', 'XI', 'XII'],
                  (v) => setState(() {
                    _classFilter = v;
                    _page = 1;
                  }),
                ),
                _dropdown(
                  'Sub-Kelas',
                  _subClassFilter,
                  const ['Semua Sub-Kelas', 'IPA 1', 'IPA 2', 'IPS 1'],
                  (v) => setState(() {
                    _subClassFilter = v;
                    _page = 1;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, left: 30.0),
                  child: AppButton.accent(
                    height: 50,
                    label: 'Tambah Siswa',
                    prefixIcon: const Icon(
                      Icons.person_add_alt_1,
                      size: 18,
                      color: AppColors.white,
                    ),
                    onPressed: _openStudentCreateModal,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: AppColors.neutral100),
                          child: DataTable(
                            columnSpacing: isSmallScreen ? 24 : 36,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen ? 50 : 56,
                            dataRowMinHeight: isSmallScreen ? 70 : 78,
                            dataRowMaxHeight: isSmallScreen ? 70 : 78,
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
                              DataColumn(label: _tableHeader('NO', width: 44)),
                              DataColumn(
                                label: _tableHeader(
                                  'NAMA',
                                  width: isSmallScreen ? 180 : 280,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'NIS',
                                  width: isSmallScreen ? 90 : 110,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'KELAS',
                                  width: isSmallScreen ? 100 : 120,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'STATUS',
                                  width: isSmallScreen ? 100 : 120,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'ACTIONS',
                                  width: isSmallScreen ? 132 : 150,
                                ),
                              ),
                            ],
                            rows: pagedRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final e = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 44,
                                      child: Text(
                                        '${startIndex + index + 1}',
                                        style: AppTextStyles.bodyMdSemiBold
                                            .copyWith(
                                              color: AppColors.neutral700,
                                            ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 180 : 280,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              Icons.person,
                                              size: 16,
                                              color: AppColors.primary700,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Text(
                                              e.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 90 : 110,
                                      child: Text(e.nis),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 100 : 120,
                                      child: Text(e.studentClass),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 100 : 120,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: e.status.toUpperCase(),
                                          status: e.status == 'Aktif'
                                              ? BadgeStatus.info
                                              : BadgeStatus.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 132 : 150,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon: Icons.visibility_outlined,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openStudentDetailModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: Icons.edit_outlined,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openStudentEditModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: Icons.delete_outline,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openStudentDeleteModal(e),
                                          ),
                                        ],
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
                const SizedBox(height: AppSpacing.lg),
                if (isSmallScreen)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Halaman $safePage dari $totalPages',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Sebelumnya',
                              onPressed: safePage > 1
                                  ? () => setState(() => _page = safePage - 1)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton.primary(
                              label: 'Berikutnya',
                              onPressed: safePage < totalPages
                                  ? () => setState(() => _page = safePage + 1)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton.secondary(
                        label: 'Sebelumnya',
                        onPressed: safePage > 1
                            ? () => setState(() => _page = safePage - 1)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Halaman $safePage dari $totalPages',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton.primary(
                        label: 'Berikutnya',
                        onPressed: safePage < totalPages
                            ? () => setState(() => _page = safePage + 1)
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : 220,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  void _openStudentDetailModal(StudentRowData row) {
    showStudentDetailModal(context, data: row);
  }

  void _openStudentDeleteModal(StudentRowData row) {
    showStudentDeleteModal(context, data: row);
  }

  void _openStudentEditModal(StudentRowData row) {
    showStudentEditModal(context, data: row);
  }

  void _openStudentCreateModal() {
    showStudentCreateModal(context);
  }
}
