import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// EduAccess standard text input.
///
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'contoh@sekolah.id',
///   controller: _emailController,
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.email,
/// )
///
/// AppTextField.password(
///   label: 'Password',
///   controller: _passController,
/// )
/// ```
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.errorText,
  });

  /// Convenience constructor for password fields (obscure toggle built-in).
  factory AppTextField.password({
    required String label,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.done,
    FocusNode? focusNode,
    String? errorText,
    Key? key,
  }) =>
      _PasswordTextField(
        label: label,
        controller: controller,
        validator: validator,
        textInputAction: textInputAction,
        focusNode: focusNode,
        errorText: errorText,
        key: key,
      );

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    size: 18, color: AppColors.neutral500)
                : null,
            suffix: widget.suffix,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// Password field variant with built-in visibility toggle.
class _PasswordTextField extends AppTextField {
  const _PasswordTextField({
    required super.label,
    super.controller,
    super.validator,
    super.textInputAction,
    super.focusNode,
    super.errorText,
    super.key,
  });

  @override
  State<AppTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(color: AppColors.neutral700),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          obscureText: _obscure,
          focusNode: widget.focusNode,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Masukkan password',
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.lock_outline,
                size: 18, color: AppColors.neutral500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: AppColors.neutral500,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}
