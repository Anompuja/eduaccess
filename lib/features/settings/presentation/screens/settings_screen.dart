import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

final _themePrefProvider = StateNotifierProvider<_ThemePrefNotifier, bool>((
  ref,
) {
  return _ThemePrefNotifier();
});

class _ThemePrefNotifier extends StateNotifier<bool> {
  static const _key = 'dark_mode';

  _ThemePrefNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(_themePrefProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tampilan',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Mode Gelap',
                  subtitle: 'Aktifkan tema gelap untuk semua layar',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(_themePrefProvider.notifier).toggle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bahasa',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Bahasa Aplikasi',
                  subtitle: 'Bahasa Indonesia',
                  trailing: Chip(
                    label: const Text('Coming soon'),
                    backgroundColor: AppColors.neutral100,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Versi Aplikasi',
                  subtitle: 'EduAccess v1.0.0',
                  trailing: const SizedBox.shrink(),
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Syarat & Ketentuan',
                  subtitle: '',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.neutral500,
                  ),
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  subtitle: '',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary700, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.neutral100,
    );
  }
}
