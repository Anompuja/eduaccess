import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role ?? UserRole.staff;
    final screen = Responsive.of(context);
    final padding = screen.isMobile ? AppSpacing.lg : AppSpacing.xl;
    final blueprint = _helpBlueprintForRole(role);
    final faqs = _faqsForRole(role);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HelpBanner(
            userName: user?.name ?? 'Pengguna',
            role: role,
            blueprint: blueprint,
            onPrimaryPressed: () => context.go(blueprint.primaryRoute),
            onSupportPressed: () => _showSupportToast(context),
          ),
          SizedBox(height: padding),
          if (screen.isDesktop || screen.isTablet)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _StartHereCard(blueprint: blueprint)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: _ShortcutsCard(shortcuts: blueprint.shortcuts),
                ),
              ],
            )
          else ...[
            _StartHereCard(blueprint: blueprint),
            const SizedBox(height: AppSpacing.lg),
            _ShortcutsCard(shortcuts: blueprint.shortcuts),
          ],
          SizedBox(height: padding),
          _SupportCard(
            issueHint: blueprint.issueHint,
            onPressed: () => _showSupportToast(context),
          ),
          SizedBox(height: padding),
          _FaqCard(faqs: faqs),
        ],
      ),
    );
  }

  void _showSupportToast(BuildContext context) {
    AppToast.show(
      context,
      message:
          'Form bantuan masih simulasi UI. Integrasi ticketing akan dihubungkan saat backend support tersedia.',
      type: ToastType.info,
    );
  }
}

class _HelpBanner extends StatelessWidget {
  final String userName;
  final UserRole role;
  final _HelpBlueprint blueprint;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSupportPressed;

  const _HelpBanner({
    required this.userName,
    required this.role,
    required this.blueprint,
    required this.onPrimaryPressed,
    required this.onSupportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().isEmpty
        ? 'Pengguna'
        : userName.trim().split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary900,
        borderRadius: AppRadius.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: AppRadius.lgAll,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.white,
                ),
              ),
              AppBadge(label: role.displayName, status: BadgeStatus.active),
              _FocusChip(label: blueprint.focusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pusat Bantuan $firstName',
            style: AppTextStyles.h2.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            blueprint.subtitle,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary300),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: blueprint.supportAreas
                .map((area) => _SupportAreaChip(label: area))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppButton.primary(
                label: blueprint.primaryLabel,
                onPressed: onPrimaryPressed,
              ),
              AppButton.secondary(
                label: 'Hubungi Support',
                onPressed: onSupportPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  final String label;

  const _FocusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent100,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmSemiBold.copyWith(
          color: AppColors.accent700,
        ),
      ),
    );
  }
}

class _SupportAreaChip extends StatelessWidget {
  final String label;

  const _SupportAreaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary300),
      ),
    );
  }
}

class _StartHereCard extends StatelessWidget {
  final _HelpBlueprint blueprint;

  const _StartHereCard({required this.blueprint});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blueprint.title,
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mulai dari alur ini agar pengecekan tetap sejalan dengan modul yang sudah ada.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...blueprint.steps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final isLast = index == blueprint.steps.length;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: _StepRow(
                index: index,
                title: entry.value.$1,
                description: entry.value.$2,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String title;
  final String description;

  const _StepRow({
    required this.index,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.primary100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMdSemiBold.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutsCard extends StatelessWidget {
  final List<_HelpShortcut> shortcuts;

  const _ShortcutsCard({required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modul yang Sering Dicek',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Shortcut ke layar yang biasanya dipakai saat menelusuri kendala.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          ...shortcuts.asMap().entries.map((entry) {
            final index = entry.key;
            final shortcut = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == shortcuts.length - 1 ? 0 : AppSpacing.sm,
              ),
              child: _ShortcutTile(shortcut: shortcut, compact: compact),
            );
          }),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final _HelpShortcut shortcut;
  final bool compact;

  const _ShortcutTile({required this.shortcut, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: shortcut.backgroundColor,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: () => context.go(shortcut.route),
        borderRadius: AppRadius.lgAll,
        child: Container(
          height: compact ? 54 : 58,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(shortcut.icon, color: shortcut.foregroundColor, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.title,
                      style: AppTextStyles.bodyMdSemiBold.copyWith(
                        color: shortcut.foregroundColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      shortcut.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: shortcut.foregroundColor.withValues(alpha: 0.72),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: shortcut.foregroundColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String issueHint;
  final VoidCallback onPressed;

  const _SupportCard({required this.issueHint, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jika Masih Bermasalah',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sampaikan konteks secukupnya saja agar tim support langsung paham titik masalahnya.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SupportCheckItem(
            title: 'Pastikan role dan modul yang dibuka sudah benar',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SupportCheckItem(
            title: 'Catat waktu kejadian dan langkah terakhir sebelum error',
          ),
          const SizedBox(height: AppSpacing.sm),
          _SupportCheckItem(
            title: 'Gunakan kategori laporan: $issueHint',
            highlight: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.accent(
            label: 'Buat Tiket Bantuan',
            isFullWidth: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _SupportCheckItem extends StatelessWidget {
  final String title;
  final bool highlight;

  const _SupportCheckItem({required this.title, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = highlight ? AppColors.accent100 : AppColors.neutral50;
    final iconColor = highlight ? AppColors.accent700 : AppColors.primary700;
    final textColor = highlight ? AppColors.accent700 : AppColors.neutral700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.lgAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodySm.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final List<_HelpFaq> faqs;

  const _FaqCard({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAQ Singkat',
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Jawaban ringkas untuk pertanyaan yang paling sering muncul pada flow aplikasi saat ini.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.neutral100),
          ...faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;

            return Column(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    iconColor: AppColors.primary700,
                    collapsedIconColor: AppColors.neutral500,
                    title: Text(
                      faq.question,
                      style: AppTextStyles.bodyMdSemiBold.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    subtitle: Text(
                      faq.tag,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.answer,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != faqs.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.neutral100,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HelpBlueprint {
  final String title;
  final String subtitle;
  final String focusLabel;
  final String primaryLabel;
  final String primaryRoute;
  final String issueHint;
  final List<String> supportAreas;
  final List<(String, String)> steps;
  final List<_HelpShortcut> shortcuts;

  const _HelpBlueprint({
    required this.title,
    required this.subtitle,
    required this.focusLabel,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.issueHint,
    required this.supportAreas,
    required this.steps,
    required this.shortcuts,
  });
}

class _HelpShortcut {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HelpShortcut({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class _HelpFaq {
  final String tag;
  final String question;
  final String answer;

  const _HelpFaq({
    required this.tag,
    required this.question,
    required this.answer,
  });
}

_HelpBlueprint _helpBlueprintForRole(UserRole role) => switch (role) {
  UserRole.superadmin => const _HelpBlueprint(
    title: 'Panduan Super Admin',
    subtitle:
        'Gunakan pusat bantuan ini untuk menelusuri isu tenant, role pengguna, dan status sekolah tanpa keluar dari flow aplikasi.',
    focusLabel: 'Tenant & akses',
    primaryLabel: 'Buka Manajemen Admin',
    primaryRoute: RouteNames.admins,
    issueHint: 'Tenant dan hak akses',
    supportAreas: ['Role pengguna', 'Profil entitas', 'Konteks sekolah'],
    steps: [
      (
        'Periksa konteks sekolah aktif',
        'Pastikan tenant yang sedang dipantau sudah sesuai sebelum memeriksa modul lain.',
      ),
      (
        'Validasi lewat modul profil terkait',
        'Gunakan Manajemen Admin, Kepala Sekolah, Guru, Siswa, Staff, atau Orang Tua sesuai entitas yang bermasalah.',
      ),
      (
        'Eskalasi jika lintas modul',
        'Catat tenant, modul terdampak, dan waktu kejadian bila masalah muncul di lebih dari satu layar.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Manajemen Admin',
        subtitle: 'Cek admin dan cakupan akses',
        route: RouteNames.admins,
        icon: Icons.admin_panel_settings_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Kepala Sekolah',
        subtitle: 'Tinjau akun pimpinan sekolah',
        route: RouteNames.headmasters,
        icon: Icons.account_balance_outlined,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Subscription',
        subtitle: 'Lihat status paket sekolah',
        route: RouteNames.subscription,
        icon: Icons.workspace_premium_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.adminSekolah => const _HelpBlueprint(
    title: 'Panduan Admin Sekolah',
    subtitle:
        'Fokus bantuan diarahkan ke data master, struktur akademik, dan transaksi yang memang sudah menjadi alur utama admin sekolah.',
    focusLabel: 'Operasional sekolah',
    primaryLabel: 'Buka Data Siswa',
    primaryRoute: RouteNames.students,
    issueHint: 'Operasional sekolah',
    supportAreas: ['Data master', 'Struktur kelas', 'Billing sekolah'],
    steps: [
      (
        'Cek modul sumber masalah',
        'Mulai dari siswa, guru, staff, atau orang tua sesuai data yang sedang bermasalah.',
      ),
      (
        'Validasi struktur akademik',
        'Jika masalah terkait kelas atau mapel, cocokkan lebih dulu dengan Struktur Akademik.',
      ),
      (
        'Pisahkan isu data dan billing',
        'Gunakan Payment atau Subscription bila masalah berkaitan dengan invoice atau paket sekolah.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Manajemen Siswa',
        subtitle: 'Periksa data master siswa',
        route: RouteNames.students,
        icon: Icons.school_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Struktur Akademik',
        subtitle: 'Validasi kelas dan mapel',
        route: RouteNames.academic,
        icon: Icons.account_tree_outlined,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Payment',
        subtitle: 'Cek invoice dan pembayaran',
        route: RouteNames.payment,
        icon: Icons.receipt_long_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.kepalaSekolah => const _HelpBlueprint(
    title: 'Panduan Kepala Sekolah',
    subtitle:
        'Pusat bantuan ini menekankan pengecekan laporan, tracking siswa, dan validasi data akademik secara ringkas.',
    focusLabel: 'Monitoring akademik',
    primaryLabel: 'Buka Reports',
    primaryRoute: RouteNames.reports,
    issueHint: 'Monitoring akademik',
    supportAreas: ['Laporan', 'Tracking siswa', 'Profil sekolah'],
    steps: [
      (
        'Mulai dari ringkasan',
        'Gunakan dashboard atau reports untuk memastikan anomali memang terlihat pada data agregat.',
      ),
      (
        'Turun ke detail bila perlu',
        'Buka Tracking Siswa atau Struktur Akademik untuk memeriksa kelas, periode, atau siswa tertentu.',
      ),
      (
        'Catat konteks yang terdampak',
        'Sertakan nama kelas atau periode ajaran saat mengirim laporan ke support.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Reports',
        subtitle: 'Tinjau statistik sekolah',
        route: RouteNames.reports,
        icon: Icons.bar_chart_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Tracking Siswa',
        subtitle: 'Lacak progres dan riwayat',
        route: RouteNames.studentTracking,
        icon: Icons.timeline_outlined,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Profil Sekolah',
        subtitle: 'Periksa data sekolah aktif',
        route: RouteNames.school,
        icon: Icons.apartment_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.guru => const _HelpBlueprint(
    title: 'Panduan Guru',
    subtitle:
        'Bantuan difokuskan pada alur kelas, siswa, dan informasi operasional yang paling sering dipakai guru di aplikasi ini.',
    focusLabel: 'Kelas & pembelajaran',
    primaryLabel: 'Buka Jadwal Kelas',
    primaryRoute: RouteNames.classSchedule,
    issueHint: 'Pembelajaran dan kelas',
    supportAreas: ['Jadwal kelas', 'Data siswa', 'Notifikasi'],
    steps: [
      (
        'Periksa jadwal lebih dulu',
        'Pastikan kelas, hari, dan sesi yang dibuka memang sesuai dengan kebutuhan Anda.',
      ),
      (
        'Cocokkan data siswa',
        'Jika daftar siswa terasa tidak sesuai, bandingkan dengan modul Manajemen Siswa.',
      ),
      (
        'Laporkan dengan detail singkat',
        'Sebut kelas, tanggal, dan sesi bila masalah masih muncul setelah pengecekan awal.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Jadwal Kelas',
        subtitle: 'Pastikan sesi dan kelas benar',
        route: RouteNames.classSchedule,
        icon: Icons.calendar_month_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Manajemen Siswa',
        subtitle: 'Periksa siswa pada kelas Anda',
        route: RouteNames.students,
        icon: Icons.school_outlined,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Notifikasi',
        subtitle: 'Lihat pembaruan terbaru',
        route: RouteNames.notifications,
        icon: Icons.notifications_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.siswa => const _HelpBlueprint(
    title: 'Panduan Siswa',
    subtitle:
        'Gunakan layar ini untuk mengecek notifikasi, akses akun, dan informasi dasar saat mengalami kendala penggunaan.',
    focusLabel: 'Akses belajar',
    primaryLabel: 'Buka Notifikasi',
    primaryRoute: RouteNames.notifications,
    issueHint: 'Akses belajar',
    supportAreas: ['Notifikasi', 'Akun', 'Hak akses'],
    steps: [
      (
        'Lihat notifikasi terbaru',
        'Cek apakah ada perubahan jadwal, ujian, atau pengumuman yang memengaruhi akses Anda.',
      ),
      (
        'Periksa akun yang dipakai',
        'Pastikan Anda login dengan akun yang benar dan sesi belum berakhir.',
      ),
      (
        'Minta bantuan admin bila perlu',
        'Jika modul tertentu tetap tertutup, biasanya akses perlu diperiksa oleh admin sekolah.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Notifikasi',
        subtitle: 'Cek update kelas dan ujian',
        route: RouteNames.notifications,
        icon: Icons.notifications_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Profil',
        subtitle: 'Periksa data akun Anda',
        route: RouteNames.profile,
        icon: Icons.person_outline_rounded,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Pengaturan',
        subtitle: 'Tinjau preferensi aplikasi',
        route: RouteNames.settings,
        icon: Icons.settings_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.orangtua => const _HelpBlueprint(
    title: 'Panduan Orang Tua',
    subtitle:
        'Bantuan diarahkan ke pemantauan informasi anak, notifikasi, dan akses akun pendamping secara singkat.',
    focusLabel: 'Pendampingan',
    primaryLabel: 'Buka Dashboard',
    primaryRoute: RouteNames.dashboard,
    issueHint: 'Pendampingan orang tua',
    supportAreas: ['Dashboard anak', 'Notifikasi', 'Akun pendamping'],
    steps: [
      (
        'Mulai dari dashboard',
        'Gunakan ringkasan dashboard untuk melihat kondisi umum yang berkaitan dengan anak Anda.',
      ),
      (
        'Periksa notifikasi',
        'Lihat apakah ada update absensi, ujian, atau pengumuman yang baru masuk.',
      ),
      (
        'Konfirmasi data akun',
        'Bila data anak tidak sesuai, minta admin sekolah memeriksa koneksi akun pendamping.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Dashboard',
        subtitle: 'Pantau ringkasan aktivitas',
        route: RouteNames.dashboard,
        icon: Icons.space_dashboard_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Notifikasi',
        subtitle: 'Lihat update terbaru',
        route: RouteNames.notifications,
        icon: Icons.notifications_outlined,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Profil',
        subtitle: 'Periksa akun pendamping',
        route: RouteNames.profile,
        icon: Icons.person_outline_rounded,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
  UserRole.staff => const _HelpBlueprint(
    title: 'Panduan Staff',
    subtitle:
        'Pusat bantuan ini membantu staff meninjau akses akun, preferensi dasar, dan pesan sistem tanpa informasi berlebihan.',
    focusLabel: 'Akses internal',
    primaryLabel: 'Buka Pengaturan',
    primaryRoute: RouteNames.settings,
    issueHint: 'Akses internal',
    supportAreas: ['Pengaturan', 'Profil akun', 'Notifikasi'],
    steps: [
      (
        'Periksa pengaturan dasar',
        'Mulai dari preferensi aplikasi dan notifikasi untuk memastikan tidak ada pengaturan yang mengganggu.',
      ),
      (
        'Tinjau profil akun',
        'Pastikan data akun aktif sudah benar sebelum mengecek masalah akses lain.',
      ),
      (
        'Eskalasi jika akses tetap terbatas',
        'Minta admin sekolah memverifikasi role bila modul yang dibutuhkan tetap tidak terbuka.',
      ),
    ],
    shortcuts: [
      _HelpShortcut(
        title: 'Pengaturan',
        subtitle: 'Cek preferensi akun',
        route: RouteNames.settings,
        icon: Icons.settings_outlined,
        backgroundColor: AppColors.primary100,
        foregroundColor: AppColors.primary700,
      ),
      _HelpShortcut(
        title: 'Profil',
        subtitle: 'Tinjau data akun aktif',
        route: RouteNames.profile,
        icon: Icons.person_outline_rounded,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral700,
      ),
      _HelpShortcut(
        title: 'Notifikasi',
        subtitle: 'Lihat pesan sistem terbaru',
        route: RouteNames.notifications,
        icon: Icons.notifications_outlined,
        backgroundColor: AppColors.accent100,
        foregroundColor: AppColors.accent700,
      ),
    ],
  ),
};

List<_HelpFaq> _faqsForRole(UserRole role) {
  final common = const [
    _HelpFaq(
      tag: 'Data',
      question: 'Mengapa data di layar belum sesuai?',
      answer:
          'Periksa dulu role, modul, dan filter yang aktif. Beberapa layar di proyek ini juga masih memakai dummy data atau simulasi UI.',
    ),
    _HelpFaq(
      tag: 'Eskalasi',
      question: 'Kapan saya perlu membuat tiket bantuan?',
      answer:
          'Buat tiket jika kendala berulang, memengaruhi pekerjaan utama, atau tetap muncul setelah login ulang dan pengecekan alur dasar.',
    ),
  ];

  final roleSpecific = switch (role) {
    UserRole.superadmin || UserRole.adminSekolah => const [
      _HelpFaq(
        tag: 'Akses',
        question: 'Bagaimana memeriksa role pengguna yang salah?',
        answer:
            'Buka modul profil yang sesuai seperti Admin, Guru, Siswa, Staff, atau Orang Tua, lalu cocokkan role akun dengan akses modul yang seharusnya.',
      ),
      _HelpFaq(
        tag: 'Billing',
        question: 'Mengapa payment atau subscription belum berubah?',
        answer:
            'Subscription kini mengikuti data backend per sekolah, tetapi modul payment masih berupa simulasi UI sehingga status invoice belum selalu merefleksikan transaksi nyata.',
      ),
    ],
    UserRole.kepalaSekolah => const [
      _HelpFaq(
        tag: 'Laporan',
        question: 'Dari mana sebaiknya saya mulai mengecek anomali data?',
        answer:
            'Mulai dari reports atau dashboard. Jika anomali terlihat, baru turun ke Tracking Siswa atau Struktur Akademik untuk detailnya.',
      ),
      _HelpFaq(
        tag: 'Sekolah',
        question: 'Bagaimana jika profil sekolah belum sesuai?',
        answer:
            'Periksa dulu modul Profil Sekolah. Bila masih berbeda, laporkan field yang tidak sesuai dan konteks sekolah yang terdampak.',
      ),
    ],
    UserRole.guru => const [
      _HelpFaq(
        tag: 'Jadwal',
        question: 'Mengapa jadwal kelas tidak tampil lengkap?',
        answer:
            'Pastikan kelas, hari, dan sesi yang dibuka sudah benar. Jika masih kosong, laporkan nama kelas dan sesi yang seharusnya muncul.',
      ),
      _HelpFaq(
        tag: 'Siswa',
        question: 'Bagaimana jika daftar siswa tidak sesuai?',
        answer:
            'Bandingkan dengan Manajemen Siswa atau struktur kelas terkait. Jika masih berbeda, sertakan contoh data siswa yang hilang atau ganda.',
      ),
    ],
    UserRole.siswa || UserRole.orangtua => const [
      _HelpFaq(
        tag: 'Notifikasi',
        question: 'Mengapa notifikasi saya kosong?',
        answer:
            'Cek akun yang digunakan lebih dulu. Jika role dan akun sudah benar, kemungkinan backend notifikasi belum mengirim data untuk akun tersebut.',
      ),
      _HelpFaq(
        tag: 'Akses',
        question: 'Apa yang harus dilakukan jika modul tidak bisa dibuka?',
        answer:
            'Biasanya ini terkait pembatasan role. Catat modul yang tertolak lalu minta admin sekolah memeriksa hak akses akun Anda.',
      ),
    ],
    UserRole.staff => const [
      _HelpFaq(
        tag: 'Pengaturan',
        question: 'Mengapa perubahan preferensi belum terasa di semua layar?',
        answer:
            'Sebagian pengaturan masih lokal atau simulasi UI, jadi belum semua perubahan langsung terhubung ke seluruh modul aplikasi.',
      ),
      _HelpFaq(
        tag: 'Akses',
        question: 'Bagaimana jika saya butuh akses modul tambahan?',
        answer:
            'Role staff memiliki cakupan terbatas. Jika akses tambahan memang diperlukan, minta admin sekolah memverifikasi kebutuhan operasional Anda.',
      ),
    ],
  };

  return [...common, ...roleSpecific];
}
