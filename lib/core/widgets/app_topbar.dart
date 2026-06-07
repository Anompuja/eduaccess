import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../providers/active_school_provider.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

typedef _PageInfo = ({String title, String subtitle});

_PageInfo _infoForRoute(String location) => switch (location) {
  String l when l.startsWith(RouteNames.dashboard) => (
    title: 'Dashboard',
    subtitle: 'Selamat datang di EduAccess',
  ),
  String l when l.startsWith(RouteNames.students) => (
    title: 'Manajemen Siswa',
    subtitle: 'Kelola data siswa sekolah',
  ),
  String l when l.startsWith(RouteNames.teachers) => (
    title: 'Manajemen Guru',
    subtitle: 'Kelola data guru sekolah',
  ),
  String l when l.startsWith(RouteNames.headmasters) => (
    title: 'Manajemen Kepala Sekolah',
    subtitle: 'Kelola data kepala sekolah per tenant',
  ),
  String l when l.startsWith(RouteNames.staff) => (
    title: 'Manajemen Staff',
    subtitle: 'Kelola data staf sekolah',
  ),
  String l when l.startsWith(RouteNames.parents) => (
    title: 'Orang Tua',
    subtitle: 'Kelola data wali murid',
  ),
  String l when l.startsWith(RouteNames.academic) => (
    title: 'Struktur Akademik',
    subtitle: 'Tahun ajaran, kelas & mata pelajaran',
  ),
  String l when l.startsWith(RouteNames.gradePromotion) => (
    title: 'Naik Kelas',
    subtitle: 'Proses kenaikan kelas siswa',
  ),
  String l when l.startsWith(RouteNames.studentTracking) => (
    title: 'Tracking Siswa',
    subtitle: 'Riwayat akademik dan progres siswa',
  ),
  String l when l.startsWith(RouteNames.school) => (
    title: 'Profil Sekolah',
    subtitle: 'Informasi sekolah dan aturan operasional',
  ),
  String l when l.startsWith(RouteNames.cbt) => (
    title: 'CBT / Ujian',
    subtitle: 'Buat dan kelola ujian online',
  ),
  String l when l.startsWith(RouteNames.attendance) => (
    title: 'Absensi',
    subtitle: 'Rekap kehadiran harian',
  ),
  String l when l.startsWith(RouteNames.subscription) => (
    title: 'Subscription',
    subtitle: 'Kelola paket langganan sekolah',
  ),
  String l when l.startsWith(RouteNames.payment) => (
    title: 'Payment',
    subtitle: 'Riwayat pembayaran dan status invoice',
  ),
  String l when l.startsWith(RouteNames.reports) => (
    title: 'Reports',
    subtitle: 'Ringkasan statistik dan export laporan',
  ),
  String l when l.startsWith(RouteNames.help) => (
    title: 'Bantuan',
    subtitle: 'Panduan penggunaan dan kanal support',
  ),
  String l when l.startsWith(RouteNames.settings) => (
    title: 'Pengaturan',
    subtitle: 'Preferensi aplikasi',
  ),
  String l when l.startsWith(RouteNames.profile) => (
    title: 'Profil',
    subtitle: 'Informasi akun Anda',
  ),
  _ => (title: 'EduAccess', subtitle: ''),
};

class AppTopbar extends ConsumerWidget {
  final String? titleOverride;
  final VoidCallback? onMenuPressed;
  final bool isMobile;
  final bool inAppBar;

  const AppTopbar({
    super.key,
    this.titleOverride,
    this.onMenuPressed,
    this.isMobile = false,
    this.inAppBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final info = titleOverride != null
        ? (title: titleOverride!, subtitle: '')
        : _infoForRoute(location);
    final user = ref.watch(currentUserProvider);
    final initials = _initials(user?.name ?? '');
    final contentHeight = isMobile ? 64.0 : 72.0;
    final topInset = inAppBar ? 0.0 : MediaQuery.paddingOf(context).top;

    final row = Row(
      children: [
        if (onMenuPressed != null) ...[
          IconButton(
            onPressed: onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.neutral700,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title,
                style: (isMobile ? AppTextStyles.h4 : AppTextStyles.h3)
                    .copyWith(color: AppColors.neutral900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isMobile && info.subtitle.isNotEmpty)
                Text(
                  info.subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (!isMobile) const _SchoolContextChip(),
        SizedBox(width: isMobile ? AppSpacing.xs : AppSpacing.md),
        GestureDetector(
          onTap: () => context.push(RouteNames.profile),
          child: CircleAvatar(
            radius: isMobile ? 16 : 18,
            backgroundColor: AppColors.primary500,
            child: Text(
              initials,
              style: AppTextStyles.label.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ),
        ),
      ],
    );

    return Container(
      height: contentHeight + topInset,
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.topbar,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: inAppBar ? row : SafeArea(bottom: false, child: row),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _SchoolContextChip extends ConsumerWidget {
  const _SchoolContextChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeSchool = ref.watch(activeSchoolProvider);

    if (user?.role != UserRole.superadmin) {
      return const SizedBox.shrink();
    }

    final isMissing = activeSchool == null;
    final backgroundColor = isMissing
        ? AppColors.accent100
        : AppColors.primary100;
    final textColor = isMissing ? AppColors.accent700 : AppColors.primary700;
    final label = isMissing ? 'Pilih Sekolah' : activeSchool.name;

    return GestureDetector(
      onTap: isMissing ? () => context.push(RouteNames.dashboard) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 16, color: textColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
