import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Generic modal dialog wrapper.
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     title: 'Tambah Siswa',
///     content: AddStudentForm(),
///     actions: [
///       AppButton.secondary(label: 'Batal', onPressed: () => Navigator.pop(context)),
///       AppButton.primary(label: 'Simpan', onPressed: _save),
///     ],
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget> actions;
  final double maxWidth;

  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.actions = const [],
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.lg, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.h4
                                .copyWith(color: AppColors.neutral900)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(subtitle!,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.neutral500)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.neutral500),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: AppSpacing.xl, color: AppColors.neutral100),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: content,
              ),
            ),
            // Actions
            if (actions.isNotEmpty) ...[
              const Divider(height: AppSpacing.xl, color: AppColors.neutral100),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: a,
                          ))
                      .toList(),
                ),
              ),
            ] else
              const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// "Apakah Anda yakin?" confirmation dialog.
///
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context: context,
///   title: 'Hapus Siswa',
///   message: 'Data siswa akan dihapus permanen.',
///   confirmLabel: 'Hapus',
///   isDanger: true,
/// );
/// if (confirmed == true) { ... }
/// ```
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Konfirmasi',
    this.cancelLabel = 'Batal',
    this.isDanger = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Konfirmasi',
    String cancelLabel = 'Batal',
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDanger
                      ? Icons.delete_outline_rounded
                      : Icons.help_outline_rounded,
                  color: isDanger ? AppColors.error : AppColors.warning,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title,
                  style:
                      AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(message,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: cancelLabel,
                      isFullWidth: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: isDanger
                        ? AppButton.danger(
                            label: confirmLabel,
                            isFullWidth: true,
                            onPressed: () => Navigator.of(context).pop(true),
                          )
                        : AppButton.primary(
                            label: confirmLabel,
                            isFullWidth: true,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
