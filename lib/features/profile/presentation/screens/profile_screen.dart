import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl        = TextEditingController();
  final _currPassCtrl    = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _profileFormKey  = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _savingProfile  = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) _nameCtrl.text = user.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    // TODO: call PUT /profile API
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(authNotifierProvider.notifier).updateUser(
            user.copyWith(name: _nameCtrl.text.trim()),
          );
    }
    AppToast.show(context, message: 'Profil berhasil diperbarui');
    setState(() => _savingProfile = false);
  }

  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    // TODO: call PUT /users/:id/password API
    _currPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    AppToast.show(context, message: 'Password berhasil diubah');
    setState(() => _savingPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final initials = _initials(user.name);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final roleLabel = user.role.displayName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — avatar + role
                SizedBox(width: 280, child: _AvatarCard(initials: initials, user: user, roleLabel: roleLabel)),
                const SizedBox(width: AppSpacing.xl),
                // Right — forms
                Expanded(
                  child: Column(
                    children: [
                      _ProfileForm(
                        formKey: _profileFormKey,
                        nameCtrl: _nameCtrl,
                        email: user.email,
                        onSave: _saveProfile,
                        saving: _savingProfile,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _PasswordForm(
                        formKey: _passwordFormKey,
                        currCtrl: _currPassCtrl,
                        newCtrl: _newPassCtrl,
                        confirmCtrl: _confirmPassCtrl,
                        onSave: _savePassword,
                        saving: _savingPassword,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _AvatarCard(initials: initials, user: user, roleLabel: roleLabel),
                const SizedBox(height: AppSpacing.xl),
                _ProfileForm(
                  formKey: _profileFormKey,
                  nameCtrl: _nameCtrl,
                  email: user.email,
                  onSave: _saveProfile,
                  saving: _savingProfile,
                ),
                const SizedBox(height: AppSpacing.xl),
                _PasswordForm(
                  formKey: _passwordFormKey,
                  currCtrl: _currPassCtrl,
                  newCtrl: _newPassCtrl,
                  confirmCtrl: _confirmPassCtrl,
                  onSave: _savePassword,
                  saving: _savingPassword,
                ),
              ],
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _AvatarCard extends StatelessWidget {
  final String initials;
  final AuthUser user;
  final String roleLabel;
  const _AvatarCard({required this.initials, required this.user, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary500,
            child: Text(initials,
                style: AppTextStyles.h2.copyWith(color: AppColors.white)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(user.name,
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(user.email,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          AppBadge(label: roleLabel, status: BadgeStatus.active),
          if (user.schoolId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('ID Sekolah: ${user.schoolId}',
                style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
          ],
        ],
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final String email;
  final VoidCallback onSave;
  final bool saving;

  const _ProfileForm({
    required this.formKey,
    required this.nameCtrl,
    required this.email,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Profil',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Nama Lengkap',
                  controller: nameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Email',
                  hint: email,
                  readOnly: true,
                  enabled: false,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.primary(
                  label: 'Simpan Perubahan',
                  isLoading: saving,
                  onPressed: onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;
  final VoidCallback onSave;
  final bool saving;

  const _PasswordForm({
    required this.formKey,
    required this.currCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ubah Password',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField.password(
                  label: 'Password Saat Ini',
                  controller: currCtrl,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Password saat ini'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField.password(
                  label: 'Password Baru',
                  controller: newCtrl,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField.password(
                  label: 'Konfirmasi Password Baru',
                  controller: confirmCtrl,
                  validator: (v) =>
                      Validators.confirmPassword(v, newCtrl.text),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.primary(
                  label: 'Ubah Password',
                  isLoading: saving,
                  onPressed: onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
