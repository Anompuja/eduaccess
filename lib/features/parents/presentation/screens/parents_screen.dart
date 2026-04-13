import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final _searchCtrl = TextEditingController();
  int _page = 1;

  final List<_ParentRow> _dummyRows = const [
    _ParentRow(
      name: 'Iwan Kurniawan',
      email: 'iwan.parent@edu.id',
      phone: '081234567890',
      childrenCount: 2,
    ),
    _ParentRow(
      name: 'Maya Rachma',
      email: 'maya.parent@edu.id',
      phone: '082233445566',
      childrenCount: 1,
    ),
    _ParentRow(
      name: 'Heri Saputra',
      email: 'heri.parent@edu.id',
      phone: '083322114455',
      childrenCount: 3,
    ),
    _ParentRow(
      name: 'Rina Wahyuni',
      email: 'rina.parent@edu.id',
      phone: '081998877665',
      childrenCount: 2,
    ),
    _ParentRow(
      name: 'Arif Nugroho',
      email: 'arif.parent@edu.id',
      phone: '082177766655',
      childrenCount: 1,
    ),
    _ParentRow(
      name: 'Sari Puspita',
      email: 'sari.parent@edu.id',
      phone: '083355544433',
      childrenCount: 4,
    ),
    _ParentRow(
      name: 'Budi Prasetyo',
      email: 'budi.parent@edu.id',
      phone: '081122334455',
      childrenCount: 2,
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
    final filteredRows = _dummyRows.where((item) {
      final q = _searchCtrl.text.trim().toLowerCase();
      return q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.email.toLowerCase().contains(q) ||
          item.phone.contains(q);
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
                      'Manajemen Orang Tua',
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
                AppTextField(
                  label: 'Cari nama / email / no hp',
                  hint: 'Contoh: iwan atau parent@edu.id',
                  controller: _searchCtrl,
                  prefixIcon: Icons.search,
                  onChanged: (_) => setState(() => _page = 1),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.accent(
                  height: 50,
                  isFullWidth: true,
                  label: 'Tambah Orang Tua',
                  prefixIcon: const Icon(
                    Icons.group_add,
                    size: 18,
                    color: AppColors.white,
                  ),
                  onPressed: () {},
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
                      width: 320,
                      child: AppTextField(
                        label: 'Cari nama / email / no hp',
                        hint: 'Contoh: iwan atau parent@edu.id',
                        controller: _searchCtrl,
                        prefixIcon: Icons.search,
                        onChanged: (_) => setState(() => _page = 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: AppButton.accent(
                    height: 50,
                    label: 'Tambah Orang Tua',
                    prefixIcon: const Icon(
                      Icons.group_add,
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
                                  width: isSmallScreen ? 170 : 240,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'EMAIL',
                                  width: isSmallScreen ? 220 : 250,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'NO. HP',
                                  width: isSmallScreen ? 120 : 130,
                                ),
                              ),
                              DataColumn(
                                label: _tableHeader(
                                  'ANAK',
                                  width: isSmallScreen ? 90 : 120,
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
                                      width: isSmallScreen ? 170 : 240,
                                      child: Text(
                                        e.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 220 : 250,
                                      child: Text(
                                        e.email,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 120 : 130,
                                      child: Text(e.phone),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: isSmallScreen ? 90 : 120,
                                      child: _childrenCountPill(
                                        e.childrenCount,
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

  Widget _childrenCountPill(int count) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          '$count siswa',
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
}

class _ParentRow {
  final String name;
  final String email;
  final String phone;
  final int childrenCount;

  const _ParentRow({
    required this.name,
    required this.email,
    required this.phone,
    required this.childrenCount,
  });
}
