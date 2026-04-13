import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum _AppButtonVariant { primary, secondary, accent, danger, ghost }

/// EduAccess standard button.
///
/// ```dart
/// AppButton.primary(label: 'Simpan', onPressed: _save)
/// AppButton.secondary(label: 'Batal', onPressed: _cancel)
/// AppButton.accent(label: 'Download', onPressed: _download)
/// AppButton.danger(label: 'Hapus', onPressed: _delete)
/// AppButton(label: 'Custom', onPressed: _fn, isLoading: true)
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final _AppButtonVariant _variant;
  final Widget? prefixIcon;
  final double height;

  const AppButton._({
    required this.label,
    required _AppButtonVariant variant,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.height = 44,
    super.key,
  }) : _variant = variant;

  // ── Named constructors ─────────────────────────────────────────────────────
  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    Widget? prefixIcon,
    double height = 44,
    Key? key,
  }) =>
      AppButton._(
        label: label,
        variant: _AppButtonVariant.primary,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        prefixIcon: prefixIcon,
        height: height,
        key: key,
      );

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    Widget? prefixIcon,
    double height = 44,
    Key? key,
  }) =>
      AppButton._(
        label: label,
        variant: _AppButtonVariant.secondary,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        prefixIcon: prefixIcon,
        height: height,
        key: key,
      );

  factory AppButton.accent({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    Widget? prefixIcon,
    double height = 44,
    Key? key,
  }) =>
      AppButton._(
        label: label,
        variant: _AppButtonVariant.accent,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        prefixIcon: prefixIcon,
        height: height,
        key: key,
      );

  factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    Widget? prefixIcon,
    double height = 44,
    Key? key,
  }) =>
      AppButton._(
        label: label,
        variant: _AppButtonVariant.danger,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        prefixIcon: prefixIcon,
        height: height,
        key: key,
      );

  factory AppButton.ghost({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = false,
    Widget? prefixIcon,
    double height = 44,
    Key? key,
  }) =>
      AppButton._(
        label: label,
        variant: _AppButtonVariant.ghost,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        prefixIcon: prefixIcon,
        height: height,
        key: key,
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final config = _variantConfig();
    final isDisabled = onPressed == null || isLoading;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: config.fgColor,
            ),
          )
        else ...[
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMdSemiBold.copyWith(color: config.fgColor),
          ),
        ],
      ],
    );

    Widget button = switch (_variant) {
      _AppButtonVariant.secondary => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll),
            side: BorderSide(
              color: isDisabled ? AppColors.neutral300 : config.bgColor,
              width: 1.5,
            ),
            foregroundColor: config.fgColor,
          ),
          child: content,
        ),
      _ => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? AppColors.neutral300 : config.bgColor,
            foregroundColor: config.fgColor,
            disabledBackgroundColor: AppColors.neutral100,
            disabledForegroundColor: AppColors.neutral500,
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll),
            elevation: 0,
          ),
          child: content,
        ),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  // ── Variant config ─────────────────────────────────────────────────────────
  ({Color bgColor, Color fgColor}) _variantConfig() => switch (_variant) {
        _AppButtonVariant.primary   => (bgColor: AppColors.primary700,  fgColor: AppColors.white),
        _AppButtonVariant.secondary => (bgColor: AppColors.primary700,  fgColor: AppColors.primary700),
        _AppButtonVariant.accent    => (bgColor: AppColors.accent500,   fgColor: AppColors.white),
        _AppButtonVariant.danger    => (bgColor: AppColors.error,       fgColor: AppColors.white),
        _AppButtonVariant.ghost     => (bgColor: Colors.transparent,    fgColor: AppColors.neutral700),
      };
}
