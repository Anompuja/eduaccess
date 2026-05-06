import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/staff_row_data.dart';
import '../widgets/staff_create_modal.dart';
import '../widgets/staff_delete_modal.dart';
import '../widgets/staff_detail_modal.dart';
import '../widgets/staff_edit_modal.dart';
import '../../data/datasources/staff_dummy_data.dart';
import '../constants/staff_screen_constants.dart';
import '../../../../core/utils/responsive.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String _searchQuery = '';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final filteredRows = staffDummyRows.where((row) {
      return _searchQuery.isEmpty ||
          row.name.toLowerCase().contains(_searchQuery) ||
          row.email.toLowerCase().contains(_searchQuery) ||
          row.role.toLowerCase().contains(_searchQuery);
    }).toList();

    const rowsPerPage = StaffScreenConstants.rowsPerPage;
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
            StaffScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: StaffScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                    _page = 1;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: StaffScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: StaffScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    StaffScreenConstants.addIcon,
                    size: StaffScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openStaffCreateModal,
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
                      width: StaffScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: StaffScreenConstants.searchHint,
                        width: StaffScreenConstants.desktopSearchWidth,
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
                    bottom: StaffScreenConstants.desktopAddButtonBottomPadding,
                    right: StaffScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: StaffScreenConstants.addButtonHeight,
                    label: StaffScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      StaffScreenConstants.addIcon,
                      size: StaffScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openStaffCreateModal,
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
                                ? StaffScreenConstants.tableColumnSpacingMobile
                                : StaffScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? StaffScreenConstants.headingRowHeightMobile
                                : StaffScreenConstants.headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? StaffScreenConstants.dataRowHeightMobile
                                : StaffScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? StaffScreenConstants.dataRowHeightMobile
                                : StaffScreenConstants.dataRowHeightDesktop,
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
                                  StaffScreenConstants.noHeader,
                                  width: StaffScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StaffScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? StaffScreenConstants
                                            .nameColumnWidthMobile
                                      : StaffScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StaffScreenConstants.emailHeader,
                                  width: isSmallScreen
                                      ? StaffScreenConstants
                                            .emailColumnWidthMobile
                                      : StaffScreenConstants
                                            .emailColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StaffScreenConstants.roleHeader,
                                  width: isSmallScreen
                                      ? StaffScreenConstants
                                            .roleColumnWidthMobile
                                      : StaffScreenConstants
                                            .roleColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StaffScreenConstants.statusHeader,
                                  width: isSmallScreen
                                      ? StaffScreenConstants
                                            .statusColumnWidthMobile
                                      : StaffScreenConstants
                                            .statusColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  StaffScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? StaffScreenConstants
                                            .actionsColumnWidthMobile
                                      : StaffScreenConstants
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
                                      width: StaffScreenConstants.noColumnWidth,
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
                                          ? StaffScreenConstants
                                                .nameColumnWidthMobile
                                          : StaffScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: StaffScreenConstants
                                                .rowAvatarRadius,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              StaffScreenConstants
                                                  .rowAvatarIcon,
                                              size: StaffScreenConstants
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
                                          ? StaffScreenConstants
                                                .emailColumnWidthMobile
                                          : StaffScreenConstants
                                                .emailColumnWidthDesktop,
                                      child: Text(row.email),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .roleColumnWidthMobile
                                          : StaffScreenConstants
                                                .roleColumnWidthDesktop,
                                      child: Text(row.role),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? StaffScreenConstants
                                                .statusColumnWidthMobile
                                          : StaffScreenConstants
                                                .statusColumnWidthDesktop,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: row.status.toUpperCase(),
                                          status:
                                              row.status ==
                                                  StaffScreenConstants
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
                                          ? StaffScreenConstants
                                                .actionsColumnWidthMobile
                                          : StaffScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon: StaffScreenConstants.viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openStaffDetailModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: StaffScreenConstants.editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openStaffEditModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon:
                                                StaffScreenConstants.deleteIcon,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openStaffDeleteModal(row),
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
      width: StaffScreenConstants.actionButtonSize,
      height: StaffScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: StaffScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openStaffDetailModal(StaffRowData row) {
    showStaffDetailModal(context, data: row);
  }

  void _openStaffEditModal(StaffRowData row) {
    showStaffEditModal(context, data: row);
  }

  void _openStaffDeleteModal(StaffRowData row) {
    showStaffDeleteModal(context, data: row);
  }

  void _openStaffCreateModal() {
    showStaffCreateModal(context);
  }
}
