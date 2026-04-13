import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// 404 / route error screen.
class NotFoundScreen extends StatelessWidget {
  final String? message;

  const NotFoundScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primary100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.primary500,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary700.withValues(alpha: 0.2),
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Halaman Tidak Ditemukan',
                style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message ??
                    'Halaman yang Anda cari tidak tersedia atau telah dipindahkan.',
                style:
                    AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.secondary(
                    label: 'Kembali',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.dashboard);
                      }
                    },
                    prefixIcon: const Icon(Icons.arrow_back_rounded,
                        size: 16, color: AppColors.primary700),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  AppButton.primary(
                    label: 'Ke Dashboard',
                    onPressed: () => context.go(RouteNames.dashboard),
                    prefixIcon: const Icon(
                        Icons.space_dashboard_outlined,
                        size: 16,
                        color: AppColors.white),
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
