import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const AppLoadingIndicator(message: 'Memuat dashboard...'),
      error: (e, _) => AppErrorState(
        message: e.toString(),
        onRetry: () => ref.read(dashboardStatsProvider.notifier).refresh(),
      ),
      data: (stats) => _DashboardContent(stats: stats),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.of(context);
    final pad = screen.isMobile ? AppSpacing.lg : AppSpacing.xl;

    return RefreshIndicator(
      color: AppColors.primary500,
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stat cards ─────────────────────────────────────────────────
            screen.isDesktop
                ? _StatCardRow(stats: stats)
                : _StatCardGrid(stats: stats, compact: screen.isMobile),
            SizedBox(height: pad),

            // ── Chart + Quick actions ──────────────────────────────────────
            if (screen.isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _AttendanceChart(
                        data: stats.weeklyAttendance, compact: false),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(flex: 2, child: _QuickActions()),
                ],
              )
            else ...[
              _AttendanceChart(
                  data: stats.weeklyAttendance, compact: screen.isMobile),
              SizedBox(height: pad),
              _QuickActions(),
            ],
            SizedBox(height: pad),

            // ── Recent activity + Active exams ─────────────────────────────
            if (screen.isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child:
                        _RecentActivity(activities: stats.recentActivities),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 2,
                    child: _ActiveExams(exams: stats.activeExams),
                  ),
                ],
              )
            else ...[
              _RecentActivity(activities: stats.recentActivities),
              SizedBox(height: pad),
              _ActiveExams(exams: stats.activeExams),
            ],

            SizedBox(height: pad),
          ],
        ),
      ),
    );
  }
}

// ── Stat cards ─────────────────────────────────────────────────────────────────
class _StatCardRow extends StatelessWidget {
  final DashboardStats stats;
  const _StatCardRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total Siswa',
              value: _fmt(stats.totalStudents),
              subtitle: '+12 bulan ini',
              icon: Icons.school_outlined,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _StatCard(
              label: 'Total Guru',
              value: _fmt(stats.totalTeachers),
              subtitle: '+2 bulan ini',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _StatCard(
              label: 'Kelas Aktif',
              value: _fmt(stats.activeClasses),
              subtitle: 'Semester ini',
              icon: Icons.class_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _StatCard(
              label: 'Langganan',
              value: stats.subscriptionPlan,
              subtitle: 'Aktif hingga Des 2024',
              icon: Icons.workspace_premium_outlined,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

class _StatCardGrid extends StatelessWidget {
  final DashboardStats stats;
  final bool compact;
  const _StatCardGrid({required this.stats, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final gap = compact ? AppSpacing.md : AppSpacing.lg;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: gap,
      mainAxisSpacing: gap,
      childAspectRatio: compact ? 1.4 : 1.65,
      children: [
        _StatCard(
          label: 'Total Siswa',
          value: '${stats.totalStudents}',
          subtitle: '+12 bulan ini',
          icon: Icons.school_outlined,
          isPrimary: true,
          compact: compact,
        ),
        _StatCard(
          label: 'Total Guru',
          value: '${stats.totalTeachers}',
          subtitle: '+2 bulan ini',
          icon: Icons.badge_outlined,
          compact: compact,
        ),
        _StatCard(
          label: 'Kelas Aktif',
          value: '${stats.activeClasses}',
          subtitle: 'Semester ini',
          icon: Icons.class_outlined,
          compact: compact,
        ),
        _StatCard(
          label: 'Langganan',
          value: stats.subscriptionPlan,
          subtitle: 'Aktif',
          icon: Icons.workspace_premium_outlined,
          compact: compact,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final bool compact;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg          = isPrimary ? AppColors.primary900 : AppColors.white;
    final labelColor  = isPrimary ? AppColors.primary300 : AppColors.neutral500;
    final valueColor  = isPrimary ? AppColors.white       : AppColors.neutral900;
    final subColor    = isPrimary ? AppColors.primary300  : AppColors.success;
    final iconBg      = isPrimary ? AppColors.primary700  : AppColors.primary100;
    final iconColor   = isPrimary ? AppColors.white       : AppColors.primary700;
    final pad         = compact ? AppSpacing.md : AppSpacing.xl;
    final iconSize    = compact ? 28.0 : 36.0;
    final valueStyle  = compact ? AppTextStyles.h3 : AppTextStyles.h2;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySm.copyWith(color: labelColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: iconColor,
                    size: compact ? 15 : 18),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: valueStyle.copyWith(color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: subColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Attendance bar chart ───────────────────────────────────────────────────────
class _AttendanceChart extends StatelessWidget {
  final List<DailyAttendance> data;
  final bool compact;
  const _AttendanceChart({required this.data, required this.compact});

  @override
  Widget build(BuildContext context) {
    final chartHeight = compact ? 180.0 : 200.0;

    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text('Statistik Absensi',
                style: AppTextStyles.h4
                    .copyWith(color: AppColors.neutral900)),
            Text('Per hari — minggu ini',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.neutral500)),
            const SizedBox(height: AppSpacing.sm),
            _Legend(compact: compact),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statistik Absensi',
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.neutral900)),
                      Text('Per hari — minggu ini',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.neutral500)),
                    ],
                  ),
                ),
                _Legend(compact: compact),
              ],
            ),
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
          // Mobile: horizontal scroll so chart never gets squished.
          // Desktop: fill available width directly (no scroll wrapper).
          if (compact)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: (data.length * 64.0).clamp(300.0, 800.0),
                height: chartHeight,
                child: _BarChartWidget(data: data),
              ),
            )
          else
            SizedBox(
              height: chartHeight,
              child: _BarChartWidget(data: data),
            ),
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<DailyAttendance> data;
  const _BarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.isEmpty
        ? 200.0
        : (data.map((d) => d.present).reduce((a, b) => a > b ? a : b) * 1.2)
            .ceilToDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.neutral900,
            getTooltipItem: (group, _, rod, ri) {
              final labels = ['Hadir', 'Absen', 'Terlambat'];
              return BarTooltipItem(
                '${labels[ri]}: ${rod.toY.toInt()}',
                AppTextStyles.caption.copyWith(color: AppColors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(data[i].day,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutral500),
              ),
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.neutral100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final d = e.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: d.present.toDouble(),
                color: AppColors.primary500,
                width: 7,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: d.absent.toDouble(),
                color: AppColors.error,
                width: 7,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: d.late.toDouble(),
                color: AppColors.warning,
                width: 7,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool compact;
  const _Legend({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? AppSpacing.sm : AppSpacing.md,
      runSpacing: 4,
      children: [
        _LegendDot(color: AppColors.primary500, label: 'Hadir'),
        _LegendDot(color: AppColors.error, label: 'Absen'),
        _LegendDot(color: AppColors.warning, label: 'Terlambat'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
      ],
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);
    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aksi Cepat',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          _ActionBtn(
            label: 'Tambah Siswa',
            icon: Icons.person_add_outlined,
            bgColor: AppColors.primary100,
            fgColor: AppColors.primary700,
            onTap: () => context.push(RouteNames.students),
            compact: compact,
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          _ActionBtn(
            label: 'Input Absensi',
            icon: Icons.fact_check_outlined,
            bgColor: AppColors.primary100,
            fgColor: AppColors.primary700,
            onTap: () => context.push(RouteNames.attendance),
            compact: compact,
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          _ActionBtn(
            label: 'Buat Ujian CBT',
            icon: Icons.quiz_outlined,
            bgColor: AppColors.accent100,
            fgColor: AppColors.accent700,
            onTap: () => context.push(RouteNames.cbt),
            compact: compact,
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          _ActionBtn(
            label: 'Lihat Laporan',
            icon: Icons.bar_chart_rounded,
            bgColor: AppColors.neutral100,
            fgColor: AppColors.neutral700,
            onTap: () {},
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;
  final bool compact;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Container(
          height: compact ? 44 : 52,
          padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.md : AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: compact ? 18 : 20),
              SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyMdSemiBold
                        .copyWith(color: fgColor, fontSize: compact ? 13 : 14),
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: fgColor.withValues(alpha: 0.5),
                  size: compact ? 12 : 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent activity ───────────────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  final List<RecentActivity> activities;
  const _RecentActivity({required this.activities});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);
    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aktivitas Terbaru',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          ...activities.map((a) => _ActivityItem(activity: a, compact: compact)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final RecentActivity activity;
  final bool compact;
  const _ActivityItem({required this.activity, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: BoxDecoration(
              color: _iconBg(activity.type),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(activity.type),
                color: _iconColor(activity.type),
                size: compact ? 15 : 18),
          ),
          SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: AppTextStyles.bodyMd
                        .copyWith(
                            color: AppColors.neutral900,
                            fontSize: compact ? 13 : 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(activity.subtitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.neutral500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(activity.time,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  IconData _icon(ActivityType t) => switch (t) {
        ActivityType.student    => Icons.school_outlined,
        ActivityType.attendance => Icons.fact_check_outlined,
        ActivityType.exam       => Icons.quiz_outlined,
        ActivityType.staff      => Icons.badge_outlined,
        ActivityType.general    => Icons.notifications_outlined,
      };

  Color _iconBg(ActivityType t) => switch (t) {
        ActivityType.student    => AppColors.primary100,
        ActivityType.attendance => AppColors.success.withValues(alpha: 0.1),
        ActivityType.exam       => AppColors.accent100,
        ActivityType.staff      => AppColors.info.withValues(alpha: 0.1),
        ActivityType.general    => AppColors.neutral100,
      };

  Color _iconColor(ActivityType t) => switch (t) {
        ActivityType.student    => AppColors.primary700,
        ActivityType.attendance => AppColors.success,
        ActivityType.exam       => AppColors.accent700,
        ActivityType.staff      => AppColors.info,
        ActivityType.general    => AppColors.neutral500,
      };
}

// ── Active exams ──────────────────────────────────────────────────────────────
class _ActiveExams extends StatelessWidget {
  final List<ActiveExam> exams;
  const _ActiveExams({required this.exams});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);
    return AppCard(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('CBT Aktif',
                    style: AppTextStyles.h4
                        .copyWith(color: AppColors.neutral900)),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.cbt),
                child: Text('Lihat semua',
                    style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          ...exams.map((e) => _ExamItem(exam: e, compact: compact)),
        ],
      ),
    );
  }
}

class _ExamItem extends StatelessWidget {
  final ActiveExam exam;
  final bool compact;
  const _ExamItem({required this.exam, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, badgeStatus) = switch (exam.status) {
      ExamStatus.ongoing   => ('Berlangsung', BadgeStatus.active),
      ExamStatus.scheduled => ('Terjadwal',   BadgeStatus.warning),
      ExamStatus.finished  => ('Selesai',     BadgeStatus.muted),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            decoration: const BoxDecoration(
              color: AppColors.accent100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined,
                color: AppColors.accent700, size: compact ? 15 : 18),
          ),
          SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.title,
                    style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral900,
                        fontSize: compact ? 13 : 14),
                    overflow: TextOverflow.ellipsis),
                Text('${exam.className} · ${exam.duration}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          AppBadge(label: statusLabel, status: badgeStatus),
        ],
      ),
    );
  }
}
