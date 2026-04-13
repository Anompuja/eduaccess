import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';

// ── Role options ──────────────────────────────────────────────────────────────
final _roleItems = [
  AppDropdownItem(value: 'admin_sekolah',  label: 'Admin Sekolah'),
  AppDropdownItem(value: 'kepala_sekolah', label: 'Kepala Sekolah'),
  AppDropdownItem(value: 'guru',           label: 'Guru'),
  AppDropdownItem(value: 'staff',          label: 'Staff'),
  AppDropdownItem(value: 'orangtua',       label: 'Orang Tua'),
  AppDropdownItem(value: 'siswa',          label: 'Siswa'),
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  final _nameFocus     = FocusNode();
  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus  = FocusNode();

  String? _selectedRole;
  bool _registrationSuccess = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole!,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (prev, next) {
      // After successful register the notifier goes Unauthenticated
      if (prev is AuthStateAuthenticating &&
          next is AuthStateUnauthenticated) {
        setState(() => _registrationSuccess = true);
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthStateAuthenticating;
    final errorMessage =
        authState is AuthStateError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──────────────────────────────────────────────────
                _Logo(),
                const SizedBox(height: AppSpacing.xxl),

                // ── Success state ─────────────────────────────────────────
                if (_registrationSuccess)
                  _SuccessBanner(onLogin: () => context.go(RouteNames.login))
                else
                  // ── Form card ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.xlAll,
                      boxShadow: AppShadows.card,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Akun EduAccess',
                            style: AppTextStyles.h2.copyWith(
                                color: AppColors.neutral900),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Isi data di bawah untuk mendaftar',
                            style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral500),
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          // ── Error banner ───────────────────────────────
                          if (errorMessage != null) ...[
                            _ErrorBanner(message: errorMessage),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // ── Name ───────────────────────────────────────
                          AppTextField(
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline,
                            validator: Validators.name,
                            onSubmitted: (_) =>
                                _emailFocus.requestFocus(),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Email ──────────────────────────────────────
                          AppTextField(
                            label: 'Email',
                            hint: 'contoh@sekolah.id',
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                            onSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Role ───────────────────────────────────────
                          AppDropdown<String>(
                            label: 'Role',
                            hint: 'Pilih role akun Anda',
                            value: _selectedRole,
                            items: _roleItems,
                            validator: (v) =>
                                Validators.requiredDropdown(v,
                                    fieldName: 'Role'),
                            onChanged: (v) =>
                                setState(() => _selectedRole = v),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Password ───────────────────────────────────
                          AppTextField.password(
                            label: 'Password',
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Confirm password ───────────────────────────
                          AppTextField.password(
                            label: 'Konfirmasi Password',
                            controller: _confirmCtrl,
                            focusNode: _confirmFocus,
                            textInputAction: TextInputAction.done,
                            validator: (v) => Validators.confirmPassword(
                                v, _passwordCtrl.text),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Submit ─────────────────────────────────────
                          AppButton.primary(
                            label: 'Daftar',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            isFullWidth: true,
                            height: 48,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Login link ─────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.neutral500),
                              ),
                              GestureDetector(
                                onTap: () => context.go(RouteNames.login),
                                child: Text(
                                  'Masuk',
                                  style: AppTextStyles.bodyMdSemiBold
                                      .copyWith(color: AppColors.primary700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl),
                Text(
                  '© 2024 EduAccess. All rights reserved.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded,
              color: AppColors.white, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'EduAccess',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary900),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final VoidCallback onLogin;
  const _SuccessBanner({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.primary700, size: 36),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pendaftaran Berhasil!',
            style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Akun Anda telah dibuat. Silakan masuk untuk melanjutkan.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: 'Masuk Sekarang',
            onPressed: onLogin,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
