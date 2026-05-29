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

/// Default password seeded for every quick-login test account.
const _devPassword = 'Test1234!';

/// Quick-login test accounts, one per role. The backend test accounts must be
/// created with these exact emails for the buttons to authenticate.
const _devAccounts = <_DevAccount>[
  _DevAccount('Admin Sekolah', 'admin.sekolah@test.eduaccess.id'),
  _DevAccount('Kepala Sekolah', 'kepala.sekolah@test.eduaccess.id'),
  _DevAccount('Guru', 'guru@test.eduaccess.id'),
  _DevAccount('Staff', 'staff@test.eduaccess.id'),
  _DevAccount('Orang Tua', 'orangtua@test.eduaccess.id'),
  _DevAccount('Siswa', 'siswa@test.eduaccess.id'),
];

class _DevAccount {
  final String label;
  final String email;
  const _DevAccount(this.label, this.email);
}

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
  int _tab = 0; // 0 = Login, 1 = Develop

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
    await _login(email, password);
  }

  Future<void> _login(String email, String password) async {
    setState(() => _isLoading = true);
    await ref.read(authNotifierProvider.notifier).login(email, password);
    // Router redirect handles navigation once state becomes Authenticated.
    if (mounted) setState(() => _isLoading = false);
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
                  _Logo(compact: isMobile),
                  SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
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
                        _tabSwitcher(),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                        ),
                        if (_tab == 0)
                          _loginForm(isMobile)
                        else
                          _developPanel(),
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

  // ── Tab switcher ────────────────────────────────────────────────────────────
  Widget _tabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.mdAll,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tabButton('Login', 0),
          _tabButton('Develop', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: AppRadius.smAll,
            boxShadow: selected ? AppShadows.card : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.primary700 : AppColors.neutral500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────
  Widget _loginForm(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2)
              .copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Masuk dengan email dan password Anda',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        ),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        Text(
          'Email',
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('masukkan@email.com'),
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Password',
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _passwordController,
          enabled: !_isLoading,
          obscureText: !_showPassword,
          decoration: _fieldDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.neutral500,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
        ),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: _primaryButtonStyle(),
            child: _isLoading
                ? const _ButtonSpinner()
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
    );
  }

  // ── Develop panel ─────────────────────────────────────────────────────────────
  Widget _developPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Login',
          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Masuk cepat sebagai salah satu role (password: $_devPassword)',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final account in _devAccounts) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => _login(account.email, _devPassword),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary700,
                side: const BorderSide(color: AppColors.neutral300),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account.label,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    account.email,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  // ── Style helpers ─────────────────────────────────────────────────────────────
  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral300),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: border(AppColors.neutral300),
      enabledBorder: border(AppColors.neutral300),
      focusedBorder: border(AppColors.primary500, 2),
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary700,
    disabledBackgroundColor: AppColors.neutral300,
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
  );
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
    ),
  );
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
