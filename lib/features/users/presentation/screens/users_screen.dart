import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/user_row_data.dart';
import '../widgets/user_create_modal.dart';
import '../widgets/user_delete_modal.dart';
import '../widgets/user_detail_modal.dart';
import '../widgets/user_edit_modal.dart';
import '../constants/users_screen_constants.dart';
import '../../data/datasources/users_dummy_data.dart';
import '../../../../core/utils/responsive.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final filteredRows = usersDummyRows.where((row) {
      return _searchQuery.isEmpty ||
          row.name.toLowerCase().contains(_searchQuery) ||
          row.email.toLowerCase().contains(_searchQuery) ||
          row.role.toLowerCase().contains(_searchQuery);
    }).toList();

    const rowsPerPage = UsersScreenConstants.rowsPerPage;
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
            UsersScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: UsersScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                    _page = 1;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: UsersScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: UsersScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    UsersScreenConstants.addIcon,
                    size: UsersScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openUserCreateModal,
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
                      width: UsersScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: UsersScreenConstants.searchHint,
                        width: UsersScreenConstants.desktopSearchWidth,
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
                    bottom: UsersScreenConstants.desktopAddButtonBottomPadding,
                    right: UsersScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: UsersScreenConstants.addButtonHeight,
                    label: UsersScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      UsersScreenConstants.addIcon,
                      size: UsersScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openUserCreateModal,
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
                                ? UsersScreenConstants.tableColumnSpacingMobile
                                : UsersScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? UsersScreenConstants.headingRowHeightMobile
                                : UsersScreenConstants.headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? UsersScreenConstants.dataRowHeightMobile
                                : UsersScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? UsersScreenConstants.dataRowHeightMobile
                                : UsersScreenConstants.dataRowHeightDesktop,
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
                                  UsersScreenConstants.noHeader,
                                  width: UsersScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  UsersScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? UsersScreenConstants
                                            .nameColumnWidthMobile
                                      : UsersScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  UsersScreenConstants.emailHeader,
                                  width: isSmallScreen
                                      ? UsersScreenConstants
                                            .emailColumnWidthMobile
                                      : UsersScreenConstants
                                            .emailColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  UsersScreenConstants.roleHeader,
                                  width: isSmallScreen
                                      ? UsersScreenConstants
                                            .roleColumnWidthMobile
                                      : UsersScreenConstants
                                            .roleColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  UsersScreenConstants.statusHeader,
                                  width: isSmallScreen
                                      ? UsersScreenConstants
                                            .statusColumnWidthMobile
                                      : UsersScreenConstants
                                            .statusColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  UsersScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? UsersScreenConstants
                                            .actionsColumnWidthMobile
                                      : UsersScreenConstants
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
                                      width: UsersScreenConstants.noColumnWidth,
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
                                          ? UsersScreenConstants
                                                .nameColumnWidthMobile
                                          : UsersScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: UsersScreenConstants
                                                .rowAvatarRadius,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              UsersScreenConstants
                                                  .rowAvatarIcon,
                                              size: UsersScreenConstants
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
                                          ? UsersScreenConstants
                                                .emailColumnWidthMobile
                                          : UsersScreenConstants
                                                .emailColumnWidthDesktop,
                                      child: Text(row.email),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? UsersScreenConstants
                                                .roleColumnWidthMobile
                                          : UsersScreenConstants
                                                .roleColumnWidthDesktop,
                                      child: Text(row.role),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? UsersScreenConstants
                                                .statusColumnWidthMobile
                                          : UsersScreenConstants
                                                .statusColumnWidthDesktop,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: row.status.toUpperCase(),
                                          status:
                                              row.status ==
                                                  UsersScreenConstants
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
                                          ? UsersScreenConstants
                                                .actionsColumnWidthMobile
                                          : UsersScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon: UsersScreenConstants.viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openUserDetailModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: UsersScreenConstants.editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openUserEditModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon:
                                                UsersScreenConstants.deleteIcon,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openUserDeleteModal(row),
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
      width: UsersScreenConstants.actionButtonSize,
      height: UsersScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: UsersScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openUserDetailModal(UserRowData row) {
    showUserDetailModal(context, data: row);
  }

  void _openUserEditModal(UserRowData row) {
    showUserEditModal(context, data: row);
  }

  void _openUserDeleteModal(UserRowData row) {
    showUserDeleteModal(context, data: row);
  }

  void _openUserCreateModal() {
    showUserCreateModal(context);
  }
}
