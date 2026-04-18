import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/datasources/payment_dummy_data.dart';
import '../../data/models/payment_entities.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _statusFilter = 'all';

  List<PaymentInvoice> get _rows {
    if (_statusFilter == 'all') return paymentDummyInvoices;
    return paymentDummyInvoices.where((e) => e.status.name == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
    final rows = _rows;

    return SingleChildScrollView(
      padding: isCompact ? const EdgeInsets.all(AppSpacing.lg) : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment', style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Riwayat pembayaran dan status invoice sekolah (dummy data).',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSummary(),
          const SizedBox(height: AppSpacing.lg),
          _buildFilters(isCompact),
          const SizedBox(height: AppSpacing.md),
          _buildTable(rows),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final paid = paymentDummyInvoices.where((e) => e.status == PaymentStatus.paid).length;
    final pending = paymentDummyInvoices.where((e) => e.status == PaymentStatus.pending).length;
    final failed = paymentDummyInvoices.where((e) => e.status == PaymentStatus.failed).length;

    return AppCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          _summaryItem('Paid', '$paid', AppColors.success),
          _summaryItem('Pending', '$pending', AppColors.warning),
          _summaryItem('Failed', '$failed', AppColors.error),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral700)),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          AppDropdown<String>(
            label: 'Status Invoice',
            value: _statusFilter,
            items: const [
              AppDropdownItem(value: 'all', label: 'Semua'),
              AppDropdownItem(value: 'paid', label: 'Paid'),
              AppDropdownItem(value: 'pending', label: 'Pending'),
              AppDropdownItem(value: 'failed', label: 'Failed'),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              label: 'Simulasi Bayar Baru',
              onPressed: _showPaymentInfo,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 220,
          child: AppDropdown<String>(
            label: 'Status Invoice',
            value: _statusFilter,
            items: const [
              AppDropdownItem(value: 'all', label: 'Semua'),
              AppDropdownItem(value: 'paid', label: 'Paid'),
              AppDropdownItem(value: 'pending', label: 'Pending'),
              AppDropdownItem(value: 'failed', label: 'Failed'),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
            },
          ),
        ),
        const Spacer(),
        AppButton.primary(
          label: 'Simulasi Bayar Baru',
          onPressed: _showPaymentInfo,
        ),
      ],
    );
  }

  Widget _buildTable(List<PaymentInvoice> rows) {
    return AppCard(
      child: rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: AppEmptyState(message: 'Tidak ada invoice untuk filter saat ini.'),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = Responsive.isMobile(context) || Responsive.isTablet(context);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: AppColors.neutral100),
                      child: DataTable(
                        columnSpacing: isCompact ? 12 : 24,
                        horizontalMargin: AppSpacing.md,
                        headingRowHeight: isCompact ? 42 : 48,
                        dataRowMinHeight: isCompact ? 50 : 54,
                        dataRowMaxHeight: isCompact ? 50 : 54,
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
                          DataColumn(label: _tableHeader('Invoice', width: 180)),
                          DataColumn(label: _tableHeader('Plan', width: 190)),
                          DataColumn(label: _tableHeader('Amount', width: 120)),
                          DataColumn(label: _tableHeader('Issued', width: 110)),
                          DataColumn(label: _tableHeader('Due', width: 110)),
                          DataColumn(label: _tableHeader('Status', width: 110)),
                        ],
                        rows: rows.map((row) {
                          return DataRow(
                            cells: [
                              DataCell(_cellBox(row.invoiceNo, width: 180)),
                              DataCell(_cellBox(row.planName, width: 190)),
                              DataCell(_cellBox(_formatIdr(row.amount), width: 120)),
                              DataCell(_cellBox(_formatDate(row.issuedAt), width: 110)),
                              DataCell(_cellBox(_formatDate(row.dueDate), width: 110)),
                              DataCell(
                                SizedBox(
                                  width: 110,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _statusBadge(row.status),
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
    );
  }

  Widget _statusBadge(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.paid => const AppBadge(label: 'PAID', status: BadgeStatus.success),
      PaymentStatus.pending => const AppBadge(label: 'PENDING', status: BadgeStatus.warning),
      PaymentStatus.failed => const AppBadge(label: 'FAILED', status: BadgeStatus.error),
    };
  }

  Widget _tableHeader(String label, {double? width}) {
    final header = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (width == null) return header;
    return SizedBox(width: width, child: header);
  }

  Widget _cellBox(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  void _showPaymentInfo() {
    AppToast.show(
      context,
      message: 'Payment gateway belum tersedia. Saat ini masih simulasi UI.',
      type: ToastType.info,
    );
  }

  String _formatIdr(int value) {
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
