import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Search input with 300ms debounce.
///
/// ```dart
/// AppSearchBar(
///   hint: 'Cari siswa...',
///   onSearch: (query) => ref.read(studentListProvider.notifier).search(query),
/// )
/// ```
class AppSearchBar extends StatefulWidget {
  final String hint;
  final void Function(String) onSearch;
  final Duration debounceDuration;
  final double? width;

  const AppSearchBar({
    super.key,
    this.hint = 'Cari...',
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.width,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 40,
      child: TextField(
        controller: _ctrl,
        onChanged: _onChanged,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral900),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral300),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.neutral500,
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _ctrl,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.neutral500),
                    onPressed: () {
                      _ctrl.clear();
                      widget.onSearch('');
                    },
                  ),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: const BorderSide(color: AppColors.neutral300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: const BorderSide(color: AppColors.neutral300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide:
                const BorderSide(color: AppColors.primary500, width: 1.5),
          ),
        ),
      ),
    );
  }
}
