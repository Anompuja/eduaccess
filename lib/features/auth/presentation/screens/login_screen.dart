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
import '../../../../core/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state — navigate on success, show error on failure
    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthStateAuthenticated) {
        context.go(RouteNames.dashboard);
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
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ───────────────────────────────────────────────────
                _Logo(),
                const SizedBox(height: AppSpacing.xxxl),

                // ── Card ───────────────────────────────────────────────────
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
                          'Masuk ke EduAccess',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Kelola sekolah Anda dengan mudah',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // ── Error banner ─────────────────────────────────
                        if (errorMessage != null) ...[
                          _ErrorBanner(message: errorMessage),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // ── Email ─────────────────────────────────────────
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

                        // ── Password ──────────────────────────────────────
                        AppTextField.password(
                          label: 'Password',
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // ── Forgot password ───────────────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: forgot password flow
                            },
                            child: Text(
                              'Lupa password?',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.primary700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Login button ──────────────────────────────────
                        AppButton.primary(
                          label: 'Masuk',
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          isFullWidth: true,
                          height: 48,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Register link ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(RouteNames.register),
                              child: Text(
                                'Daftar sekarang',
                                style: AppTextStyles.bodyMdSemiBold.copyWith(
                                  color: AppColors.primary700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ────────────────────────────────────────────────
                const SizedBox(height: AppSpacing.xl),
                Text(
                  '© 2024 EduAccess. All rights reserved.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutral500,
                  ),
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
          child: const Icon(
            Icons.school_rounded,
            color: AppColors.white,
            size: 24,
          ),
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
        color: AppColors.error.withOpacity(0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
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
