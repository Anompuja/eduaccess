import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/teacher_row_data.dart';
import '../widgets/teacher_create_modal.dart';
import '../widgets/teacher_delete_modal.dart';
import '../widgets/teacher_detail_modal.dart';
import '../widgets/teacher_edit_modal.dart';
import '../constants/teachers_screen_constants.dart';
import '../../data/datasources/teachers_dummy_data.dart';
import '../../../../core/utils/responsive.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  String _searchQuery = '';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final filteredRows = teacherDummyRows.where((row) {
      return _searchQuery.isEmpty ||
          row.name.toLowerCase().contains(_searchQuery) ||
          row.nip.contains(_searchQuery) ||
          row.subject.toLowerCase().contains(_searchQuery) ||
          row.email.toLowerCase().contains(_searchQuery);
    }).toList();

    const rowsPerPage = TeachersScreenConstants.rowsPerPage;
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
          Text(
            TeachersScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: TeachersScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                    _page = 1;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: TeachersScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: TeachersScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    TeachersScreenConstants.addIcon,
                    size: TeachersScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openTeacherCreateModal,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: TeachersScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: TeachersScreenConstants.searchHint,
                        width: TeachersScreenConstants.desktopSearchWidth,
                        onSearch: (value) => setState(() {
                          _searchQuery = value.toLowerCase().trim();
                          _page = 1;
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom:
                        TeachersScreenConstants.desktopAddButtonBottomPadding,
                    right: TeachersScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: TeachersScreenConstants.addButtonHeight,
                    label: TeachersScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      TeachersScreenConstants.addIcon,
                      size: TeachersScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openTeacherCreateModal,
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
                                ? TeachersScreenConstants
                                      .tableColumnSpacingMobile
                                : TeachersScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? TeachersScreenConstants.headingRowHeightMobile
                                : TeachersScreenConstants
                                      .headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? TeachersScreenConstants.dataRowHeightMobile
                                : TeachersScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? TeachersScreenConstants.dataRowHeightMobile
                                : TeachersScreenConstants.dataRowHeightDesktop,
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
                                  TeachersScreenConstants.noHeader,
                                  width: TeachersScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  TeachersScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? TeachersScreenConstants
                                            .nameColumnWidthMobile
                                      : TeachersScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  TeachersScreenConstants.nipHeader,
                                  width: isSmallScreen
                                      ? TeachersScreenConstants
                                            .nipColumnWidthMobile
                                      : TeachersScreenConstants
                                            .nipColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  TeachersScreenConstants.subjectHeader,
                                  width: isSmallScreen
                                      ? TeachersScreenConstants
                                            .subjectColumnWidthMobile
                                      : TeachersScreenConstants
                                            .subjectColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  TeachersScreenConstants.statusHeader,
                                  width: isSmallScreen
                                      ? TeachersScreenConstants
                                            .statusColumnWidthMobile
                                      : TeachersScreenConstants
                                            .statusColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  TeachersScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? TeachersScreenConstants
                                            .actionsColumnWidthMobile
                                      : TeachersScreenConstants
                                            .actionsColumnWidthDesktop,
                                ),
                              ),
                            ],
                            rows: pagedRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width:
                                          TeachersScreenConstants.noColumnWidth,
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
                                          ? TeachersScreenConstants
                                                .nameColumnWidthMobile
                                          : TeachersScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: TeachersScreenConstants
                                                .rowAvatarRadius,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              TeachersScreenConstants
                                                  .rowAvatarIcon,
                                              size: TeachersScreenConstants
                                                  .rowAvatarIconSize,
                                              color: AppColors.primary700,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Text(
                                              row.name,
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
                                          ? TeachersScreenConstants
                                                .nipColumnWidthMobile
                                          : TeachersScreenConstants
                                                .nipColumnWidthDesktop,
                                      child: Text(row.nip),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? TeachersScreenConstants
                                                .subjectColumnWidthMobile
                                          : TeachersScreenConstants
                                                .subjectColumnWidthDesktop,
                                      child: Text(row.subject),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? TeachersScreenConstants
                                                .statusColumnWidthMobile
                                          : TeachersScreenConstants
                                                .statusColumnWidthDesktop,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: row.status.toUpperCase(),
                                          status:
                                              row.status ==
                                                  TeachersScreenConstants
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
                                          ? TeachersScreenConstants
                                                .actionsColumnWidthMobile
                                          : TeachersScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon: TeachersScreenConstants
                                                .viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openTeacherDetailModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: TeachersScreenConstants
                                                .editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openTeacherEditModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: TeachersScreenConstants
                                                .deleteIcon,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openTeacherDeleteModal(row),
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
                      Center(
                        child: AppPagination(
                          currentPage: safePage,
                          totalPages: totalPages,
                          onPageChanged: (page) => setState(() => _page = page),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Halaman $safePage dari $totalPages',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppPagination(
                        currentPage: safePage,
                        totalPages: totalPages,
                        onPageChanged: (page) => setState(() => _page = page),
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
      width: TeachersScreenConstants.actionButtonSize,
      height: TeachersScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: TeachersScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openTeacherDetailModal(TeacherRowData row) {
    showTeacherDetailModal(context, data: row);
  }

  void _openTeacherEditModal(TeacherRowData row) {
    showTeacherEditModal(context, data: row);
  }

  void _openTeacherDeleteModal(TeacherRowData row) {
    showTeacherDeleteModal(context, data: row);
  }

  void _openTeacherCreateModal() {
    showTeacherCreateModal(context);
  }
}
