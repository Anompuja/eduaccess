import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// EduAccess standard card container.
/// White bg, 16px radius, subtle shadow.
///
/// ```dart
/// AppCard(
///   child: Text('Content'),
/// )
/// AppCard(padding: EdgeInsets.all(32), child: ...)
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final BorderRadiusGeometry borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = AppRadius.xlAll,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: borderRadius,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}
