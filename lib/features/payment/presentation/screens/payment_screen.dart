import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/paginated.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/external_url_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
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
    final isSuperadmin = user?.role == UserRole.superadmin;

    if (!isSuperadmin) {
      final trackedPayment =
          _payment ?? ref.watch(activeSubscriptionPaymentProvider);

      ref.listen<String?>(currentSubscriptionSchoolIdProvider, (
        previous,
        next,
      ) {
        if (previous == next) return;
        ref.read(paymentHistoryCurrentPageProvider.notifier).state = 1;

        if (next == null || next.isEmpty) return;

        final current = ref.read(activeSubscriptionPaymentProvider);
        if (current == null || current.schoolId == next) return;

        _pollTimer?.cancel();
        ref.read(activeSubscriptionPaymentProvider.notifier).state = null;
        if (!mounted) return;
        setState(() {
          _payment = null;
          _pollingElapsed = Duration.zero;
          _pollingTimedOut = false;
          _isRefreshing = false;
          _hasLoadedInitialStatus = false;
          _errorMessage = null;
        });
      });

      if (_payment == null && trackedPayment != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _payment != null) return;
          _trackPayment(
            trackedPayment,
            refreshImmediately: !_hasLoadedInitialStatus,
          );
        });
      }
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
            isSuperadmin
                ? 'Pantau daftar pembayaran seluruh sekolah dan buka detail transaksi saat diperlukan.'
                : 'Pantau proses pembayaran paket sekolah dan lihat perkembangan statusnya secara berkala.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isSuperadmin)
            _buildSuperadminContent(context, isCompact)
          else
            _buildSchoolAdminContent(context, isCompact),
        ],
      ),
    );
  }

  Widget _buildSuperadminContent(BuildContext context, bool isCompact) {
    final activeSchool = ref.watch(activeSchoolProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);

    ref.listen(activeSchoolProvider, (_, _) {
      ref.read(paymentHistoryCurrentPageProvider.notifier).state = 1;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeSchool != null) ...[
          _buildDashboardContextCard(activeSchool.name),
          const SizedBox(height: AppSpacing.lg),
        ],
        _buildHistorySection(
          context: context,
          paymentsAsync: historyAsync,
          isCompact: isCompact,
          selectedPayment: null,
          openDetailOnView: true,
          trackPaymentOnView: false,
          showToolbar: activeSchool == null,
        ),
      ],
    );
  }

  Widget _buildSchoolAdminContent(BuildContext context, bool isCompact) {
    final schoolId = ref.watch(currentSubscriptionSchoolIdProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);
    final trackedPayment =
        _payment ?? ref.watch(activeSubscriptionPaymentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trackedPayment == null)
          _buildNoSelectionCard(context, schoolId)
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
            isCompact: isCompact,
          ),
        const SizedBox(height: AppSpacing.xl),
        _buildHistorySection(
          context: context,
          paymentsAsync: historyAsync,
          isCompact: isCompact,
          selectedPayment: trackedPayment,
          openDetailOnView: true,
          trackPaymentOnView: true,
          showToolbar: true,
        ),
      ],
    );
  }

  Widget _buildDashboardContextCard(String schoolName) {
    return AppCard(
      color: AppColors.primary100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.75),
              borderRadius: AppRadius.lgAll,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.primary700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Context sekolah mengikuti dashboard',
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Daftar pembayaran sedang difokuskan ke $schoolName. Pilih "Semua Sekolah" dari dashboard jika ingin melihat transaksi seluruh tenant.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionCard(BuildContext context, String? schoolId) {
    final canOpenSubscription = schoolId != null && schoolId.isNotEmpty;

    return AppCard(
      child: AppEmptyState(
        icon: Icons.payments_outlined,
        message: 'Belum ada pembayaran yang dipantau',
        subtitle: canOpenSubscription
            ? 'Pilih transaksi dari riwayat di bawah atau buat pembayaran baru dari halaman paket.'
            : 'Pilih transaksi dari riwayat di bawah untuk melihat detail pembayaran.',
        ctaLabel: canOpenSubscription ? 'Buka Paket' : null,
        onCta: canOpenSubscription
            ? () => context.go(RouteNames.subscription)
            : null,
      ),
    );
  }

  Widget _buildPaymentContent({
    required BuildContext context,
    required SubscriptionPayment payment,
    required bool isCompact,
  }) {
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
        _buildPaymentDetailCard(payment, isCompact),
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
              _summaryMetric('Sekolah', _displaySchool(payment)),
              _summaryMetric('Nominal', _formatIdr(payment.amount)),
              _summaryMetric('Paket', _displayPlan(payment)),
              _summaryMetric('Siklus', payment.cycle.label),
              if (payment.paymentType.isNotEmpty)
                _summaryMetric('Metode', _humanizeToken(payment.paymentType)),
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

  Widget _buildPaymentDetailCard(SubscriptionPayment payment, bool isCompact) {
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
                _detailRow('Sekolah', _displaySchool(payment)),
                _detailRow('Paket', _displayPlan(payment)),
                _detailRow('Periode', payment.cycle.label),
                _detailRow('Provider', _displayProvider(payment)),
                _detailRow('Order ID', _orDash(payment.providerOrderId)),
                _detailRow(
                  'Status Gateway',
                  _displayTransactionStatus(payment),
                ),
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
                      _detailRow('Sekolah', _displaySchool(payment)),
                      _detailRow('Paket', _displayPlan(payment)),
                      _detailRow('Periode', payment.cycle.label),
                      _detailRow('Provider', _displayProvider(payment)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    children: [
                      _detailRow('Order ID', _orDash(payment.providerOrderId)),
                      _detailRow(
                        'Status Gateway',
                        _displayTransactionStatus(payment),
                      ),
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

  Widget _buildHistorySection({
    required BuildContext context,
    required AsyncValue<Paginated<SubscriptionPayment>> paymentsAsync,
    required bool isCompact,
    required SubscriptionPayment? selectedPayment,
    required bool openDetailOnView,
    required bool trackPaymentOnView,
    required bool showToolbar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Pembayaran',
          style: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Lihat histori pembayaran sekolah, filter berdasarkan status, lalu pilih transaksi untuk dipantau.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        ),
        if (showToolbar) ...[
          const SizedBox(height: AppSpacing.md),
          _buildHistoryToolbar(isCompact),
          const SizedBox(height: AppSpacing.lg),
        ],
        paymentsAsync.when(
          loading: () => const AppCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppLoadingIndicator(
                message: 'Memuat riwayat pembayaran...',
              ),
            ),
          ),
          error: (error, _) => AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(paymentHistoryProvider),
              ),
            ),
          ),
          data: (result) => _buildHistoryTable(
            context: context,
            result: result,
            isCompact: isCompact,
            selectedPayment: selectedPayment,
            openDetailOnView: openDetailOnView,
            trackPaymentOnView: trackPaymentOnView,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryToolbar(bool isCompact) {
    final status = ref.watch(paymentHistoryStatusFilterProvider);
    final dropdown = AppDropdown<PaymentStatus?>(
      label: 'Status Pembayaran',
      value: status,
      hint: 'Semua Status',
      items: const [
        AppDropdownItem<PaymentStatus?>(value: null, label: 'Semua Status'),
        AppDropdownItem<PaymentStatus?>(
          value: PaymentStatus.pending,
          label: 'Pending',
        ),
        AppDropdownItem<PaymentStatus?>(
          value: PaymentStatus.paid,
          label: 'Paid',
        ),
        AppDropdownItem<PaymentStatus?>(
          value: PaymentStatus.failed,
          label: 'Failed',
        ),
        AppDropdownItem<PaymentStatus?>(
          value: PaymentStatus.expired,
          label: 'Expired',
        ),
        AppDropdownItem<PaymentStatus?>(
          value: PaymentStatus.cancelled,
          label: 'Cancelled',
        ),
      ],
      onChanged: _setHistoryStatusFilter,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchBar(
            hint: 'Cari sekolah, paket, atau order ID...',
            width: double.infinity,
            onSearch: _setHistorySearchQuery,
          ),
          const SizedBox(height: AppSpacing.md),
          dropdown,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 320,
          child: AppSearchBar(
            hint: 'Cari sekolah, paket, atau order ID...',
            width: 320,
            onSearch: _setHistorySearchQuery,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: dropdown),
      ],
    );
  }

  Widget _buildHistoryTable({
    required BuildContext context,
    required Paginated<SubscriptionPayment> result,
    required bool isCompact,
    required SubscriptionPayment? selectedPayment,
    required bool openDetailOnView,
    required bool trackPaymentOnView,
  }) {
    if (result.items.isEmpty) {
      final search = ref.read(paymentHistorySearchQueryProvider);
      final status = ref.read(paymentHistoryStatusFilterProvider);
      final hasFilter = search.isNotEmpty || status != null;

      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AppEmptyState(
            icon: Icons.receipt_long_outlined,
            message: hasFilter
                ? 'Tidak ada pembayaran yang sesuai filter'
                : 'Belum ada riwayat pembayaran',
            subtitle: hasFilter
                ? 'Ubah kata kunci pencarian atau status untuk melihat data lain.'
                : 'Riwayat pembayaran sekolah akan muncul di halaman ini setelah transaksi dibuat.',
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: AppColors.neutral100),
                    child: DataTable(
                      columnSpacing: isCompact ? 12 : 24,
                      horizontalMargin: AppSpacing.md,
                      headingRowHeight: isCompact ? 42 : 48,
                      dataRowMinHeight: isCompact ? 60 : 64,
                      dataRowMaxHeight: isCompact ? 60 : 64,
                      dividerThickness: 1,
                      headingTextStyle: AppTextStyles.label.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                      dataTextStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w500,
                      ),
                      columns: [
                        DataColumn(label: _tableHeader('No', width: 64)),
                        DataColumn(label: _tableHeader('Sekolah', width: 220)),
                        DataColumn(
                          label: _tableHeader('Paket / Order', width: 220),
                        ),
                        DataColumn(label: _tableHeader('Nominal', width: 140)),
                        DataColumn(label: _tableHeader('Status', width: 120)),
                        DataColumn(label: _tableHeader('Dibuat', width: 160)),
                        DataColumn(label: _tableHeader('Aksi', width: 110)),
                      ],
                      rows: result.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final payment = entry.value;
                        final isSelected =
                            selectedPayment?.id == payment.id &&
                            selectedPayment?.schoolId == payment.schoolId;

                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '${(result.page - 1) * paymentHistoryPerPage + index + 1}',
                                  style: AppTextStyles.bodyMdSemiBold.copyWith(
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Text(
                                  _displaySchool(payment),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 220,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayPlan(payment),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _orDash(payment.providerOrderId),
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.neutral500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 140,
                                child: Text(_formatIdr(payment.amount)),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _statusBadge(payment.status),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 160,
                                child: Text(_formatDateTime(payment.createdAt)),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 110,
                                child: Row(
                                  children: [
                                    _actionIconButton(
                                      icon: isSelected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.visibility_outlined,
                                      backgroundColor: isSelected
                                          ? AppColors.primary700
                                          : AppColors.info,
                                      onTap: () async {
                                        if (trackPaymentOnView) {
                                          _trackPayment(
                                            payment,
                                            refreshImmediately:
                                                !payment.isFinal,
                                          );
                                        }
                                        if (!openDetailOnView) return;
                                        await _showPaymentDetailDialog(
                                          context,
                                          payment,
                                        );
                                      },
                                    ),
                                    if (payment.canResumeCheckout) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      _actionIconButton(
                                        icon: Icons.open_in_new_rounded,
                                        backgroundColor: AppColors.warning,
                                        onTap: () => _openPaymentPage(payment),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Halaman ${result.page} dari ${result.totalPages}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: AppPagination(
                    currentPage: result.page,
                    totalPages: result.totalPages,
                    onPageChanged: _setHistoryPage,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Halaman ${result.page} dari ${result.totalPages}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppPagination(
                  currentPage: result.page,
                  totalPages: result.totalPages,
                  onPageChanged: _setHistoryPage,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDetailDialog(
    BuildContext context,
    SubscriptionPayment payment,
  ) async {
    var current = payment;
    var refreshing = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AppDialog(
            title: 'Detail Pembayaran',
            subtitle: _displaySchool(current),
            content: Column(
              children: [
                _detailRow('Sekolah', _displaySchool(current)),
                _detailRow('Paket', _displayPlan(current)),
                _detailRow('Status', current.status.label),
                _detailRow('Siklus', current.cycle.label),
                _detailRow('Nominal', _formatIdr(current.amount)),
                _detailRow('Provider', _displayProvider(current)),
                _detailRow('Order ID', _orDash(current.providerOrderId)),
                _detailRow(
                  'Status Gateway',
                  _displayTransactionStatus(current),
                ),
                _detailRow('Dibayar', _formatDateTime(current.paidAt)),
                _detailRow('Kadaluarsa', _formatDateTime(current.expiresAt)),
                _detailRow('Dibuat', _formatDateTime(current.createdAt)),
              ],
            ),
            actions: [
              AppButton.secondary(
                label: 'Tutup',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              AppButton.secondary(
                label: 'Salin Link',
                onPressed: current.providerRedirectUrl.isEmpty
                    ? null
                    : () => _copyPaymentLink(current.providerRedirectUrl),
              ),
              AppButton.secondary(
                label: 'Refresh Status',
                isLoading: refreshing,
                onPressed: () async {
                  setDialogState(() => refreshing = true);
                  try {
                    final latest = await ref.refresh(
                      subscriptionPaymentStatusProvider((
                        schoolId: current.schoolId,
                        paymentId: current.id,
                      )).future,
                    );

                    if (!mounted) return;
                    setDialogState(() => current = latest);

                    final tracked = ref.read(activeSubscriptionPaymentProvider);
                    if (tracked != null &&
                        tracked.id == latest.id &&
                        tracked.schoolId == latest.schoolId) {
                      _trackPayment(latest, refreshImmediately: false);
                    }
                  } catch (e) {
                    if (!mounted) return;
                    AppToast.show(
                      this.context,
                      message: e.toString(),
                      type: ToastType.error,
                    );
                  } finally {
                    if (dialogContext.mounted) {
                      setDialogState(() => refreshing = false);
                    }
                  }
                },
              ),
              AppButton.primary(
                label: 'Buka Pembayaran',
                onPressed: current.canResumeCheckout
                    ? () => _openPaymentPage(current)
                    : null,
              ),
            ],
          ),
        );
      },
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

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _actionIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  void _setHistorySearchQuery(String value) {
    ref.read(paymentHistorySearchQueryProvider.notifier).state = value
        .trim()
        .toLowerCase();
    ref.read(paymentHistoryCurrentPageProvider.notifier).state = 1;
  }

  void _setHistoryStatusFilter(PaymentStatus? status) {
    ref.read(paymentHistoryStatusFilterProvider.notifier).state = status;
    ref.read(paymentHistoryCurrentPageProvider.notifier).state = 1;
  }

  void _setHistoryPage(int page) {
    ref.read(paymentHistoryCurrentPageProvider.notifier).state = page;
  }

  String _displaySchool(SubscriptionPayment payment) =>
      _orDash(payment.displaySchoolName);

  String _displayPlan(SubscriptionPayment payment) =>
      _orDash(payment.displayPlanName);

  String _displayProvider(SubscriptionPayment payment) =>
      _orDash(_humanizeToken(payment.provider));

  String _displayTransactionStatus(SubscriptionPayment payment) {
    if (payment.transactionStatus.trim().isNotEmpty) {
      return _humanizeToken(payment.transactionStatus);
    }
    return _orDash(payment.status.label);
  }

  String _humanizeToken(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '-';

    final words = trimmed
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        );

    final result = words.join(' ');
    return result.isEmpty ? '-' : result;
  }

  String _orDash(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
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
