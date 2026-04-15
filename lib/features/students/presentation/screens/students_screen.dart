import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/students_dummy_data.dart';
import '../../data/models/student_row_data.dart';
import '../constants/students_screen_constants.dart';
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
    final isSmallScreen = Responsive.isMobile(context);
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredRows = studentDummyRows.where((e) {
      return query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.nis.contains(query);
    }).toList();

    const rowsPerPage = StudentsScreenConstants.rowsPerPage;
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
                      StudentsScreenConstants.title,
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
                  label: StudentsScreenConstants.searchLabel,
                  hint: StudentsScreenConstants.searchHint,
                  controller: _searchCtrl,
                  prefixIcon: StudentsScreenConstants.searchIcon,
                  onChanged: (_) => setState(() => _page = 1),
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  StudentsScreenConstants.educationLevelLabel,
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
                  StudentsScreenConstants.classLabel,
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
                  StudentsScreenConstants.subClassLabel,
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
                  height: StudentsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: StudentsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    StudentsScreenConstants.addIcon,
                    size: StudentsScreenConstants.actionIconSize,
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
                  width: StudentsScreenConstants.desktopSearchWidth,
                  child: AppTextField(
                    label: StudentsScreenConstants.searchLabel,
                    hint: StudentsScreenConstants.searchHint,
                    controller: _searchCtrl,
                    prefixIcon: StudentsScreenConstants.searchIcon,
                    onChanged: (_) => setState(() => _page = 1),
                  ),
                ),
                _dropdown(
                  StudentsScreenConstants.educationLevelLabel,
                  _levelFilter,
                  const ['Semua Level', 'SD', 'SMP', 'SMA'],
                  (v) => setState(() {
                    _levelFilter = v;
                    _page = 1;
                  }),
                ),
                _dropdown(
                  StudentsScreenConstants.classLabel,
                  _classFilter,
                  const ['Semua Kelas', 'X', 'XI', 'XII'],
                  (v) => setState(() {
                    _classFilter = v;
                    _page = 1;
                  }),
                ),
                _dropdown(
                  StudentsScreenConstants.subClassLabel,
                  _subClassFilter,
                  const ['Semua Sub-Kelas', 'IPA 1', 'IPA 2', 'IPS 1'],
                  (v) => setState(() {
                    _subClassFilter = v;
                    _page = 1;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom:
                        StudentsScreenConstants.desktopAddButtonBottomPadding,
                    left: StudentsScreenConstants.desktopAddButtonLeftPadding,
                  ),
                  child: AppButton.accent(
                    height: StudentsScreenConstants.addButtonHeight,
                    label: StudentsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      StudentsScreenConstants.addIcon,
                      size: StudentsScreenConstants.actionIconSize,
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
                            columnSpacing: isSmallScreen
                                ? StudentsScreenConstants
                                      .tableColumnSpacingMobile
                                : StudentsScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? StudentsScreenConstants.headingRowHeightMobile
                                : StudentsScreenConstants
                                      .headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? StudentsScreenConstants.dataRowHeightMobile
                                : StudentsScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? StudentsScreenConstants.dataRowHeightMobile
                                : StudentsScreenConstants.dataRowHeightDesktop,
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
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.noHeader,
                                  width: StudentsScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? StudentsScreenConstants
                                            .nameColumnWidthMobile
                                      : StudentsScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.nisHeader,
                                  width: isSmallScreen
                                      ? StudentsScreenConstants
                                            .nisColumnWidthMobile
                                      : StudentsScreenConstants
                                            .nisColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.classHeader,
                                  width: isSmallScreen
                                      ? StudentsScreenConstants
                                            .classColumnWidthMobile
                                      : StudentsScreenConstants
                                            .classColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.statusHeader,
                                  width: isSmallScreen
                                      ? StudentsScreenConstants
                                            .statusColumnWidthMobile
                                      : StudentsScreenConstants
                                            .statusColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StudentsScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? StudentsScreenConstants
                                            .actionsColumnWidthMobile
                                      : StudentsScreenConstants
                                            .actionsColumnWidthDesktop,
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
                                      width:
                                          StudentsScreenConstants.noColumnWidth,
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
                                      width: isSmallScreen
                                          ? StudentsScreenConstants
                                                .nameColumnWidthMobile
                                          : StudentsScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: StudentsScreenConstants
                                                .rowAvatarRadius,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              StudentsScreenConstants
                                                  .rowAvatarIcon,
                                              size: StudentsScreenConstants
                                                  .rowAvatarIconSize,
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
                                      width: isSmallScreen
                                          ? StudentsScreenConstants
                                                .nisColumnWidthMobile
                                          : StudentsScreenConstants
                                                .nisColumnWidthDesktop,
                                      child: Text(e.nis),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? StudentsScreenConstants
                                                .classColumnWidthMobile
                                          : StudentsScreenConstants
                                                .classColumnWidthDesktop,
                                      child: Text(e.studentClass),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? StudentsScreenConstants
                                                .statusColumnWidthMobile
                                          : StudentsScreenConstants
                                                .statusColumnWidthDesktop,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: e.status.toUpperCase(),
                                          status:
                                              e.status ==
                                                  StudentsScreenConstants
                                                      .activeStatus
                                              ? BadgeStatus.info
                                              : BadgeStatus.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? StudentsScreenConstants
                                                .actionsColumnWidthMobile
                                          : StudentsScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon: StudentsScreenConstants
                                                .viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openStudentDetailModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: StudentsScreenConstants
                                                .editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openStudentEditModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: StudentsScreenConstants
                                                .deleteIcon,
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
                              label:
                                  StudentsScreenConstants.previousButtonLabel,
                              onPressed: safePage > 1
                                  ? () => setState(() => _page = safePage - 1)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton.primary(
                              label: StudentsScreenConstants.nextButtonLabel,
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
                        label: StudentsScreenConstants.previousButtonLabel,
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
                        label: StudentsScreenConstants.nextButtonLabel,
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
      width: StudentsScreenConstants.actionButtonSize,
      height: StudentsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: StudentsScreenConstants.actionIconSize,
          ),
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
