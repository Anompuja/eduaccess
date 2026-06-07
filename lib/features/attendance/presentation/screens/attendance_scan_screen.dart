import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import 'package:eduaccess/core/widgets/app_card.dart';
import '../providers/attendance_provider.dart';

class AttendanceScanScreen extends ConsumerStatefulWidget {
  final String? token;
  const AttendanceScanScreen({super.key, this.token});

  @override
  ConsumerState<AttendanceScanScreen> createState() => _AttendanceScanScreenState();
}

class _AttendanceScanScreenState extends ConsumerState<AttendanceScanScreen> {
  bool _loading = false;
  String? _resultStatus;
  String? _resultMessage;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit(widget.token!));
    }
  }

  Future<void> _submit(String token) async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ref.read(attendanceRepositoryProvider).scanQR(token);
      if (!mounted) return;
      setState(() {
        _resultStatus = result['status'] as String?;
        _resultMessage = result['message'] as String?;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Absensi', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.neutral900,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: _body(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (widget.token == null) return _noTokenView();
    if (_loading) return _loadingView();
    if (_error != null) return _errorView(_error!);
    if (_resultStatus != null) return _resultView(_resultStatus!, _resultMessage ?? '');
    return _loadingView();
  }

  Widget _noTokenView() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.link_off_rounded, size: 56, color: AppColors.neutral300),
      const SizedBox(height: AppSpacing.lg),
      Text('Token tidak ditemukan', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Scan ulang QR code dari guru atau minta guru menampilkan kode baru.',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _loadingView() => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(color: AppColors.primary500),
      SizedBox(height: AppSpacing.lg),
      Text('Memproses kehadiran...'),
    ],
  );

  Widget _errorView(String message) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Gagal Absen', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
      const SizedBox(height: AppSpacing.md),
      Text(message, style: AppTextStyles.bodyMd.copyWith(color: AppColors.error), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.xl),
      AppButton.secondary(
        label: 'Coba Lagi',
        isFullWidth: true,
        onPressed: widget.token != null ? () => _submit(widget.token!) : null,
      ),
    ],
  );

  Widget _resultView(String status, String message) {
    final isSuccess = status == 'present' || status == 'late';
    final color = status == 'present' ? AppColors.success
        : status == 'late' ? AppColors.warning
        : AppColors.error;
    final icon = status == 'present' ? Icons.check_circle_rounded
        : status == 'late' ? Icons.access_time_rounded
        : Icons.cancel_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: color),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          isSuccess ? (status == 'present' ? 'Berhasil Hadir!' : 'Hadir Terlambat') : 'Tidak Berhasil',
          style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message.isEmpty ? _defaultMessage(status) : message,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.mdAll),
          child: Text(
            _statusLabel(status),
            style: AppTextStyles.bodyMdSemiBold.copyWith(color: color),
          ),
        ),
        if (isSuccess) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Kehadiranmu telah tercatat. Halaman ini bisa ditutup.',
            style: AppTextStyles.label.copyWith(color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _statusLabel(String status) => switch (status) {
    'present' => 'Hadir',
    'late' => 'Terlambat',
    _ => status,
  };

  String _defaultMessage(String status) => switch (status) {
    'present' => 'Kehadiranmu sudah tercatat.',
    'late' => 'Kamu terlambat masuk kelas.',
    _ => 'Cek statusmu dengan guru.',
  };
}
