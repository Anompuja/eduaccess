import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/utils/responsive.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import 'package:eduaccess/core/widgets/school_filter.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/jadwal_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/jenjang_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/kelas_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/mata_pelajaran_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/ruang_kelas_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/sub_kelas_tab.dart';
import 'package:eduaccess/features/academic/presentation/widgets/academic/tahun_ajaran_tab.dart';

class AcademicScreen extends ConsumerStatefulWidget {
  const AcademicScreen({super.key});

  @override
  ConsumerState<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends ConsumerState<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);

    return Padding(
      padding: isCompact ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Struktur Akademik', style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kelola jenjang, kelas, tahun ajaran, mata pelajaran, ruang kelas, dan jadwal.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.md),
          const SchoolFilter(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    labelColor: AppColors.primary700,
                    unselectedLabelColor: AppColors.neutral500,
                    indicatorColor: AppColors.primary700,
                    labelStyle: AppTextStyles.bodyMdSemiBold,
                    tabs: const [
                      Tab(text: 'Jenjang'),
                      Tab(text: 'Kelas'),
                      Tab(text: 'Sub Kelas'),
                      Tab(text: 'Tahun Ajaran'),
                      Tab(text: 'Mata Pelajaran'),
                      Tab(text: 'Ruang Kelas'),
                      Tab(text: 'Jadwal'),
                    ],
                  ),
                  const Divider(height: 1, color: AppColors.neutral100),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        JenjangTab(),
                        KelasTab(),
                        SubKelasTab(),
                        TahunAjaranTab(),
                        MataPelajaranTab(),
                        RuangKelasTab(),
                        JadwalTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
