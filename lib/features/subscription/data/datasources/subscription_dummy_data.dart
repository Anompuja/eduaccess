import '../models/subscription_entities.dart';

final subscriptionDummyData = SchoolSubscription(
  planName: 'EduAccess Pro School',
  description: 'Paket untuk operasional sekolah dengan akses akademik, absensi, dan laporan.',
  status: SubscriptionStatus.active,
  billingCycle: BillingCycle.yearly,
  price: 18000000,
  endDate: DateTime(2027, 3, 30),
  features: [
    SubscriptionFeature(id: 'f1', name: 'Manajemen Siswa', included: true),
    SubscriptionFeature(id: 'f2', name: 'Struktur Akademik', included: true),
    SubscriptionFeature(id: 'f3', name: 'Tracking Siswa', included: true),
    SubscriptionFeature(id: 'f4', name: 'CBT / Ujian Online', included: true),
    SubscriptionFeature(id: 'f5', name: 'Laporan & Export', included: true),
    SubscriptionFeature(id: 'f6', name: 'Integrasi Payment Gateway', included: false),
  ],
  limits: [
    SubscriptionLimit(label: 'Total Pengguna', used: 312, total: 500),
    SubscriptionLimit(label: 'Total Siswa', used: 280, total: 450),
    SubscriptionLimit(label: 'Total Guru & Staff', used: 32, total: 75),
  ],
);
