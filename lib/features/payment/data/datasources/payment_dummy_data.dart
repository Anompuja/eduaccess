import '../models/payment_entities.dart';

final paymentDummyInvoices = <PaymentInvoice>[
  PaymentInvoice(
    id: 'inv_001',
    invoiceNo: 'INV-EDU-2026-001',
    planName: 'EduAccess Pro School',
    amount: 18000000,
    issuedAt: DateTime(2026, 1, 2),
    dueDate: DateTime(2026, 1, 15),
    status: PaymentStatus.paid,
  ),
  PaymentInvoice(
    id: 'inv_002',
    invoiceNo: 'INV-EDU-2026-002',
    planName: 'EduAccess Pro School',
    amount: 18000000,
    issuedAt: DateTime(2026, 4, 1),
    dueDate: DateTime(2026, 4, 15),
    status: PaymentStatus.pending,
  ),
  PaymentInvoice(
    id: 'inv_003',
    invoiceNo: 'INV-EDU-2025-004',
    planName: 'EduAccess Pro School',
    amount: 15000000,
    issuedAt: DateTime(2025, 10, 1),
    dueDate: DateTime(2025, 10, 14),
    status: PaymentStatus.failed,
  ),
];
