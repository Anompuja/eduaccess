import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable refresh icon button with automatic loading state.
/// Displays a CircularProgressIndicator while `onRefresh` is executing.
///
/// ```dart
/// AppRefreshButton(
///   onRefresh: () async {
///     await ref.read(cacheStoreProvider).clean();
///     ref.invalidate(someProvider);
///   },
/// )
/// ```
class AppRefreshButton extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final String tooltip;

  const AppRefreshButton({
    super.key,
    required this.onRefresh,
    this.tooltip = 'Refresh data',
  });

  @override
  State<AppRefreshButton> createState() => _AppRefreshButtonState();
}

class _AppRefreshButtonState extends State<AppRefreshButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary700),
              ),
            )
          : const Icon(Icons.refresh_rounded, color: AppColors.primary700),
      tooltip: widget.tooltip,
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await widget.onRefresh();
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
    );
  }
}
