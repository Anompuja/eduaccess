import '../../../subscription/data/models/subscription_entities.dart';

enum PaymentStatus {
  pending,
  paid,
  failed,
  expired,
  cancelled,
  unknown;

  static PaymentStatus fromString(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'pending' => PaymentStatus.pending,
        'paid' => PaymentStatus.paid,
        'failed' => PaymentStatus.failed,
        'expired' => PaymentStatus.expired,
        'cancelled' || 'canceled' => PaymentStatus.cancelled,
        _ => PaymentStatus.unknown,
      };

  String get label => switch (this) {
    PaymentStatus.pending => 'PENDING',
    PaymentStatus.paid => 'PAID',
    PaymentStatus.failed => 'FAILED',
    PaymentStatus.expired => 'EXPIRED',
    PaymentStatus.cancelled => 'CANCELLED',
    PaymentStatus.unknown => 'UNKNOWN',
  };

  bool get isFinal => switch (this) {
    PaymentStatus.pending => false,
    PaymentStatus.paid ||
    PaymentStatus.failed ||
    PaymentStatus.expired ||
    PaymentStatus.cancelled ||
    PaymentStatus.unknown => true,
  };
}

class SubscriptionPayment {
  final String id;
  final String schoolId;
  final String planId;
  final String createdByUserId;
  final String activatedSubscriptionId;
  final PaymentStatus status;
  final BillingCycle cycle;
  final int amount;
  final String currency;
  final String provider;
  final String providerOrderId;
  final String providerTransactionId;
  final String providerSnapToken;
  final String providerRedirectUrl;
  final String paymentType;
  final String transactionStatus;
  final String fraudStatus;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubscriptionPayment({
    required this.id,
    required this.schoolId,
    required this.planId,
    required this.createdByUserId,
    required this.activatedSubscriptionId,
    required this.status,
    required this.cycle,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.providerOrderId,
    required this.providerTransactionId,
    required this.providerSnapToken,
    required this.providerRedirectUrl,
    required this.paymentType,
    required this.transactionStatus,
    required this.fraudStatus,
    required this.paidAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFinal => status.isFinal;

  bool get isPending => status == PaymentStatus.pending;

  bool get isPaid => status == PaymentStatus.paid;

  bool get canResumeCheckout =>
      isPending && providerRedirectUrl.trim().isNotEmpty && !isExpired;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!.toLocal());
}
