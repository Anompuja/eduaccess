import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Temporary placeholder for routes that Dev 2 / Dev 3 will implement.
/// Replace by removing this widget and implementing the real screen.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String assignedTo;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.assignedTo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: AppColors.primary700,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 8),
          Text(
            'Diimplementasikan oleh $assignedTo',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}
