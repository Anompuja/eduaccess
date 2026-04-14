import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchCtrl = TextEditingController();
  int _page = 1;

  final List<_StaffRow> _staffRows = const [
    _StaffRow(
      name: 'Taufik Hidayat',
      email: 'taufik.staff@edu.id',
      role: 'Administrasi',
      status: 'Aktif',
    ),
    _StaffRow(
      name: 'Rina Amelia',
      email: 'rina.staff@edu.id',
      role: 'Keuangan',
      status: 'Nonaktif',
    ),
    _StaffRow(
      name: 'Dewi Sartika',
      email: 'dewi.staff@edu.id',
      role: 'Operator',
      status: 'Aktif',
    ),
    _StaffRow(
      name: 'Maya Putri',
      email: 'maya.staff@edu.id',
      role: 'TU',
      status: 'Aktif',
    ),
    _StaffRow(
      name: 'Arif Nugraha',
      email: 'arif.staff@edu.id',
      role: 'Perpustakaan',
      status: 'Nonaktif',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 700;
    final query = _searchCtrl.text.toLowerCase().trim();
    final filteredRows = _staffRows.where((row) {
      return query.isEmpty ||
          row.name.toLowerCase().contains(query) ||
          row.email.toLowerCase().contains(query) ||
          row.role.toLowerCase().contains(query);
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
          Text(
            'Manajemen Staff',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Cari nama / email / role',
                  hint: 'Contoh: taufik atau staff@edu.id',
                  controller: _searchCtrl,
                  prefixIcon: Icons.search,
                  onChanged: (_) => setState(() => _page = 1),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: 50,
                  isFullWidth: true,
                  label: 'Tambah Staff',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: AppColors.white,
                  ),
                  onPressed: () {},
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
                    label: 'Cari nama / email / role',
                    hint: 'Contoh: taufik atau staff@edu.id',
                    controller: _searchCtrl,
                    prefixIcon: Icons.search,
                    onChanged: (_) => setState(() => _page = 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                  child: AppButton.accent(
                    height: 50,
                    label: 'Tambah Staff',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: AppColors.white,
                    ),
                    onPressed: () {},
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
                                  'EMAIL',
                                  width: isSmallScreen ? 180 : 260,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'ROLE',
                                  width: isSmallScreen ? 120 : 150,
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
                              final row = entry.value;
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
                                              Icons.badge,
                                              size: 16,
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
                                      width: isSmallScreen ? 180 : 260,
                                      child: Text(row.email),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 120 : 150,
                                      child: Text(row.role),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 100 : 120,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: AppBadge(
                                          label: row.status.toUpperCase(),
                                          status: row.status == 'Aktif'
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
                                            onTap: () {},
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: Icons.edit_outlined,
                                            backgroundColor: AppColors.warning,
                                            onTap: () {},
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          _actionIconButton(
                                            icon: Icons.delete_outline,
                                            backgroundColor: AppColors.error,
                                            onTap: () {},
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
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }
}

class _StaffRow {
  final String name;
  final String email;
  final String role;
  final String status;

  const _StaffRow({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}
