import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Prev / Next + numbered page buttons.
///
/// ```dart
/// AppPagination(
///   currentPage: 1,
///   totalPages: 10,
///   onPageChanged: (p) => ref.read(provider.notifier).setPage(p),
/// )
/// ```
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _visiblePages();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prev
        _NavBtn(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: AppSpacing.xs),

        // Page numbers
        ...pages.map((p) {
          if (p == -1) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text('…',
                  style: TextStyle(color: AppColors.neutral500)),
            );
          }
          final isActive = p == currentPage;
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 2),
            child: _PageBtn(
              page: p,
              isActive: isActive,
              onTap: () => onPageChanged(p),
            ),
          );
        }),

        const SizedBox(width: AppSpacing.xs),
        // Next
        _NavBtn(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }

  /// Returns page numbers to show, inserting -1 for ellipsis gaps.
  List<int> _visiblePages() {
    if (totalPages <= 7) return List.generate(totalPages, (i) => i + 1);
    final pages = <int>[];
    pages.add(1);
    if (currentPage > 3) pages.add(-1);
    for (var p = (currentPage - 1).clamp(2, totalPages - 1);
        p <= (currentPage + 1).clamp(2, totalPages - 1);
        p++) {
      pages.add(p);
    }
    if (currentPage < totalPages - 2) pages.add(-1);
    pages.add(totalPages);
    return pages;
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.neutral300),
          borderRadius: AppRadius.smAll,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.neutral700 : AppColors.neutral300,
        ),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PageBtn(
      {required this.page, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary700 : AppColors.white,
          border: Border.all(
            color: isActive ? AppColors.primary700 : AppColors.neutral300,
          ),
          borderRadius: AppRadius.smAll,
        ),
        child: Center(
          child: Text(
            '$page',
            style: AppTextStyles.label.copyWith(
              color: isActive ? AppColors.white : AppColors.neutral700,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
