import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/datasources/admins_dummy_data.dart';
import '../../data/models/admin_row_data.dart';
import '../constants/admins_screen_constants.dart';
import '../widgets/admin_create_modal.dart';
import '../widgets/admin_delete_modal.dart';
import '../widgets/admin_detail_modal.dart';
import '../widgets/admin_edit_modal.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  String _searchQuery = '';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final filteredRows = adminDummyRows.where((row) {
      return _searchQuery.isEmpty ||
          row.name.toLowerCase().contains(_searchQuery) ||
          row.phoneNumber.toLowerCase().contains(_searchQuery) ||
          row.address.toLowerCase().contains(_searchQuery) ||
          row.nik.toLowerCase().contains(_searchQuery);
    }).toList();

    const rowsPerPage = AdminsScreenConstants.rowsPerPage;
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
            AdminsScreenConstants.title,
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: AdminsScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                    _page = 1;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: AdminsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: AdminsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    AdminsScreenConstants.addIcon,
                    size: AdminsScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openAdminCreateModal,
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
                      width: AdminsScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: AdminsScreenConstants.searchHint,
                        width: AdminsScreenConstants.desktopSearchWidth,
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
                    bottom: AdminsScreenConstants.desktopAddButtonBottomPadding,
                    right: AdminsScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: AdminsScreenConstants.addButtonHeight,
                    label: AdminsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      AdminsScreenConstants.addIcon,
                      size: AdminsScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openAdminCreateModal,
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
                                ? AdminsScreenConstants.tableColumnSpacingMobile
                                : AdminsScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? AdminsScreenConstants.headingRowHeightMobile
                                : AdminsScreenConstants.headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? AdminsScreenConstants.dataRowHeightMobile
                                : AdminsScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? AdminsScreenConstants.dataRowHeightMobile
                                : AdminsScreenConstants.dataRowHeightDesktop,
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
                                  AdminsScreenConstants.noHeader,
                                  width: AdminsScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  AdminsScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? AdminsScreenConstants
                                            .nameColumnWidthMobile
                                      : AdminsScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  AdminsScreenConstants.phoneNumberHeader,
                                  width: isSmallScreen
                                      ? AdminsScreenConstants
                                            .phoneNumberColumnWidthMobile
                                      : AdminsScreenConstants
                                            .phoneNumberColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  AdminsScreenConstants.addressHeader,
                                  width: isSmallScreen
                                      ? AdminsScreenConstants
                                            .addressColumnWidthMobile
                                      : AdminsScreenConstants
                                            .addressColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  AdminsScreenConstants.nikHeader,
                                  width: isSmallScreen
                                      ? AdminsScreenConstants
                                            .nikColumnWidthMobile
                                      : AdminsScreenConstants
                                            .nikColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  AdminsScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? AdminsScreenConstants
                                            .actionsColumnWidthMobile
                                      : AdminsScreenConstants
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
                                          AdminsScreenConstants.noColumnWidth,
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
                                          ? AdminsScreenConstants
                                                .nameColumnWidthMobile
                                          : AdminsScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: AdminsScreenConstants
                                                .rowAvatarRadius,
                                            backgroundColor:
                                                AppColors.primary100,
                                            child: Icon(
                                              AdminsScreenConstants
                                                  .rowAvatarIcon,
                                              size: AdminsScreenConstants
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
                                          ? AdminsScreenConstants
                                                .phoneNumberColumnWidthMobile
                                          : AdminsScreenConstants
                                                .phoneNumberColumnWidthDesktop,
                                      child: Text(row.phoneNumber),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .addressColumnWidthMobile
                                          : AdminsScreenConstants
                                                .addressColumnWidthDesktop,
                                      child: Text(
                                        row.address,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .nikColumnWidthMobile
                                          : AdminsScreenConstants
                                                .nikColumnWidthDesktop,
                                      child: Text(row.nik),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? AdminsScreenConstants
                                                .actionsColumnWidthMobile
                                          : AdminsScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon:
                                                AdminsScreenConstants.viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openAdminDetailModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon:
                                                AdminsScreenConstants.editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openAdminEditModal(row),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: AdminsScreenConstants
                                                .deleteIcon,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openAdminDeleteModal(row),
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
      width: AdminsScreenConstants.actionButtonSize,
      height: AdminsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: AdminsScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openAdminDetailModal(AdminRowData row) {
    showAdminDetailModal(context, data: row);
  }

  void _openAdminEditModal(AdminRowData row) {
    showAdminEditModal(context, data: row);
  }

  void _openAdminDeleteModal(AdminRowData row) {
    showAdminDeleteModal(context, data: row);
  }

  void _openAdminCreateModal() {
    showAdminCreateModal(context);
  }
}
