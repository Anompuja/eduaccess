import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:eduaccess/core/theme/app_colors.dart';
import 'package:eduaccess/core/theme/app_spacing.dart';
import 'package:eduaccess/core/theme/app_text_styles.dart';
import 'package:eduaccess/core/widgets/app_button.dart';
import '../providers/attendance_provider.dart';

class AttendanceScannerScreen extends ConsumerStatefulWidget {
  const AttendanceScannerScreen({super.key});

  @override
  ConsumerState<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends ConsumerState<AttendanceScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _processing = false;
  String? _resultStatus;
  String? _resultMessage;
  String? _error;

  // Permission states
  bool _permissionChecked = false;
  bool _permissionGranted = false;
  bool _permissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _permissionChecked = true;
      _permissionGranted = status.isGranted;
      _permissionPermanentlyDenied = status.isPermanentlyDenied;
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _controller?.pauseCamera();
    _controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code;
      if (code == null || code.isEmpty || _processing) return;
      _processToken(code);
    });
  }

  Future<void> _processToken(String rawValue) async {
    if (_processing) return;
    setState(() { _processing = true; _error = null; });
    await _controller?.pauseCamera();

    // Support both raw JWT and URL-wrapped token (e.g. .../attendance/scan?token=...)
    String token = rawValue;
    if (rawValue.contains('token=')) {
      final uri = Uri.tryParse(rawValue);
      token = uri?.queryParameters['token'] ?? rawValue;
    }

    try {
      final result = await ref.read(attendanceRepositoryProvider).scanQR(token);
      if (!mounted) return;
      setState(() {
        _resultStatus = result['status'] as String?;
        _resultMessage = result['message'] as String?;
        _processing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _processing = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _resultStatus = null;
      _resultMessage = null;
      _processing = false;
    });
    _controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scan QR Absensi', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_permissionChecked) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary500),
      );
    }

    if (_permissionPermanentlyDenied) {
      return _permissionDeniedView(permanent: true);
    }

    if (!_permissionGranted) {
      return _permissionDeniedView(permanent: false);
    }

    if (_resultStatus != null) {
      return _resultView(_resultStatus!, _resultMessage ?? '');
    }

    if (_error != null) {
      return _errorView(_error!);
    }

    return _scannerView();
  }

  Widget _permissionDeniedView({required bool permanent}) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.warning),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Izin Kamera Diperlukan',
                style: AppTextStyles.h3.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                permanent
                    ? 'Izin kamera ditolak permanen. Buka Pengaturan → Aplikasi → EduAccess → Izin → Kamera, lalu aktifkan.'
                    : 'Aplikasi membutuhkan akses kamera untuk scan QR absensi.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral300),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (permanent)
                AppButton.primary(
                  label: 'Buka Pengaturan',
                  prefixIcon: const Icon(Icons.settings_rounded, size: 18, color: AppColors.white),
                  isFullWidth: true,
                  onPressed: openAppSettings,
                )
              else
                AppButton.primary(
                  label: 'Izinkan Kamera',
                  prefixIcon: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white),
                  isFullWidth: true,
                  onPressed: _requestCameraPermission,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scannerView() {
    return Stack(
      children: [
        QRView(
          key: _qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: AppColors.primary500,
            borderRadius: 12,
            borderLength: 32,
            borderWidth: 5,
            cutOutSize: MediaQuery.of(context).size.width * 0.72,
          ),
        ),
        if (_processing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            ),
          ),
        Positioned(
          bottom: 56,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Text(
                  'Arahkan ke QR code yang ditampilkan guru',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultView(String status, String message) {
    final isPresent = status == 'present';
    final isLate = status == 'late';
    final color = isPresent ? AppColors.success : isLate ? AppColors.warning : AppColors.error;
    final icon = isPresent
        ? Icons.check_circle_rounded
        : isLate
            ? Icons.access_time_rounded
            : Icons.cancel_rounded;
    final title = isPresent
        ? 'Berhasil Hadir!'
        : isLate
            ? 'Hadir Terlambat'
            : 'Tidak Berhasil';

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: color),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.white)),
              const SizedBox(height: AppSpacing.md),
              Text(
                message.isEmpty ? _defaultMessage(status) : message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral300),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  _statusLabel(status),
                  style: AppTextStyles.bodyMdSemiBold.copyWith(color: color),
                ),
              ),
              if (isPresent || isLate) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Kehadiranmu sudah tercatat. Halaman ini bisa ditutup.',
                  style: AppTextStyles.label.copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Gagal Absen', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton.primary(
                label: 'Scan Ulang',
                prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.white),
                isFullWidth: true,
                onPressed: _retry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'present' => 'Hadir',
    'late' => 'Terlambat',
    _ => status,
  };

  String _defaultMessage(String status) => switch (status) {
    'present' => 'Kehadiranmu sudah tercatat tepat waktu.',
    'late' => 'Kamu terlambat, tapi kehadiranmu tetap tercatat.',
    _ => 'Hubungi guru untuk informasi lebih lanjut.',
  };
}
