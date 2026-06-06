enum SubscriptionStatus {
  active,
  inactive,
  trial,
  expired,
  cancelled,
  unknown;

  static SubscriptionStatus fromString(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'active' => SubscriptionStatus.active,
        'inactive' => SubscriptionStatus.inactive,
        'trial' => SubscriptionStatus.trial,
        'expired' => SubscriptionStatus.expired,
        'cancelled' || 'canceled' => SubscriptionStatus.cancelled,
        _ => SubscriptionStatus.unknown,
      };

  String get label => switch (this) {
    SubscriptionStatus.active => 'ACTIVE',
    SubscriptionStatus.inactive => 'INACTIVE',
    SubscriptionStatus.trial => 'TRIAL',
    SubscriptionStatus.expired => 'EXPIRED',
    SubscriptionStatus.cancelled => 'CANCELLED',
    SubscriptionStatus.unknown => 'UNKNOWN',
  };
}

enum BillingCycle {
  monthly,
  yearly,
  oneTime,
  unknown;

  static BillingCycle fromString(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'monthly' || 'month' => BillingCycle.monthly,
        'yearly' || 'annual' || 'annually' || 'year' => BillingCycle.yearly,
        'one_time' || 'one-time' || 'lifetime' => BillingCycle.oneTime,
        _ => BillingCycle.unknown,
      };

  String get label => switch (this) {
    BillingCycle.monthly => 'Bulanan',
    BillingCycle.yearly => 'Tahunan',
    BillingCycle.oneTime => 'Sekali Bayar',
    BillingCycle.unknown => 'Belum diketahui',
  };
}

enum SubscriptionTier {
  trial,
  basic,
  pro,
  enterprise,
  custom;

  static SubscriptionTier fromPlan({
    required String name,
    required String code,
  }) {
    final normalized = '${name.trim()} ${code.trim()}'.toLowerCase();
    if (normalized.contains('trial')) return SubscriptionTier.trial;
    if (normalized.contains('enterprise')) return SubscriptionTier.enterprise;
    if (normalized.contains('pro')) return SubscriptionTier.pro;
    if (normalized.contains('basic')) return SubscriptionTier.basic;
    return SubscriptionTier.custom;
  }

  String get label => switch (this) {
    SubscriptionTier.trial => 'Trial',
    SubscriptionTier.basic => 'Basic',
    SubscriptionTier.pro => 'Pro',
    SubscriptionTier.enterprise => 'Enterprise',
    SubscriptionTier.custom => 'Custom',
  };

  int get sortOrder => switch (this) {
    SubscriptionTier.trial => 0,
    SubscriptionTier.basic => 1,
    SubscriptionTier.pro => 2,
    SubscriptionTier.enterprise => 3,
    SubscriptionTier.custom => 4,
  };
}

class SubscriptionPlan {
  final String id;
  final String code;
  final String name;
  final String description;
  final BillingCycle billingCycle;
  final int price;
  final int maxStudents;
  final bool isActive;
  final SubscriptionTier tier;

  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.billingCycle,
    required this.price,
    required this.maxStudents,
    required this.isActive,
    required this.tier,
  });

  bool matches(SubscriptionPlan other) {
    if (id.isNotEmpty && other.id.isNotEmpty && id == other.id) return true;
    if (code.isNotEmpty && other.code.isNotEmpty && code == other.code) {
      return true;
    }
    return _normalizedIdentity == other._normalizedIdentity;
  }

  String get displayName => name.isNotEmpty ? name : tier.label;

  bool get isSelectable => tier != SubscriptionTier.trial;

  String get _normalizedIdentity =>
      '${name.trim().toLowerCase()}::${code.trim().toLowerCase()}';
}

class SchoolSubscription {
  final String id;
  final String schoolId;
  final String schoolName;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final SubscriptionPlan plan;

  const SchoolSubscription({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.plan,
  });
}

class SchoolSubscriptionOverview {
  final SchoolSubscription subscription;
  final int studentsUsed;

  const SchoolSubscriptionOverview({
    required this.subscription,
    required this.studentsUsed,
  });

  SubscriptionPlan get plan => subscription.plan;

  int get studentsLimit => plan.maxStudents;

  int get remainingStudents {
    if (studentsLimit <= 0) return 0;
    final remaining = studentsLimit - studentsUsed;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    if (studentsLimit <= 0) return 0;
    final ratio = studentsUsed / studentsLimit;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get isAtCapacity => studentsLimit > 0 && studentsUsed >= studentsLimit;

  bool get isNearCapacity => !isAtCapacity && progress >= 0.85;
}
