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
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/providers/active_school_provider.dart';
import 'package:eduaccess/features/academic/domain/entities/classroom_entity.dart';
import 'package:eduaccess/features/academic/presentation/providers/academic_providers.dart';
import 'package:eduaccess/features/dashboard/domain/entities/dashboard_school.dart';
import 'package:eduaccess/features/dashboard/presentation/providers/dashboard_provider.dart';

const _roomTypes = [
  AppDropdownItem(value: 'classroom', label: 'Ruang Kelas'),
  AppDropdownItem(value: 'lab', label: 'Laboratorium'),
  AppDropdownItem(value: 'hall', label: 'Aula'),
  AppDropdownItem(value: 'other', label: 'Lainnya'),
];

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
    String? dialogSchoolId = activeSchool?.id;
    final nameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    final floorCtrl = TextEditingController();
    final buildingCtrl = TextEditingController();
    final facilitiesCtrl = TextEditingController();
    var selectedType = 'classroom';
    ({String name, int capacity, int floor, String building, String type, String facilities, String? schoolId})? result;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Tambah Ruang Kelas',
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (needsSchoolPicker) ...[
              AppDropdown<String?>(
                label: 'Sekolah',
                hint: 'Pilih sekolah',
                value: dialogSchoolId,
                items: allSchools.map((s) => AppDropdownItem<String?>(value: s.id, label: s.name)).toList(),
                onChanged: (v) => setD(() => dialogSchoolId = v),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppTextField(label: 'Nama Ruang', controller: nameCtrl, hint: 'Contoh: Ruang A1'),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: 'Tipe Ruang',
              value: selectedType,
              items: _roomTypes,
              onChanged: (v) { if (v != null) setD(() => selectedType = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: AppTextField(label: 'Kapasitas', controller: capacityCtrl, hint: '30', keyboardType: TextInputType.number)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: AppTextField(label: 'Lantai', controller: floorCtrl, hint: '1', keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Gedung', controller: buildingCtrl, hint: 'Gedung Utama'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Fasilitas', controller: facilitiesCtrl, hint: 'Proyektor, AC, Whiteboard'),
          ])),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              final capacity = int.tryParse(capacityCtrl.text.trim()) ?? 0;
              final floor = int.tryParse(floorCtrl.text.trim()) ?? 1;
              if (name.isEmpty) return;
              if (needsSchoolPicker && dialogSchoolId == null) return;
              result = (
                name: name, capacity: capacity, floor: floor,
                building: buildingCtrl.text.trim(), type: selectedType,
                facilities: facilitiesCtrl.text.trim(),
                schoolId: isSuperadmin ? dialogSchoolId : null,
              );
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    nameCtrl.dispose(); capacityCtrl.dispose(); floorCtrl.dispose();
    buildingCtrl.dispose(); facilitiesCtrl.dispose();

    final r = result;
    if (r == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).createClassroom(
        r.name, r.capacity, r.floor, r.building, r.type, r.facilities, schoolId: r.schoolId);
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _edit(ClassroomEntity room) async {
    final nameCtrl = TextEditingController(text: room.name);
    final capacityCtrl = TextEditingController(text: room.capacity.toString());
    final floorCtrl = TextEditingController(text: room.floor.toString());
    final buildingCtrl = TextEditingController(text: room.building);
    final facilitiesCtrl = TextEditingController(text: room.facilities);
    final typeValue = _roomTypes.any((t) => t.value == room.roomType) ? room.roomType : 'classroom';
    var selectedType = typeValue;
    ({String name, int capacity, int floor, String building, String type, String facilities})? result;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setD) => AppDialog(
          title: 'Edit Ruang Kelas',
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            AppTextField(label: 'Nama Ruang', controller: nameCtrl, hint: 'Contoh: Ruang A1'),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: 'Tipe Ruang',
              value: selectedType,
              items: _roomTypes,
              onChanged: (v) { if (v != null) setD(() => selectedType = v); },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: AppTextField(label: 'Kapasitas', controller: capacityCtrl, hint: '30', keyboardType: TextInputType.number)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: AppTextField(label: 'Lantai', controller: floorCtrl, hint: '1', keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Gedung', controller: buildingCtrl, hint: 'Gedung Utama'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Fasilitas', controller: facilitiesCtrl, hint: 'Proyektor, AC, Whiteboard'),
          ])),
          actions: [
            AppButton.secondary(label: 'Batal', onPressed: () => Navigator.of(ctx).pop()),
            AppButton.primary(label: 'Simpan', onPressed: () {
              final name = nameCtrl.text.trim();
              final capacity = int.tryParse(capacityCtrl.text.trim()) ?? 0;
              final floor = int.tryParse(floorCtrl.text.trim()) ?? 1;
              if (name.isEmpty) return;
              result = (
                name: name, capacity: capacity, floor: floor,
                building: buildingCtrl.text.trim(), type: selectedType,
                facilities: facilitiesCtrl.text.trim(),
              );
              Navigator.of(ctx).pop();
            }),
          ],
        ),
      ),
    );
    nameCtrl.dispose(); capacityCtrl.dispose(); floorCtrl.dispose();
    buildingCtrl.dispose(); facilitiesCtrl.dispose();

    final r = result;
    if (r == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(academicRepositoryProvider).updateClassroom(
        room.id, r.name, r.capacity, r.floor, r.building, r.type, r.facilities);
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
      ref.invalidate(classroomsProvider);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  BadgeStatus _statusBadge(String status) => switch (status) {
    'available' => BadgeStatus.success,
    'occupied' => BadgeStatus.warning,
    'maintenance' => BadgeStatus.error,
    _ => BadgeStatus.muted,
  };

  String _statusLabel(String status) => switch (status) {
    'available' => 'Tersedia',
    'occupied' => 'Terpakai',
    'maintenance' => 'Pemeliharaan',
    _ => status,
  };

  String _roomTypeLabel(String type) => switch (type) {
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
        Align(
          alignment: Alignment.centerRight,
          child: AppButton.accent(
            label: 'Tambah Ruang',
            prefixIcon: const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
            onPressed: _isSubmitting ? null : _create,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        asyncData.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
          data: (rooms) => AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                  child: DataTable(
                    columnSpacing: isCompact ? 12 : 24,
                    horizontalMargin: AppSpacing.md,
                    headingRowHeight: isCompact ? 42 : 48,
                    dataRowMinHeight: isCompact ? 50 : 54,
                    dataRowMaxHeight: isCompact ? 50 : 54,
                    headingTextStyle: AppTextStyles.label.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w700),
                    dataTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w500),
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
                        DataCell(SizedBox(width: 160, child: Text(r.name, overflow: TextOverflow.ellipsis))),
                        DataCell(SizedBox(width: 100, child: Text(_roomTypeLabel(r.roomType)))),
                        DataCell(SizedBox(width: 90, child: Text('${r.capacity} orang'))),
                        DataCell(SizedBox(width: 80, child: Text('Lt. ${r.floor}'))),
                        DataCell(SizedBox(width: 130, child: Text(r.building, overflow: TextOverflow.ellipsis))),
                        DataCell(Align(alignment: Alignment.centerLeft, child: AppBadge(label: _statusLabel(r.status), status: _statusBadge(r.status)))),
                        DataCell(SizedBox(width: 100, child: Row(children: [
                          _actionBtn(Icons.edit_outlined, AppColors.warning, () => _edit(r)),
                          const SizedBox(width: AppSpacing.sm),
                          _actionBtn(Icons.delete_outline_rounded, AppColors.error, () => _delete(r)),
                        ]))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => SizedBox(
    width: 34, height: 34,
    child: Material(
      color: color, borderRadius: AppRadius.mdAll,
      child: InkWell(borderRadius: AppRadius.mdAll, onTap: onTap, child: Icon(icon, color: AppColors.white, size: 18)),
    ),
  );
}
