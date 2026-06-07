import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduaccess/core/auth/auth_notifier.dart';
import 'package:eduaccess/core/auth/auth_state.dart';
import 'package:eduaccess/core/router/route_names.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import 'package:eduaccess/core/widgets/app_card.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isSiswa = user?.role == UserRole.siswa;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Absensi', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.neutral900,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: isSiswa ? _studentView(context) : _teacherView(context),
          ),
        ),
      ),
    );
  }

  Widget _studentView(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.xxl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.qr_code_scanner_rounded, size: 72, color: AppColors.primary500),
        const SizedBox(height: AppSpacing.lg),
        Text('Scan QR Kehadiran', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Arahkan kamera HP-mu ke QR code yang ditampilkan guru di layar. '
          'Pastikan kamu sudah login di browser sebelum scan.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'QR code baru diterbitkan setiap 30 detik untuk mencegah kecurangan.',
          style: AppTextStyles.label.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _teacherView(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.xxl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.co_present_rounded, size: 72, color: AppColors.primary500),
        const SizedBox(height: AppSpacing.lg),
        Text('Kelola Absensi', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Buka jadwal pelajaran yang sedang berlangsung, lalu tekan '
          '"Tampilkan QR Absensi" untuk menampilkan kode QR ke siswa.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton.primary(
          label: 'Ke Jadwal Pelajaran',
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.white),
          isFullWidth: true,
          onPressed: () => context.go(RouteNames.classSchedule),
        ),
      ],
    ),
  );
}
