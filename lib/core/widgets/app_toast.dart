import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum ToastType { success, error, warning, info }

/// Overlay toast notification.
///
/// ```dart
/// AppToast.show(context, message: 'Data berhasil disimpan');
/// AppToast.show(context, message: 'Login gagal', type: ToastType.error);
/// AppToast.show(context, message: 'Periksa koneksi', type: ToastType.warning);
/// ```
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config(widget.type);

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.lg,
      left: AppSpacing.xl,
      right: AppSpacing.xl,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: cfg.bg,
              borderRadius: AppRadius.lgAll,
              boxShadow: AppShadows.elevated,
              border: Border.all(color: cfg.border),
            ),
            child: Row(
              children: [
                Icon(cfg.icon, color: cfg.iconColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.message,
                    style:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _ctrl.reverse();
                    widget.onDismiss();
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({Color bg, Color border, Color iconColor, IconData icon}) _config(
          ToastType t) =>
      switch (t) {
        ToastType.success => (
            bg: AppColors.white,
            border: AppColors.success.withValues(alpha: 0.3),
            iconColor: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
        ToastType.error => (
            bg: AppColors.white,
            border: AppColors.error.withValues(alpha: 0.3),
            iconColor: AppColors.error,
            icon: Icons.error_outline_rounded,
          ),
        ToastType.warning => (
            bg: AppColors.white,
            border: AppColors.warning.withValues(alpha: 0.3),
            iconColor: AppColors.warning,
            icon: Icons.warning_amber_rounded,
          ),
        ToastType.info => (
            bg: AppColors.white,
            border: AppColors.info.withValues(alpha: 0.3),
            iconColor: AppColors.info,
            icon: Icons.info_outline_rounded,
          ),
      };
}
