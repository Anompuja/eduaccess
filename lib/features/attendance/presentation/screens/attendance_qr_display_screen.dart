import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/widgets/app_badge.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import 'package:eduaccess/features/class_schedule/presentation/providers/class_schedule_providers.dart';
import '../providers/attendance_provider.dart';

class AttendanceQrDisplayScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const AttendanceQrDisplayScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<AttendanceQrDisplayScreen> createState() => _AttendanceQrDisplayScreenState();
}

class _AttendanceQrDisplayScreenState extends ConsumerState<AttendanceQrDisplayScreen> {
  Timer? _qrTimer;
  Timer? _listTimer;
  int _countdown = 30;

  @override
  void initState() {
    super.initState();
    _startQrRefresh();
    _startListRefresh();
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _listTimer?.cancel();
    super.dispose();
  }

  void _startQrRefresh() {
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        setState(() => _countdown = 30);
        ref.invalidate(qrTokenProvider(widget.scheduleId));
      }
    });
  }

  void _startListRefresh() {
    _listTimer?.cancel();
    _listTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      ref.invalidate(attendancesProvider(widget.scheduleId));
    });
  }

  String _buildQrUrl(String token) {
    final origin = Uri.base.origin;
    return '$origin/attendance/scan?token=$token';
  }

  @override
  Widget build(BuildContext context) {
    final qrAsync = ref.watch(qrTokenProvider(widget.scheduleId));
    final attendancesAsync = ref.watch(attendancesProvider(widget.scheduleId));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('QR Absensi', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.neutral900,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR Code card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Text(
                    'Tampilkan ke siswa',
                    style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'QR code diperbarui otomatis setiap 30 detik',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  qrAsync.when(
                    loading: () => const SizedBox(
                      width: 280,
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => SizedBox(
                      width: 280,
                      height: 280,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              e.toString().replaceFirst('Exception: ', ''),
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (token) => QrImageView(
                      data: _buildQrUrl(token),
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: AppColors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Countdown indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.neutral500),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Refresh dalam $_countdown detik',
                        style: AppTextStyles.label.copyWith(color: AppColors.neutral500),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: _countdown / 30,
                          color: _countdown > 10 ? AppColors.primary500 : AppColors.warning,
                          backgroundColor: AppColors.neutral100,
                          minHeight: 6,
                          borderRadius: AppRadius.pillAll,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Attendance list
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Kehadiran Siswa', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
            ),
            const SizedBox(height: AppSpacing.md),
            attendancesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(e.toString(), style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
              ),
              data: (attendances) {
                if (attendances.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'Belum ada siswa yang hadir.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                  );
                }
                final present = attendances.where((a) => a.status == 'present' || a.status == 'late').toList();
                final absent = attendances.where((a) => a.status == 'scheduled' || a.status == 'absent').length;
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Text('${present.length} hadir', style: AppTextStyles.bodyMd.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                            const SizedBox(width: AppSpacing.lg),
                            Text('$absent belum', style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ...attendances.map((att) => ListTile(
                        dense: true,
                        title: Text(att.studentId, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900)),
                        trailing: _attendanceBadge(att.status),
                      )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceBadge(String status) => AppBadge(
    label: switch (status) {
      'present' => 'Hadir',
      'late' => 'Terlambat',
      'sick' => 'Sakit',
      'permission' => 'Izin',
      'absent' => 'Alpha',
      'scheduled' => 'Belum',
      _ => status,
    },
    status: switch (status) {
      'present' => BadgeStatus.success,
      'late' => BadgeStatus.warning,
      'sick' => BadgeStatus.warning,
      'permission' => BadgeStatus.info,
      'absent' => BadgeStatus.error,
      _ => BadgeStatus.info,
    },
  );
}
