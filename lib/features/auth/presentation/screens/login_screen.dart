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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _loginAs(UserRole role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });
    await ref.read(authNotifierProvider.notifier).demoLogin(role);
    // Router redirect handles navigation once state becomes Authenticated
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AuthStateAuthenticated) context.go(RouteNames.dashboard);
    });

    final isMobile = Responsive.isMobile(context);
    final outerPad = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(outerPad),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ──────────────────────────────────────────────
                  _Logo(compact: isMobile),
                  SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),

                  // ── Demo mode card ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.xlAll,
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent500.withValues(alpha: 0.12),
                                borderRadius: AppRadius.smAll,
                              ),
                              child: Text(
                                'DEMO MODE',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accent700,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Pilih Peran',
                          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2)
                              .copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tap salah satu peran untuk masuk dan menjelajahi aplikasi.',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.neutral500),
                        ),
                        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),

                        // ── Role cards ─────────────────────────────────
                        ..._roles.map(
                          (r) => _RoleCard(
                            config: r,
                            isSelected: _selectedRole == r.role,
                            isLoading: _isLoading && _selectedRole == r.role,
                            disabled: _isLoading,
                            onTap: () => _loginAs(r.role),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '© 2025 EduAccess. All rights reserved.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role definitions ──────────────────────────────────────────────────────────
class _RoleConfig {
  final UserRole role;
  final String label;
  final String description;
  final IconData icon;
  final Color accent;

  const _RoleConfig({
    required this.role,
    required this.label,
    required this.description,
    required this.icon,
    required this.accent,
  });
}

const _roles = [
  _RoleConfig(
    role: UserRole.superadmin,
    label: 'Super Admin',
    description: 'Akses penuh ke semua sekolah & fitur',
    icon: Icons.admin_panel_settings_outlined,
    accent: AppColors.primary700,
  ),
  _RoleConfig(
    role: UserRole.adminSekolah,
    label: 'Admin Sekolah',
    description: 'Kelola data sekolah, siswa, guru & staff',
    icon: Icons.manage_accounts_outlined,
    accent: AppColors.primary500,
  ),
  _RoleConfig(
    role: UserRole.kepalaSekolah,
    label: 'Kepala Sekolah',
    description: 'Pantau statistik & laporan sekolah',
    icon: Icons.account_balance_outlined,
    accent: AppColors.info,
  ),
  _RoleConfig(
    role: UserRole.guru,
    label: 'Guru',
    description: 'Kelola absensi kelas & ujian CBT',
    icon: Icons.school_outlined,
    accent: AppColors.success,
  ),
  _RoleConfig(
    role: UserRole.siswa,
    label: 'Siswa',
    description: 'Lihat absensi & ikuti ujian CBT',
    icon: Icons.menu_book_outlined,
    accent: AppColors.accent500,
  ),
  _RoleConfig(
    role: UserRole.orangtua,
    label: 'Orang Tua',
    description: 'Pantau kehadiran & nilai ujian anak',
    icon: Icons.family_restroom_outlined,
    accent: AppColors.warning,
  ),
  _RoleConfig(
    role: UserRole.staff,
    label: 'Staff',
    description: 'Akses terbatas ke absensi harian',
    icon: Icons.badge_outlined,
    accent: AppColors.neutral500,
  ),
];

// ── Role card widget ──────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final _RoleConfig config;
  final bool isSelected;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _RoleCard({
    required this.config,
    required this.isSelected,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isSelected
            ? config.accent.withValues(alpha: 0.08)
            : AppColors.neutral50,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: isSelected
                    ? config.accent.withValues(alpha: 0.4)
                    : AppColors.neutral300,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: config.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config.icon, color: config.accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),

                // Label + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.label,
                        style: AppTextStyles.bodyMdSemiBold.copyWith(
                          color: isSelected
                              ? config.accent
                              : AppColors.neutral900,
                        ),
                      ),
                      Text(
                        config.description,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),
                // Trailing: spinner or arrow
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: config.accent,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isSelected
                        ? config.accent
                        : AppColors.neutral300,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 34.0 : 40.0;
    final textStyle = compact ? AppTextStyles.h3 : AppTextStyles.h2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.primary700,
            borderRadius: BorderRadius.circular(iconSize * 0.25),
          ),
          child: Icon(Icons.school_rounded,
              color: AppColors.white, size: iconSize * 0.6),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('EduAccess',
            style: textStyle.copyWith(color: AppColors.primary900)),
      ],
    );
  }
}
