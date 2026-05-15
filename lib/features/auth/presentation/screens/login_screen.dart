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
import '../../../../core/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).login(email, password);
    // Router redirect handles navigation once state becomes Authenticated
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AuthStateAuthenticated) context.go(RouteNames.dashboard);
      if (next is AuthStateError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
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

                  // ── Login form card ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      isMobile ? AppSpacing.lg : AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.xlAll,
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Login',
                          style:
                              (isMobile ? AppTextStyles.h3 : AppTextStyles.h2)
                                  .copyWith(color: AppColors.neutral900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Masuk dengan email dan password Anda',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                        ),

                        // ── Email field ────────────────────────────────
                        Text(
                          'Email',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'masukkan@email.com',
                            hintStyle: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral300,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.neutral300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.neutral300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.primary500,
                                width: 2,
                              ),
                            ),
                          ),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // ── Password field ─────────────────────────────
                        Text(
                          'Password',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral300,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.neutral500,
                              ),
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.neutral300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.neutral300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdAll,
                              borderSide: const BorderSide(
                                color: AppColors.primary500,
                                width: 2,
                              ),
                            ),
                          ),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                        ),

                        // ── Login button ───────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary700,
                              disabledBackgroundColor: AppColors.neutral300,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '© 2025 EduAccess. All rights reserved.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral300,
                    ),
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

// ── Logo ──────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final logoVariant = compact
        ? AppLogoVariant.textOnly
        : AppLogoVariant.logoAndText;
    final logoHeight = compact ? 40.0 : 60.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [AppLogo(variant: logoVariant, height: logoHeight)],
    );
  }
}
