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
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _emailFocus  = FocusNode();
  final _passFocus   = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AuthStateAuthenticated) context.go(RouteNames.dashboard);
    });

    final authState   = ref.watch(authNotifierProvider);
    final isLoading   = authState is AuthStateAuthenticating;
    final errorMsg    = authState is AuthStateError ? authState.message : null;
    final isMobile    = Responsive.isMobile(context);
    final cardPad     = isMobile ? AppSpacing.xl : AppSpacing.xxl;
    final outerPad    = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(outerPad),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  _Logo(compact: isMobile),
                  SizedBox(height: isMobile ? AppSpacing.xxl : AppSpacing.xxxl),

                  // Card
                  Container(
                    padding: EdgeInsets.all(cardPad),
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
                          Text('Masuk ke EduAccess',
                              style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2)
                                  .copyWith(color: AppColors.neutral900)),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Kelola sekolah Anda dengan mudah',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.neutral500)),
                          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xxl),

                          // Error banner
                          if (errorMsg != null) ...[
                            _ErrorBanner(message: errorMsg),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // Email
                          AppTextField(
                            label: 'Email',
                            hint: 'contoh@sekolah.id',
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                            onSubmitted: (_) => _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Password
                          AppTextField.password(
                            label: 'Password',
                            controller: _passCtrl,
                            focusNode: _passFocus,
                            textInputAction: TextInputAction.done,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Lupa password?',
                                  style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.primary700,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Login button
                          AppButton.primary(
                            label: 'Masuk',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            isFullWidth: true,
                            height: 48,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Belum punya akun? ',
                                  style: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.neutral500)),
                              GestureDetector(
                                onTap: () => context.push(RouteNames.register),
                                child: Text('Daftar sekarang',
                                    style: AppTextStyles.bodyMdSemiBold
                                        .copyWith(color: AppColors.primary700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Text('© 2024 EduAccess. All rights reserved.',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize  = compact ? 34.0 : 40.0;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
