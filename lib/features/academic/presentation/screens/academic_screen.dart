import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/academic_dummy_data.dart';
import '../../data/models/academic_entities.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<AcademicLevel> _levels = List.of(academicDummyLevels);
  List<AcademicClass> _classes = List.of(academicDummyClasses);
  List<AcademicSubClass> _subClasses = List.of(academicDummySubClasses);

  String _classLevelFilter = 'all';
  String _subClassFilter = 'all';

  int _levelSeq = 100;
  int _classSeq = 200;
  int _subClassSeq = 300;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding:
          isMobile ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Struktur Akademik',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kelola level pendidikan, kelas, dan sub-kelas (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: isMobile,
                    labelColor: AppColors.primary700,
                    unselectedLabelColor: AppColors.neutral500,
                    indicatorColor: AppColors.primary700,
                    labelStyle: AppTextStyles.bodyMdSemiBold,
                    tabs: const [
                      Tab(text: 'Level Pendidikan'),
                      Tab(text: 'Kelas'),
                      Tab(text: 'Sub-Kelas'),
                    ],
                  ),
                  const Divider(height: 1, color: AppColors.neutral100),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLevelTab(),
                        _buildClassTab(isMobile),
                        _buildSubClassTab(isMobile),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.accent(
              label: 'Tambah Level',
              prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              onPressed: _openCreateLevelDialog,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _tableCard(
            columns: [
              DataColumn(label: _tableHeader('No', width: 64)),
              DataColumn(label: _tableHeader('Level', width: 220)),
              DataColumn(label: _tableHeader('Jumlah Kelas', width: 170)),
              DataColumn(label: _tableHeader('Status', width: 140)),
              DataColumn(label: _tableHeader('Aksi', width: 120)),
            ],
            rows: _levels.asMap().entries.map((entry) {
              final index = entry.key;
              final level = entry.value;
              final classCount = _classes.where((e) => e.levelId == level.id).length;

              return DataRow(
                cells: [
                  DataCell(_cellBox('${index + 1}', width: 64)),
                  DataCell(_cellBox(level.name, width: 220)),
                  DataCell(_cellBox('$classCount kelas', width: 170)),
                  const DataCell(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBadge(label: 'ACTIVE', status: BadgeStatus.info),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: _rowActions(
                        onEdit: () => _openEditLevelDialog(level),
                        onDelete: () => _deleteLevel(level),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTab(bool isMobile) {
    final filteredClasses = _classLevelFilter == 'all'
        ? _classes
        : _classes.where((e) => e.levelId == _classLevelFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              children: [
                _levelFilterDropdown(),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.accent(
                    label: 'Tambah Kelas',
                    prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                    onPressed: _openCreateClassDialog,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                SizedBox(width: 280, child: _levelFilterDropdown()),
                const Spacer(),
                AppButton.accent(
                  label: 'Tambah Kelas',
                  prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                  onPressed: _openCreateClassDialog,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          _tableCard(
            columns: [
              DataColumn(label: _tableHeader('No', width: 64)),
              DataColumn(label: _tableHeader('Nama Kelas', width: 220)),
              DataColumn(label: _tableHeader('Level', width: 160)),
              DataColumn(label: _tableHeader('Jumlah Sub-Kelas', width: 180)),
              DataColumn(label: _tableHeader('Aksi', width: 120)),
            ],
            rows: filteredClasses.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final levelName = _findLevelName(row.levelId);
              final subClassCount = _subClasses.where((e) => e.classId == row.id).length;

              return DataRow(
                cells: [
                  DataCell(_cellBox('${index + 1}', width: 64)),
                  DataCell(_cellBox(row.name, width: 220)),
                  DataCell(_cellBox(levelName, width: 160)),
                  DataCell(_cellBox('$subClassCount sub-kelas', width: 180)),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: _rowActions(
                        onEdit: () => _openEditClassDialog(row),
                        onDelete: () => _deleteClass(row),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubClassTab(bool isMobile) {
    final filteredSubClasses = _subClassFilter == 'all'
        ? _subClasses
        : _subClasses.where((e) => e.classId == _subClassFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              children: [
                _classFilterDropdown(),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.accent(
                    label: 'Tambah Sub-Kelas',
                    prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                    onPressed: _openCreateSubClassDialog,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                SizedBox(width: 280, child: _classFilterDropdown()),
                const Spacer(),
                AppButton.accent(
                  label: 'Tambah Sub-Kelas',
                  prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                  onPressed: _openCreateSubClassDialog,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          _tableCard(
            columns: [
              DataColumn(label: _tableHeader('No', width: 64)),
              DataColumn(label: _tableHeader('Sub-Kelas', width: 220)),
              DataColumn(label: _tableHeader('Kelas', width: 170)),
              DataColumn(label: _tableHeader('Level', width: 160)),
              DataColumn(label: _tableHeader('Aksi', width: 120)),
            ],
            rows: filteredSubClasses.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final className = _findClassName(row.classId);
              final levelName = _findLevelNameByClassId(row.classId);

              return DataRow(
                cells: [
                  DataCell(_cellBox('${index + 1}', width: 64)),
                  DataCell(_cellBox(row.name, width: 220)),
                  DataCell(_cellBox(className, width: 170)),
                  DataCell(_cellBox(levelName, width: 160)),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: _rowActions(
                        onEdit: () => _openEditSubClassDialog(row),
                        onDelete: () => _deleteSubClass(row),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _tableCard({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                child: DataTable(
                  columnSpacing: Responsive.isMobile(context) ? 12 : 24,
                  horizontalMargin: AppSpacing.md,
                  headingRowHeight: Responsive.isMobile(context) ? 42 : 48,
                  dataRowMinHeight: Responsive.isMobile(context) ? 50 : 54,
                  dataRowMaxHeight: Responsive.isMobile(context) ? 50 : 54,
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
                  columns: columns,
                  rows: rows,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _cellBox(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _levelFilterDropdown() {
    return AppDropdown<String>(
      label: 'Filter Level',
      value: _classLevelFilter,
      items: [
        const AppDropdownItem<String>(value: 'all', label: 'Semua Level'),
        ..._levels.map((level) => AppDropdownItem<String>(value: level.id, label: level.name)),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _classLevelFilter = value);
      },
    );
  }

  Widget _classFilterDropdown() {
    return AppDropdown<String>(
      label: 'Filter Kelas',
      value: _subClassFilter,
      items: [
        const AppDropdownItem<String>(value: 'all', label: 'Semua Kelas'),
        ..._classes.map((item) => AppDropdownItem<String>(value: item.id, label: item.name)),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _subClassFilter = value);
      },
    );
  }

  Widget _rowActions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      children: [
        _actionButton(icon: Icons.edit_outlined, color: AppColors.warning, onTap: onEdit),
        const SizedBox(width: AppSpacing.sm),
        _actionButton(icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: color,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  Future<void> _openCreateLevelDialog() async {
    final controller = TextEditingController();
    await _showNameDialog(
      title: 'Tambah Level Pendidikan',
      label: 'Nama Level',
      controller: controller,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _levels = [..._levels, AcademicLevel(id: 'lvl_${_levelSeq++}', name: name)];
        });
      },
    );
  }

  Future<void> _openEditLevelDialog(AcademicLevel level) async {
    final controller = TextEditingController(text: level.name);
    await _showNameDialog(
      title: 'Edit Level Pendidikan',
      label: 'Nama Level',
      controller: controller,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _levels =
              _levels.map((item) => item.id == level.id ? item.copyWith(name: name) : item).toList();
        });
      },
    );
  }

  Future<void> _deleteLevel(AcademicLevel level) async {
    final hasClass = _classes.any((element) => element.levelId == level.id);
    if (hasClass) {
      _showDependencyDialog(
        title: 'Level Tidak Bisa Dihapus',
        message:
            'Masih ada kelas yang terhubung ke level ini. Hapus atau pindahkan kelas terlebih dahulu.',
      );
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Level',
      message: 'Level "${level.name}" akan dihapus.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );

    if (confirmed != true) return;

    setState(() {
      _levels = _levels.where((item) => item.id != level.id).toList();
    });
  }

  Future<void> _openCreateClassDialog() async {
    if (_levels.isEmpty) {
      _showDependencyDialog(
        title: 'Level Belum Ada',
        message: 'Tambahkan level pendidikan dulu sebelum membuat kelas.',
      );
      return;
    }

    var selectedLevelId = _levels.first.id;
    final controller = TextEditingController();

    await _showClassDialog(
      title: 'Tambah Kelas',
      nameController: controller,
      initialLevelId: selectedLevelId,
      onLevelChanged: (value) => selectedLevelId = value,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _classes = [
            ..._classes,
            AcademicClass(id: 'cls_${_classSeq++}', levelId: selectedLevelId, name: name),
          ];
        });
      },
    );
  }

  Future<void> _openEditClassDialog(AcademicClass row) async {
    var selectedLevelId = row.levelId;
    final controller = TextEditingController(text: row.name);

    await _showClassDialog(
      title: 'Edit Kelas',
      nameController: controller,
      initialLevelId: selectedLevelId,
      onLevelChanged: (value) => selectedLevelId = value,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _classes = _classes
              .map(
                (item) => item.id == row.id ? item.copyWith(name: name, levelId: selectedLevelId) : item,
              )
              .toList();
        });
      },
    );
  }

  Future<void> _deleteClass(AcademicClass row) async {
    final hasSubClass = _subClasses.any((element) => element.classId == row.id);
    if (hasSubClass) {
      _showDependencyDialog(
        title: 'Kelas Tidak Bisa Dihapus',
        message:
            'Masih ada sub-kelas yang terhubung ke kelas ini. Hapus sub-kelas terlebih dahulu.',
      );
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Kelas',
      message: 'Kelas "${row.name}" akan dihapus.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );

    if (confirmed != true) return;

    setState(() {
      _classes = _classes.where((item) => item.id != row.id).toList();
      if (_subClassFilter == row.id) _subClassFilter = 'all';
    });
  }

  Future<void> _openCreateSubClassDialog() async {
    if (_classes.isEmpty) {
      _showDependencyDialog(
        title: 'Kelas Belum Ada',
        message: 'Tambahkan kelas dulu sebelum membuat sub-kelas.',
      );
      return;
    }

    var selectedClassId = _classes.first.id;
    final controller = TextEditingController();

    await _showSubClassDialog(
      title: 'Tambah Sub-Kelas',
      nameController: controller,
      initialClassId: selectedClassId,
      onClassChanged: (value) => selectedClassId = value,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _subClasses = [
            ..._subClasses,
            AcademicSubClass(id: 'sub_${_subClassSeq++}', classId: selectedClassId, name: name),
          ];
        });
      },
    );
  }

  Future<void> _openEditSubClassDialog(AcademicSubClass row) async {
    var selectedClassId = row.classId;
    final controller = TextEditingController(text: row.name);

    await _showSubClassDialog(
      title: 'Edit Sub-Kelas',
      nameController: controller,
      initialClassId: selectedClassId,
      onClassChanged: (value) => selectedClassId = value,
      onSave: () {
        final name = controller.text.trim();
        if (name.isEmpty) return;

        setState(() {
          _subClasses = _subClasses
              .map(
                (item) => item.id == row.id ? item.copyWith(name: name, classId: selectedClassId) : item,
              )
              .toList();
        });
      },
    );
  }

  Future<void> _deleteSubClass(AcademicSubClass row) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Sub-Kelas',
      message: 'Sub-kelas "${row.name}" akan dihapus.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );

    if (confirmed != true) return;

    setState(() {
      _subClasses = _subClasses.where((item) => item.id != row.id).toList();
    });
  }

  Future<void> _showNameDialog({
    required String title,
    required String label,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        content: AppTextField(label: label, controller: controller, hint: 'Masukkan $label'),
        actions: [
          AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(context).pop()),
          AppButton.primary(
            label: 'Simpan',
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onSave();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showClassDialog({
    required String title,
    required TextEditingController nameController,
    required String initialLevelId,
    required ValueChanged<String> onLevelChanged,
    required VoidCallback onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var selectedLevel = initialLevelId;

        return StatefulBuilder(
          builder: (_, setDialogState) => AppDialog(
            title: title,
            content: Column(
              children: [
                AppDropdown<String>(
                  label: 'Level Pendidikan',
                  value: selectedLevel,
                  items: _levels
                      .map((level) => AppDropdownItem<String>(value: level.id, label: level.name))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedLevel = value);
                    onLevelChanged(value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nama Kelas',
                  controller: nameController,
                  hint: 'Contoh: Kelas 10',
                ),
              ],
            ),
            actions: [
              AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(dialogContext).pop()),
              AppButton.primary(
                label: 'Simpan',
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  onSave();
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSubClassDialog({
    required String title,
    required TextEditingController nameController,
    required String initialClassId,
    required ValueChanged<String> onClassChanged,
    required VoidCallback onSave,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var selectedClass = initialClassId;

        return StatefulBuilder(
          builder: (_, setDialogState) => AppDialog(
            title: title,
            content: Column(
              children: [
                AppDropdown<String>(
                  label: 'Kelas',
                  value: selectedClass,
                  items: _classes
                      .map((row) => AppDropdownItem<String>(value: row.id, label: row.name))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => selectedClass = value);
                    onClassChanged(value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nama Sub-Kelas',
                  controller: nameController,
                  hint: 'Contoh: IPA 1',
                ),
              ],
            ),
            actions: [
              AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(dialogContext).pop()),
              AppButton.primary(
                label: 'Simpan',
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  onSave();
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDependencyDialog({
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: title,
        content: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
        ),
        actions: [
          AppButton.primary(label: 'Tutup', onPressed: () => Navigator.of(dialogContext).pop()),
        ],
      ),
    );
  }

  String _findLevelName(String levelId) {
    final match = _levels.where((item) => item.id == levelId);
    return match.isEmpty ? '-' : match.first.name;
  }

  String _findClassName(String classId) {
    final match = _classes.where((item) => item.id == classId);
    return match.isEmpty ? '-' : match.first.name;
  }

  String _findLevelNameByClassId(String classId) {
    final classMatch = _classes.where((item) => item.id == classId);
    if (classMatch.isEmpty) return '-';
    return _findLevelName(classMatch.first.levelId);
  }
}
