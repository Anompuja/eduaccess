import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/datasources/reports_dummy_data.dart';
import '../../data/models/report_entities.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: isMobile ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ringkasan statistik sekolah dan simulasi export laporan (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: reportsDummyKpis.map(_kpiCard).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isMobile)
            Column(
              children: [
                _chartCard(
                  title: 'Kelas Dengan Performa Terbaik',
                  data: reportsDummyTopClasses,
                  suffix: '',
                ),
                const SizedBox(height: AppSpacing.lg),
                _chartCard(
                  title: 'Kehadiran per Bulan',
                  data: reportsDummyAttendanceByMonth,
                  suffix: '%',
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _chartCard(
                    title: 'Kelas Dengan Performa Terbaik',
                    data: reportsDummyTopClasses,
                    suffix: '',
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _chartCard(
                    title: 'Kehadiran per Bulan',
                    data: reportsDummyAttendanceByMonth,
                    suffix: '%',
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Export laporan belum terhubung backend. Gunakan simulasi tombol untuk demo UTS.',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton.primary(
                  label: 'Export PDF',
                  onPressed: () => _showExportInfo(context, 'PDF'),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton.secondary(
                  label: 'Export Excel',
                  onPressed: () => _showExportInfo(context, 'Excel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(ReportKpi item) {
    return AppCard(
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.value, style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
            const SizedBox(height: AppSpacing.xs),
            Text(item.label, style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.delta,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required List<ReportCategory> data,
    required String suffix,
  }) {
    final maxValue = data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.md),
          ...data.map((item) {
            final ratio = maxValue == 0 ? 0.0 : item.value / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700),
                        ),
                      ),
                      Text(
                        '${item.value}$suffix',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: ratio,
                      backgroundColor: AppColors.neutral100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showExportInfo(BuildContext context, String type) {
    AppToast.show(
      context,
      message: 'Export $type masih simulasi UI (backend belum tersedia).',
      type: ToastType.info,
    );
  }
}
