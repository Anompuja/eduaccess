import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Centered loading spinner.
///
/// ```dart
/// const AppLoadingIndicator()
/// AppLoadingIndicator(message: 'Memuat data...')
/// ```
class AppLoadingIndicator extends StatelessWidget {
  final String? message;

  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary500,
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer-style placeholder row (used in lists while loading).
class AppShimmerRow extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const AppShimmerRow({
    super.key,
    this.height = 48,
    this.width,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
