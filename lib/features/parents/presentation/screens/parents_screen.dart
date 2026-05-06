import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/parent_row_data.dart';
import '../widgets/parent_create_modal.dart';
import '../widgets/parent_delete_modal.dart';
import '../widgets/parent_detail_modal.dart';
import '../widgets/parent_edit_modal.dart';
import '../constants/parents_screen_constants.dart';
import '../../data/datasources/parents_dummy_data.dart';
import '../../../../core/utils/responsive.dart';

class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  String _searchQuery = '';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    final filteredRows = parentsDummyRows.where((item) {
      return _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery) ||
          item.email.toLowerCase().contains(_searchQuery) ||
          item.phone.contains(_searchQuery);
    }).toList();

    const rowsPerPage = ParentsScreenConstants.rowsPerPage;
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
                      ParentsScreenConstants.title,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    // const SizedBox(height: AppSpacing.sm),
                    // Text(
                    //   'UI awal daftar orang tua. Data masih dummy untuk validasi flow halaman.',
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
                AppSearchBar(
                  hint: ParentsScreenConstants.searchHint,
                  width: double.infinity,
                  onSearch: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                    _page = 1;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: ParentsScreenConstants.addButtonHeight,
                  isFullWidth: true,
                  label: ParentsScreenConstants.addButtonLabel,
                  prefixIcon: const Icon(
                    ParentsScreenConstants.addIcon,
                    size: ParentsScreenConstants.actionIconSize,
                    color: AppColors.white,
                  ),
                  onPressed: _openParentCreateModal,
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
                      width: ParentsScreenConstants.desktopSearchWidth,
                      child: AppSearchBar(
                        hint: ParentsScreenConstants.searchHint,
                        width: ParentsScreenConstants.desktopSearchWidth,
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
                        ParentsScreenConstants.desktopAddButtonBottomPadding,
                    right: ParentsScreenConstants.desktopAddButtonRightPadding,
                  ),
                  child: AppButton.accent(
                    height: ParentsScreenConstants.addButtonHeight,
                    label: ParentsScreenConstants.addButtonLabel,
                    prefixIcon: const Icon(
                      ParentsScreenConstants.addIcon,
                      size: ParentsScreenConstants.actionIconSize,
                      color: AppColors.white,
                    ),
                    onPressed: _openParentCreateModal,
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
                                ? ParentsScreenConstants
                                      .tableColumnSpacingMobile
                                : ParentsScreenConstants
                                      .tableColumnSpacingDesktop,
                            horizontalMargin: AppSpacing.md,
                            headingRowHeight: isSmallScreen
                                ? ParentsScreenConstants.headingRowHeightMobile
                                : ParentsScreenConstants
                                      .headingRowHeightDesktop,
                            dataRowMinHeight: isSmallScreen
                                ? ParentsScreenConstants.dataRowHeightMobile
                                : ParentsScreenConstants.dataRowHeightDesktop,
                            dataRowMaxHeight: isSmallScreen
                                ? ParentsScreenConstants.dataRowHeightMobile
                                : ParentsScreenConstants.dataRowHeightDesktop,
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
                                  ParentsScreenConstants.noHeader,
                                  width: ParentsScreenConstants.noColumnWidth,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  ParentsScreenConstants.nameHeader,
                                  width: isSmallScreen
                                      ? ParentsScreenConstants
                                            .nameColumnWidthMobile
                                      : ParentsScreenConstants
                                            .nameColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  ParentsScreenConstants.emailHeader,
                                  width: isSmallScreen
                                      ? ParentsScreenConstants
                                            .emailColumnWidthMobile
                                      : ParentsScreenConstants
                                            .emailColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  ParentsScreenConstants.phoneHeader,
                                  width: isSmallScreen
                                      ? ParentsScreenConstants
                                            .phoneColumnWidthMobile
                                      : ParentsScreenConstants
                                            .phoneColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  ParentsScreenConstants.childrenHeader,
                                  width: isSmallScreen
                                      ? ParentsScreenConstants
                                            .childrenColumnWidthMobile
                                      : ParentsScreenConstants
                                            .childrenColumnWidthDesktop,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  ParentsScreenConstants.actionsHeader,
                                  width: isSmallScreen
                                      ? ParentsScreenConstants
                                            .actionsColumnWidthMobile
                                      : ParentsScreenConstants
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
                                          ParentsScreenConstants.noColumnWidth,
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
                                          ? ParentsScreenConstants
                                                .nameColumnWidthMobile
                                          : ParentsScreenConstants
                                                .nameColumnWidthDesktop,
                                      child: Text(
                                        e.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? ParentsScreenConstants
                                                .emailColumnWidthMobile
                                          : ParentsScreenConstants
                                                .emailColumnWidthDesktop,
                                      child: Text(
                                        e.email,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? ParentsScreenConstants
                                                .phoneColumnWidthMobile
                                          : ParentsScreenConstants
                                                .phoneColumnWidthDesktop,
                                      child: Text(e.phone),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? ParentsScreenConstants
                                                .childrenColumnWidthMobile
                                          : ParentsScreenConstants
                                                .childrenColumnWidthDesktop,
                                      child: _childrenCountPill(
                                        e.childrenCount,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen
                                          ? ParentsScreenConstants
                                                .actionsColumnWidthMobile
                                          : ParentsScreenConstants
                                                .actionsColumnWidthDesktop,
                                      child: Row(
                                        children: [
                                          _actionIconButton(
                                            icon:
                                                ParentsScreenConstants.viewIcon,
                                            backgroundColor: AppColors.info,
                                            onTap: () =>
                                                _openParentDetailModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon:
                                                ParentsScreenConstants.editIcon,
                                            backgroundColor: AppColors.warning,
                                            onTap: () =>
                                                _openParentEditModal(e),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: ParentsScreenConstants
                                                .deleteIcon,
                                            backgroundColor: AppColors.error,
                                            onTap: () =>
                                                _openParentDeleteModal(e),
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

  Widget _childrenCountPill(int count) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ParentsScreenConstants.childrenPillHorizontalPadding,
          vertical: ParentsScreenConstants.childrenPillVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          '$count ${ParentsScreenConstants.childrenSuffix}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: ParentsScreenConstants.actionButtonSize,
      height: ParentsScreenConstants.actionButtonSize,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(
            icon,
            color: AppColors.white,
            size: ParentsScreenConstants.actionIconSize,
          ),
        ),
      ),
    );
  }

  void _openParentDetailModal(ParentRowData row) {
    showParentDetailModal(context, data: row);
  }

  void _openParentEditModal(ParentRowData row) {
    showParentEditModal(context, data: row);
  }

  void _openParentDeleteModal(ParentRowData row) {
    showParentDeleteModal(context, data: row);
  }

  void _openParentCreateModal() {
    showParentCreateModal(context);
  }
}
