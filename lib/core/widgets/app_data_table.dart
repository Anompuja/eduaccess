import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_empty_state.dart';
import 'app_pagination.dart';
import 'app_search_bar.dart';

/// Column definition for AppDataTable.
class AppTableColumn {
  final String label;
  final double? width;       // fixed width; null = flex
  final bool sortable;
  final TextAlign align;

  const AppTableColumn({
    required this.label,
    this.width,
    this.sortable = false,
    this.align = TextAlign.left,
  });
}

/// EduAccess data table with search + sort + pagination.
///
/// ```dart
/// AppDataTable(
///   columns: [
///     AppTableColumn(label: 'Nama', sortable: true),
///     AppTableColumn(label: 'NIS', width: 120),
///     AppTableColumn(label: 'Kelas', width: 80),
///     AppTableColumn(label: 'Status', width: 100),
///   ],
///   rows: students.map((s) => [s.name, s.nis, s.classroom, _badge(s)]).toList(),
///   totalRows: students.length,
/// )
/// ```
class AppDataTable extends StatefulWidget {
  final List<AppTableColumn> columns;
  final List<List<dynamic>> rows;   // Widget or String per cell
  final int totalRows;
  final int pageSize;
  final bool showSearch;
  final String searchHint;
  final void Function(String)? onSearch;
  final void Function(int column, bool ascending)? onSort;
  final void Function(int page)? onPageChanged;
  final int currentPage;
  final String emptyMessage;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.totalRows = 0,
    this.pageSize = 10,
    this.showSearch = true,
    this.searchHint = 'Cari...',
    this.onSearch,
    this.onSort,
    this.onPageChanged,
    this.currentPage = 1,
    this.emptyMessage = 'Tidak ada data',
  });

  @override
  State<AppDataTable> createState() => _AppDataTableState();
}

class _AppDataTableState extends State<AppDataTable> {
  int? _sortColumn;
  bool _sortAsc = true;

  void _handleSort(int column) {
    final asc = _sortColumn == column ? !_sortAsc : true;
    setState(() {
      _sortColumn = column;
      _sortAsc = asc;
    });
    widget.onSort?.call(column, asc);
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.totalRows / widget.pageSize).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        if (widget.showSearch && widget.onSearch != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: AppSearchBar(
              hint: widget.searchHint,
              onSearch: widget.onSearch!,
              width: 280,
            ),
          ),

        // ── Table container ─────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.xlAll,
            boxShadow: AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header
              _TableHeader(
                columns: widget.columns,
                sortColumn: _sortColumn,
                sortAsc: _sortAsc,
                onSort: widget.onSort != null ? _handleSort : null,
              ),
              const Divider(height: 1, color: AppColors.neutral100),
              // Body
              widget.rows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: AppEmptyState(message: widget.emptyMessage),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.rows.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.neutral100),
                      itemBuilder: (_, i) => _TableRow(
                        cells: widget.rows[i],
                        columns: widget.columns,
                        isAlt: i.isOdd,
                      ),
                    ),
            ],
          ),
        ),

        // ── Pagination ──────────────────────────────────────────────────────
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  '${widget.totalRows} data',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
                ),
                const Spacer(),
                AppPagination(
                  currentPage: widget.currentPage,
                  totalPages: totalPages,
                  onPageChanged: widget.onPageChanged ?? (_) {},
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Internal sub-widgets ──────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final List<AppTableColumn> columns;
  final int? sortColumn;
  final bool sortAsc;
  final void Function(int)? onSort;

  const _TableHeader({
    required this.columns,
    this.sortColumn,
    required this.sortAsc,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral50,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: columns.asMap().entries.map((e) {
          final i = e.key;
          final col = e.value;
          final isSorted = sortColumn == i;

          Widget label = Text(
            col.label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w600,
            ),
            textAlign: col.align,
          );

          if (col.sortable && onSort != null) {
            label = GestureDetector(
              onTap: () => onSort!(i),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  const SizedBox(width: 4),
                  Icon(
                    isSorted
                        ? (sortAsc
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded)
                        : Icons.unfold_more_rounded,
                    size: 14,
                    color: isSorted
                        ? AppColors.primary700
                        : AppColors.neutral300,
                  ),
                ],
              ),
            );
          }

          return col.width != null
              ? SizedBox(width: col.width, child: label)
              : Expanded(child: label);
        }).toList(),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<dynamic> cells;
  final List<AppTableColumn> columns;
  final bool isAlt;

  const _TableRow({
    required this.cells,
    required this.columns,
    required this.isAlt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: isAlt ? AppColors.neutral50 : AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: cells.asMap().entries.map((e) {
          final i = e.key;
          final cell = e.value;
          final col = i < columns.length ? columns[i] : null;

          Widget content = cell is Widget
              ? cell
              : Text(
                  cell.toString(),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral900,
                  ),
                  textAlign: col?.align ?? TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                );

          return col?.width != null
              ? SizedBox(width: col!.width, child: content)
              : Expanded(child: content);
        }).toList(),
      ),
    );
  }
}
