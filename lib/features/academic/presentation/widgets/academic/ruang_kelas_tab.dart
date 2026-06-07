import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/utils/responsive.dart';
import 'package:eduaccess/core/widgets/app_badge.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import 'package:eduaccess/core/widgets/app_dialog.dart';
import 'package:eduaccess/core/widgets/app_dropdown.dart';
import 'package:eduaccess/core/widgets/app_text_field.dart';
import 'package:eduaccess/core/api/api_client.dart';
import 'package:eduaccess/core/widgets/app_refresh_button.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/features/academic/domain/entities/classroom_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/class_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/sub_class_entity.dart';
import 'package:eduaccess/features/academic/domain/entities/academic_year_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

const _roomTypes = [
  AppDropdownItem(value: 'classroom', label: 'Ruang Kelas'),
  AppDropdownItem(value: 'lab', label: 'Laboratorium'),
  AppDropdownItem(value: 'hall', label: 'Aula'),
  AppDropdownItem(value: 'other', label: 'Lainnya'),
];

const _statusItems = [
  AppDropdownItem(value: 'available', label: 'Tersedia'),
  AppDropdownItem(value: 'occupied', label: 'Terpakai'),
  AppDropdownItem(value: 'maintenance', label: 'Pemeliharaan'),
  AppDropdownItem(value: 'unknown', label: 'Tidak Diketahui'),
];

// ── Dialog result ────────────────────────────────────────────────────────────

class _ClassroomFormResult {
  final String name;
  final int capacity;
  final String floor;
  final String building;
  final String roomType;
  final String status;
  final String facilities;
  final String? classId;
  final String? subClassId;
  final String? academicYearId;
  final String? homeroomTeacherId;
  final String? schoolId;

  const _ClassroomFormResult({
    required this.name,
    required this.capacity,
    required this.floor,
    required this.building,
    required this.roomType,
    required this.status,
    required this.facilities,
    this.classId,
    this.subClassId,
    this.academicYearId,
    this.homeroomTeacherId,
    this.schoolId,
  });
}

// ── Dialog form body ─────────────────────────────────────────────────────────

class _ClassroomFormBody extends ConsumerStatefulWidget {
  final ClassroomEntity? existing;
  final bool needsSchoolPicker;
  final List<DashboardSchool> allSchools;
  final String? initialSchoolId;

  const _ClassroomFormBody({
    super.key,
    this.existing,
    required this.needsSchoolPicker,
    required this.allSchools,
    this.initialSchoolId,
  });

  @override
  ConsumerState<_ClassroomFormBody> createState() => _ClassroomFormBodyState();
}

class _ClassroomFormBodyState extends ConsumerState<_ClassroomFormBody> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _floorCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _facilitiesCtrl;

  String _roomType = 'classroom';
  String _status = 'available';
  String? _schoolId;
  String? _classId;
  String? _subClassId;
  String? _academicYearId;
  String? _homeroomTeacherId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _capacityCtrl = TextEditingController(text: e != null ? '${e.capacity}' : '');
    _floorCtrl = TextEditingController(text: e?.floor ?? '');
    _buildingCtrl = TextEditingController(text: e?.building ?? '');
    _facilitiesCtrl = TextEditingController(text: e?.facilities ?? '');
    _schoolId = widget.initialSchoolId;

    if (e != null) {
      _roomType = _roomTypes.any((t) => t.value == e.roomType) ? e.roomType : 'classroom';
      _status = _statusItems.any((s) => s.value == e.status) ? e.status : 'available';
      _classId = e.classId;
      _subClassId = e.subClassId;
      _academicYearId = e.academicYearId;
      _homeroomTeacherId = e.homeroomTeacherId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _floorCtrl.dispose();
    _buildingCtrl.dispose();
    _facilitiesCtrl.dispose();
    super.dispose();
  }

  List<SubClassEntity> _filteredSubClasses(List<SubClassEntity> all) {
    if (_classId == null || _classId!.isEmpty) return [];
    return all.where((s) => s.classId == _classId).toList();
  }

  void submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    if (widget.needsSchoolPicker && _schoolId == null) return;
    Navigator.of(context).pop(_ClassroomFormResult(
      name: name,
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 0,
      floor: _floorCtrl.text.trim(),
      building: _buildingCtrl.text.trim(),
      roomType: _roomType,
      status: _status,
      facilities: _facilitiesCtrl.text.trim(),
      classId: _classId,
      subClassId: _subClassId,
      academicYearId: _academicYearId,
      homeroomTeacherId: _homeroomTeacherId,
      schoolId: _schoolId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(classesProvider).valueOrNull ?? <ClassEntity>[];
    final allSubClasses = ref.watch(subClassesProvider).valueOrNull ?? <SubClassEntity>[];
    final years = ref.watch(academicYearsProvider).valueOrNull ?? <AcademicYearEntity>[];
    final teachers = ref.watch(teachersForDropdownProvider).valueOrNull ?? [];

    final subClasses = _filteredSubClasses(allSubClasses);

    // Clear sub-class if it's no longer in the filtered list
    if (_subClassId != null && subClasses.every((s) => s.id != _subClassId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _subClassId = null);
      });
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (widget.needsSchoolPicker) ...[
        AppDropdown<String?>(
          label: 'Sekolah',
          hint: 'Pilih sekolah',
          value: _schoolId,
          items: [
            const AppDropdownItem<String?>(value: null, label: 'Pilih sekolah'),
            ...widget.allSchools
                .map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)),
          ],
          onChanged: (v) => setState(() => _schoolId = v),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
      AppTextField(label: 'Nama Ruang', controller: _nameCtrl, hint: 'Contoh: Ruang A1'),
      const SizedBox(height: AppSpacing.md),
      AppDropdown<String>(
        label: 'Tipe Ruang',
        value: _roomType,
        items: _roomTypes,
        onChanged: (v) { if (v != null) setState(() => _roomType = v); },
      ),
      const SizedBox(height: AppSpacing.md),
      AppDropdown<String>(
        label: 'Status',
        value: _status,
        items: _statusItems,
        onChanged: (v) { if (v != null) setState(() => _status = v); },
      ),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        Expanded(child: AppTextField(
          label: 'Kapasitas',
          controller: _capacityCtrl,
          hint: '30',
          keyboardType: TextInputType.number,
        )),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppTextField(label: 'Lantai', controller: _floorCtrl, hint: '1')),
      ]),
      const SizedBox(height: AppSpacing.md),
      AppTextField(label: 'Gedung', controller: _buildingCtrl, hint: 'Gedung Utama'),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Fasilitas',
        controller: _facilitiesCtrl,
        hint: 'Proyektor, AC, Whiteboard',
      ),
      const SizedBox(height: AppSpacing.md),
      // Kelas dropdown
      AppDropdown<String?>(
        label: 'Kelas (opsional)',
        hint: classes.isEmpty ? 'Belum ada data kelas' : 'Pilih kelas',
        value: classes.any((c) => c.id == _classId) ? _classId : null,
        items: [
          const AppDropdownItem<String?>(value: null, label: 'Tidak dipilih'),
          ...classes.map((c) => AppDropdownItem<String?>(value: c.id, label: c.name)),
        ],
        onChanged: (v) => setState(() {
          _classId = v;
          _subClassId = null;
        }),
      ),
      const SizedBox(height: AppSpacing.md),
      // Sub-kelas — only enabled and populated after a class is picked
      AppDropdown<String?>(
        label: 'Sub-kelas (opsional)',
        hint: _classId == null
            ? 'Pilih kelas terlebih dahulu'
            : subClasses.isEmpty
                ? 'Tidak ada sub-kelas untuk kelas ini'
                : 'Pilih sub-kelas',
        value: subClasses.any((s) => s.id == _subClassId) ? _subClassId : null,
        items: [
          const AppDropdownItem<String?>(value: null, label: 'Tidak dipilih'),
          ...subClasses.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)),
        ],
        onChanged: _classId == null ? null : (v) => setState(() => _subClassId = v),
      ),
      const SizedBox(height: AppSpacing.md),
      // Tahun Ajaran
      AppDropdown<String?>(
        label: 'Tahun Ajaran (opsional)',
        hint: years.isEmpty ? 'Belum ada tahun ajaran' : 'Pilih tahun ajaran',
        value: years.any((y) => y.id == _academicYearId) ? _academicYearId : null,
        items: [
          const AppDropdownItem<String?>(value: null, label: 'Tidak dipilih'),
          ...years.map((y) => AppDropdownItem<String?>(
            value: y.id,
            label: y.isActive ? '${y.name} (aktif)' : y.name,
          )),
        ],
        onChanged: (v) => setState(() => _academicYearId = v),
      ),
      const SizedBox(height: AppSpacing.md),
      // Wali kelas — value = userId (auth.users UUID), NOT teacherId
      AppDropdown<String?>(
        label: 'Wali Kelas (opsional)',
        hint: teachers.isEmpty ? 'Belum ada data guru' : 'Pilih wali kelas',
        value: teachers.any((t) => t.userId == _homeroomTeacherId) ? _homeroomTeacherId : null,
        items: [
          const AppDropdownItem<String?>(value: null, label: 'Tidak dipilih'),
          ...teachers.map((t) => AppDropdownItem<String?>(value: t.userId, label: t.name)),
        ],
        onChanged: (v) => setState(() => _homeroomTeacherId = v),
      ),
    ]);
  }
}

// ── Main Tab ─────────────────────────────────────────────────────────────────

class RuangKelasTab extends ConsumerStatefulWidget {
  const RuangKelasTab({super.key});

  @override
  ConsumerState<RuangKelasTab> createState() => _RuangKelasTabState();
}

class _RuangKelasTabState extends ConsumerState<RuangKelasTab> {
  bool _isSubmitting = false;

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    final activeSchool = ref.read(activeSchoolProvider);
    final isSuperadmin = user?.role == UserRole.superadmin;
    final needsSchoolPicker = isSuperadmin && activeSchool == null;
    final allSchools = needsSchoolPicker
        ? (ref.read(dashboardSchoolsProvider).valueOrNull ?? [])
        : <DashboardSchool>[];

    final formKey = GlobalKey<_ClassroomFormBodyState>();
    final result = await showDialog<_ClassroomFormResult>(
      context: context,
      builder: (dialogCtx) => _buildDialog(
        dialogCtx: dialogCtx,
        title: 'Tambah Ruang Kelas',
        formKey: formKey,
        existing: null,
        needsSchoolPicker: needsSchoolPicker,
        allSchools: allSchools,
        initialSchoolId: activeSchool?.id,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createClassroom(
        result.name, result.capacity, result.floor,
        result.building, result.roomType, result.facilities,
        classId: result.classId,
        subClassId: result.subClassId,
        academicYearId: result.academicYearId,
        homeroomTeacherId: result.homeroomTeacherId,
        schoolId: isSuperadmin ? result.schoolId : null,
      );
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(ClassroomEntity room) async {
    final formKey = GlobalKey<_ClassroomFormBodyState>();
    final result = await showDialog<_ClassroomFormResult>(
      context: context,
      builder: (dialogCtx) => _buildDialog(
        dialogCtx: dialogCtx,
        title: 'Edit Ruang Kelas',
        formKey: formKey,
        existing: room,
        needsSchoolPicker: false,
        allSchools: const [],
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateClassroom(
        room.id, result.name, result.capacity, result.floor,
        result.building, result.roomType, result.facilities,
        status: result.status,
        classId: result.classId,
        subClassId: result.subClassId,
        academicYearId: result.academicYearId,
        homeroomTeacherId: result.homeroomTeacherId,
      );
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildDialog({
    required BuildContext dialogCtx,
    required String title,
    required GlobalKey<_ClassroomFormBodyState> formKey,
    required ClassroomEntity? existing,
    required bool needsSchoolPicker,
    required List<DashboardSchool> allSchools,
    String? initialSchoolId,
  }) {
    return AppDialog(
      title: title,
      content: _ClassroomFormBody(
        key: formKey,
        existing: existing,
        needsSchoolPicker: needsSchoolPicker,
        allSchools: allSchools,
        initialSchoolId: initialSchoolId,
      ),
      actions: [
        AppButton.secondary(
          label: 'Batal',
          onPressed: () => Navigator.of(dialogCtx).pop(),
        ),
        AppButton.primary(
          label: 'Simpan',
          onPressed: () => formKey.currentState?.submit(),
        ),
      ],
    );
  }

  Future<void> _delete(ClassroomEntity room) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Hapus Ruang Kelas',
      message: 'Ruang "${room.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      isDanger: true,
    );
    if (confirmed != true) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).deleteClassroom(room.id);
      await ref.read(cacheStoreProvider).clean();
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  BadgeStatus _badgeForStatus(String status) => switch (status) {
    'available' => BadgeStatus.success,
    'occupied' => BadgeStatus.warning,
    'maintenance' => BadgeStatus.error,
    _ => BadgeStatus.muted,
  };

  String _labelForStatus(String status) => switch (status) {
    'available' => 'Tersedia',
    'occupied' => 'Terpakai',
    'maintenance' => 'Pemeliharaan',
    'unknown' => 'Tidak Diketahui',
    _ => status,
  };

  String _labelForRoomType(String type) => switch (type) {
    'classroom' => 'Kelas',
    'lab' => 'Lab',
    'hall' => 'Aula',
    _ => type,
  };

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(classroomsProvider);
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          AppRefreshButton(
            onRefresh: () async {
              await ref.read(cacheStoreProvider).clean();
              ref.invalidate(classroomsProvider);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton.accent(
            label: 'Tambah Ruang',
            prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
            onPressed: _isSubmitting ? null : _create,
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(
            child: Text(e.toString(),
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
          ),
          data: (rooms) => AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(builder: (context, constraints) =>
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: AppColors.neutral100),
                    child: DataTable(
                      columnSpacing: isCompact ? 12 : 24,
                      horizontalMargin: AppSpacing.md,
                      headingRowHeight: isCompact ? 42 : 48,
                      dataRowMinHeight: isCompact ? 50 : 54,
                      dataRowMaxHeight: isCompact ? 50 : 54,
                      headingTextStyle: AppTextStyles.label.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w700),
                      dataTextStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w500),
                      columns: const [
                        DataColumn(label: SizedBox(width: 48, child: Text('No'))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Nama Ruang'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Tipe'))),
                        DataColumn(label: SizedBox(width: 90, child: Text('Kapasitas'))),
                        DataColumn(label: SizedBox(width: 80, child: Text('Lantai'))),
                        DataColumn(label: SizedBox(width: 130, child: Text('Gedung'))),
                        DataColumn(label: SizedBox(width: 110, child: Text('Status'))),
                        DataColumn(label: SizedBox(width: 100, child: Text('Aksi'))),
                      ],
                      rows: rooms.asMap().entries.map((entry) {
                        final i = entry.key;
                        final r = entry.value;
                        return DataRow(cells: [
                          DataCell(SizedBox(width: 48, child: Text('${i + 1}'))),
                          DataCell(SizedBox(width: 160,
                            child: Text(r.name, overflow: TextOverflow.ellipsis))),
                          DataCell(SizedBox(width: 100,
                            child: Text(_labelForRoomType(r.roomType)))),
                          DataCell(SizedBox(width: 90,
                            child: Text('${r.capacity} org'))),
                          DataCell(SizedBox(width: 80,
                            child: Text(r.floor.isEmpty ? '-' : 'Lt. ${r.floor}'))),
                          DataCell(SizedBox(width: 130,
                            child: Text(r.building, overflow: TextOverflow.ellipsis))),
                          DataCell(Align(
                            alignment: Alignment.centerLeft,
                            child: AppBadge(
                              label: _labelForStatus(r.status),
                              status: _badgeForStatus(r.status),
                            ),
                          )),
                          DataCell(SizedBox(width: 100, child: Row(children: [
                            _actionBtn(Icons.edit_outlined, AppColors.warning,
                              () => _edit(r)),
                            const SizedBox(width: AppSpacing.sm),
                            _actionBtn(Icons.delete_outline_rounded, AppColors.error,
                              () => _delete(r)),
                          ]))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 34, height: 34,
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
