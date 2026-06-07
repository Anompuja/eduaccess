import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/external_url_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/school_filter.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/data/models/subscription_entities.dart';
import '../providers/payment_provider.dart';
import '../../data/models/payment_entities.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionPayment? initialPayment;

  const PaymentScreen({super.key, this.initialPayment});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  static const _pollInterval = Duration(seconds: 4);
  static const _pollTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  SubscriptionPayment? _payment;
  Duration _pollingElapsed = Duration.zero;
  bool _pollingTimedOut = false;
  bool _isRefreshing = false;
  bool _hasLoadedInitialStatus = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial =
          widget.initialPayment ?? ref.read(activeSubscriptionPaymentProvider);
      if (initial != null) {
        _trackPayment(initial, refreshImmediately: true);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final user = ref.watch(currentUserProvider);
    final schoolId = ref.watch(currentSubscriptionSchoolIdProvider);
    final trackedPayment =
        _payment ?? ref.watch(activeSubscriptionPaymentProvider);
    final plansAsync = ref.watch(schoolPlansProvider);

    if (_payment == null && trackedPayment != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _payment != null) return;
        _trackPayment(
          trackedPayment,
          refreshImmediately: !_hasLoadedInitialStatus,
        );
      });
    }

    return SingleChildScrollView(
      padding: isCompact
          ? const EdgeInsets.all(AppSpacing.lg)
          : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran',
            style: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pantau proses pembayaran paket sekolah dan lihat perkembangan statusnya secara berkala.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          if (user?.role == UserRole.superadmin) ...[
            const SizedBox(height: AppSpacing.md),
            const SchoolFilter(
              label: 'Sekolah Pembayaran',
              allLabel: 'Pilih Sekolah',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (trackedPayment == null)
            AppCard(
              child: AppEmptyState(
                icon: Icons.payments_outlined,
                message: 'Belum ada pembayaran',
                subtitle: schoolId == null || schoolId.isEmpty
                    ? 'Pilih sekolah lalu lanjutkan dari halaman paket.'
                    : 'Buat pembayaran dari halaman paket untuk mulai memantau statusnya.',
                ctaLabel: 'Buka Paket',
                onCta: () => context.go(RouteNames.subscription),
              ),
            )
          else if (!_hasLoadedInitialStatus && _isRefreshing)
            const AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(
                  message: 'Mengecek status pembayaran terbaru...',
                ),
              ),
            )
          else
            _buildPaymentContent(
              context: context,
              payment: trackedPayment,
              plansAsync: plansAsync,
              isCompact: isCompact,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent({
    required BuildContext context,
    required SubscriptionPayment payment,
    required AsyncValue<List<SubscriptionPlan>> plansAsync,
    required bool isCompact,
  }) {
    final planName = plansAsync.maybeWhen(
      data: (plans) {
        SubscriptionPlan? plan;
        for (final entry in plans) {
          if (entry.id == payment.planId) {
            plan = entry;
            break;
          }
        }
        return plan?.displayName ?? payment.planId;
      },
      orElse: () => payment.planId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          AppCard(
            color: AppColors.white,
            child: AppErrorState(
              message: _errorMessage!,
              onRetry: () => _refreshPaymentStatus(showLoader: true),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _buildStatusSummary(payment),
        const SizedBox(height: AppSpacing.lg),
        _buildPaymentDetailCard(payment, planName, isCompact),
        const SizedBox(height: AppSpacing.lg),
        _buildActionCard(context, payment, isCompact),
      ],
    );
  }

  Widget _buildStatusSummary(SubscriptionPayment payment) {
    final remaining = _remainingPollingTime;
    final statusColor = payment.isPaid
        ? AppColors.success
        : payment.isFinal
        ? AppColors.neutral500
        : AppColors.warning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.lgAll,
                ),
                child: Icon(_statusIcon(payment.status), color: statusColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pembayaran',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      payment.isFinal
                          ? 'Ringkasan pembayaran terakhir sekolah'
                          : 'Pantau hingga pembayaran selesai diproses',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(payment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              _summaryMetric('Nominal', _formatIdr(payment.amount)),
              _summaryMetric('Siklus', payment.cycle.label),
              if (payment.paymentType.isNotEmpty)
                _summaryMetric('Metode', payment.paymentType),
              _summaryMetric('Kadaluarsa', _formatDateTime(payment.expiresAt)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.neutral100),
            ),
            child: Text(
              payment.isFinal
                  ? _finalStatusMessage(payment.status)
                  : _pollingTimedOut
                  ? 'Pemeriksaan otomatis dihentikan setelah ${_formatDuration(_pollTimeout)}. Gunakan tombol perbarui status untuk mengecek kembali.'
                  : 'Status akan diperbarui otomatis. Sisa waktu pemantauan: ${_formatDuration(remaining)}.',
              style: AppTextStyles.bodySm.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailCard(
    SubscriptionPayment payment,
    String planName,
    bool isCompact,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isCompact)
            Column(
              children: [
                _detailRow('Paket', planName.isEmpty ? '-' : planName),
                _detailRow('Periode', payment.cycle.label),
                _detailRow('Dibuat', _formatDateTime(payment.createdAt)),
                _detailRow('Dibayar', _formatDateTime(payment.paidAt)),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _detailRow('Paket', planName.isEmpty ? '-' : planName),
                      _detailRow('Periode', payment.cycle.label),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    children: [
                      _detailRow('Dibuat', _formatDateTime(payment.createdAt)),
                      _detailRow('Dibayar', _formatDateTime(payment.paidAt)),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            payment.status == PaymentStatus.pending
                ? 'Jika jendela pembayaran tertutup, Anda masih bisa membukanya kembali dari tombol di bawah.'
                : payment.status == PaymentStatus.paid
                ? 'Pembayaran telah selesai dan paket sekolah akan menyesuaikan secara otomatis.'
                : 'Jika diperlukan, Anda dapat kembali ke halaman paket untuk membuat pembayaran baru.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    SubscriptionPayment payment,
    bool isCompact,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tindakan',
            style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Gunakan tombol berikut untuk melanjutkan pembayaran atau memeriksa status terbaru.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.primary(
                  label: 'Buka Halaman Pembayaran',
                  onPressed: payment.canResumeCheckout
                      ? () => _openPaymentPage(payment)
                      : null,
                  isLoading: false,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.secondary(
                  label: 'Perbarui Status',
                  onPressed: () => _refreshPaymentStatus(showLoader: true),
                  isLoading: _isRefreshing,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.secondary(
                  label: 'Salin Link Pembayaran',
                  onPressed: payment.providerRedirectUrl.isEmpty
                      ? null
                      : () => _copyPaymentLink(payment.providerRedirectUrl),
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.secondary(
                  label: 'Kembali ke Paket',
                  onPressed: () => context.go(RouteNames.subscription),
                  isFullWidth: true,
                ),
              ],
            )
          else
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppButton.primary(
                  label: 'Buka Halaman Pembayaran',
                  onPressed: payment.canResumeCheckout
                      ? () => _openPaymentPage(payment)
                      : null,
                  isLoading: false,
                ),
                AppButton.secondary(
                  label: 'Perbarui Status',
                  onPressed: () => _refreshPaymentStatus(showLoader: true),
                  isLoading: _isRefreshing,
                ),
                AppButton.secondary(
                  label: 'Salin Link Pembayaran',
                  onPressed: payment.providerRedirectUrl.isEmpty
                      ? null
                      : () => _copyPaymentLink(payment.providerRedirectUrl),
                ),
                AppButton.secondary(
                  label: 'Kembali ke Paket',
                  onPressed: () => context.go(RouteNames.subscription),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMdSemiBold.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.pending => const AppBadge(
        label: 'PENDING',
        status: BadgeStatus.warning,
      ),
      PaymentStatus.paid => const AppBadge(
        label: 'PAID',
        status: BadgeStatus.success,
      ),
      PaymentStatus.failed => const AppBadge(
        label: 'FAILED',
        status: BadgeStatus.error,
      ),
      PaymentStatus.expired => const AppBadge(
        label: 'EXPIRED',
        status: BadgeStatus.muted,
      ),
      PaymentStatus.cancelled => const AppBadge(
        label: 'CANCELLED',
        status: BadgeStatus.error,
      ),
      PaymentStatus.unknown => const AppBadge(
        label: 'UNKNOWN',
        status: BadgeStatus.muted,
      ),
    };
  }

  void _trackPayment(
    SubscriptionPayment payment, {
    required bool refreshImmediately,
  }) {
    _pollTimer?.cancel();
    setState(() {
      _payment = payment;
      _pollingElapsed = Duration.zero;
      _pollingTimedOut = false;
      _errorMessage = null;
      _hasLoadedInitialStatus = !refreshImmediately;
    });
    ref.read(activeSubscriptionPaymentProvider.notifier).state = payment;

    if (payment.isFinal) return;

    if (refreshImmediately) {
      unawaited(_refreshPaymentStatus(showLoader: false));
    }

    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (_payment == null || _payment!.isFinal) {
        _pollTimer?.cancel();
        return;
      }

      final nextElapsed = _pollingElapsed + _pollInterval;
      if (nextElapsed >= _pollTimeout) {
        if (!mounted) return;
        setState(() {
          _pollingElapsed = _pollTimeout;
          _pollingTimedOut = true;
        });
        _pollTimer?.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          _pollingElapsed = nextElapsed;
        });
      }

      unawaited(_refreshPaymentStatus(showLoader: false));
    });
  }

  Future<void> _refreshPaymentStatus({required bool showLoader}) async {
    final current = _payment;
    if (current == null || _isRefreshing) return;

    if (showLoader && mounted) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      _isRefreshing = true;
    }

    try {
      final latest = await ref.refresh(
        subscriptionPaymentStatusProvider((
          schoolId: current.schoolId,
          paymentId: current.id,
        )).future,
      );

      final previousStatus = current.status;
      if (!mounted) return;

      setState(() {
        _payment = latest;
        _isRefreshing = false;
        _errorMessage = null;
        _hasLoadedInitialStatus = true;
      });

      ref.read(activeSubscriptionPaymentProvider.notifier).state = latest;

      if (latest.isFinal) {
        _pollTimer?.cancel();
      }

      if (latest.isPaid && previousStatus != PaymentStatus.paid) {
        AppToast.show(
          context,
          message: 'Pembayaran berhasil. Paket sekolah akan diperbarui.',
        );
      } else if (latest.status == PaymentStatus.failed &&
          previousStatus != PaymentStatus.failed) {
        AppToast.show(
          context,
          message: 'Pembayaran gagal. Silakan coba lagi bila diperlukan.',
          type: ToastType.error,
        );
      } else if (latest.status == PaymentStatus.expired &&
          previousStatus != PaymentStatus.expired) {
        AppToast.show(
          context,
          message: 'Waktu pembayaran habis. Silakan buat pembayaran baru.',
          type: ToastType.warning,
        );
      } else if (latest.status == PaymentStatus.cancelled &&
          previousStatus != PaymentStatus.cancelled) {
        AppToast.show(
          context,
          message: 'Pembayaran dibatalkan.',
          type: ToastType.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        _hasLoadedInitialStatus = true;
        _errorMessage = e.toString();
      });
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _openPaymentPage(SubscriptionPayment payment) async {
    final opened = await ExternalUrlLauncher.open(payment.providerRedirectUrl);
    if (!mounted) return;

    if (!opened) {
      AppToast.show(
        context,
        message:
            'Halaman pembayaran belum bisa dibuka otomatis. Gunakan tombol salin link pembayaran.',
        type: ToastType.warning,
      );
    }
  }

  Future<void> _copyPaymentLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    AppToast.show(
      context,
      message: 'Link pembayaran berhasil disalin.',
      type: ToastType.info,
    );
  }

  Duration get _remainingPollingTime {
    final remaining = _pollTimeout - _pollingElapsed;
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  String _finalStatusMessage(PaymentStatus status) => switch (status) {
    PaymentStatus.paid =>
      'Pembayaran sudah berhasil dan paket sekolah akan menyesuaikan secara otomatis.',
    PaymentStatus.failed =>
      'Pembayaran belum berhasil. Tidak ada perubahan paket yang diterapkan.',
    PaymentStatus.expired => 'Waktu pembayaran telah habis.',
    PaymentStatus.cancelled => 'Pembayaran dibatalkan.',
    PaymentStatus.unknown => 'Status pembayaran masih belum dapat dipastikan.',
    PaymentStatus.pending => 'Pembayaran masih menunggu penyelesaian.',
  };

  String _formatIdr(int value) {
    if (value <= 0) return '-';

    final source = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = source.length - 1; i >= 0; i--) {
      buffer.write(source[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }

    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final local = date.toLocal();
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} $month ${local.year}, $hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  IconData _statusIcon(PaymentStatus status) => switch (status) {
    PaymentStatus.pending => Icons.schedule_rounded,
    PaymentStatus.paid => Icons.check_circle_outline_rounded,
    PaymentStatus.failed => Icons.error_outline_rounded,
    PaymentStatus.expired => Icons.hourglass_disabled_rounded,
    PaymentStatus.cancelled => Icons.cancel_outlined,
    PaymentStatus.unknown => Icons.help_outline_rounded,
  };
}
