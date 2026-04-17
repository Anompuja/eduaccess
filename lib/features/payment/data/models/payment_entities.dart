enum PaymentStatus {
  paid,
  pending,
  failed,
}

class PaymentInvoice {
  final String id;
  final String invoiceNo;
  final String planName;
  final int amount;
  final DateTime issuedAt;
  final DateTime dueDate;
  final PaymentStatus status;

  const PaymentInvoice({
    required this.id,
    required this.invoiceNo,
    required this.planName,
    required this.amount,
    required this.issuedAt,
    required this.dueDate,
    required this.status,
  });
}
