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

enum SchoolDirectoryStatus {
  active,
  nonactive,
  unknown;

  static SchoolDirectoryStatus fromString(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'active' => SchoolDirectoryStatus.active,
        'nonactive' || 'inactive' => SchoolDirectoryStatus.nonactive,
        _ => SchoolDirectoryStatus.unknown,
      };

  String get label => switch (this) {
    SchoolDirectoryStatus.active => 'ACTIVE',
    SchoolDirectoryStatus.nonactive => 'NONACTIVE',
    SchoolDirectoryStatus.unknown => 'UNKNOWN',
  };

  String get apiValue => switch (this) {
    SchoolDirectoryStatus.active => 'active',
    SchoolDirectoryStatus.nonactive => 'nonactive',
    SchoolDirectoryStatus.unknown => '',
  };
}

enum BillingCycle {
  monthly,
  yearly,
  unknown;

  static BillingCycle fromString(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'monthly' || 'month' => BillingCycle.monthly,
        'yearly' || 'annual' || 'annually' || 'year' => BillingCycle.yearly,
        _ => BillingCycle.unknown,
      };

  String get label => switch (this) {
    BillingCycle.monthly => 'Bulanan',
    BillingCycle.yearly => 'Tahunan',
    BillingCycle.unknown => 'Belum diketahui',
  };

  String get apiValue => switch (this) {
    BillingCycle.monthly => 'month',
    BillingCycle.yearly => 'year',
    BillingCycle.unknown => '',
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
  final List<String> features;
  final int monthlyPrice;
  final int yearlyPrice;
  final int maxStudents;
  final bool isActive;
  final SubscriptionTier tier;

  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.features,
    required this.monthlyPrice,
    required this.yearlyPrice,
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

  List<BillingCycle> get availableCycles => [
    if (monthlyPrice > 0) BillingCycle.monthly,
    if (yearlyPrice > 0) BillingCycle.yearly,
  ];

  bool supportsCycle(BillingCycle cycle) => availableCycles.contains(cycle);

  int priceForCycle(BillingCycle cycle) => switch (cycle) {
    BillingCycle.monthly => monthlyPrice,
    BillingCycle.yearly => yearlyPrice,
    BillingCycle.unknown => 0,
  };

  bool get hasPaidCycle => availableCycles.isNotEmpty;

  bool get isSelectable => tier != SubscriptionTier.trial && hasPaidCycle;

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
  final BillingCycle cycle;
  final int price;
  final int quantity;
  final SubscriptionPlan plan;

  const SchoolSubscription({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.cycle,
    required this.price,
    required this.quantity,
    required this.plan,
  });

  int get currentPrice {
    if (price > 0) return price;
    return plan.priceForCycle(cycle);
  }
}

class SchoolSubscriptionRecord {
  final String id;
  final String name;
  final SchoolDirectoryStatus status;
  final SchoolSubscription? subscription;

  const SchoolSubscriptionRecord({
    required this.id,
    required this.name,
    required this.status,
    required this.subscription,
  });

  bool get hasSubscription =>
      subscription != null &&
      (subscription!.id.isNotEmpty ||
          subscription!.plan.id.isNotEmpty ||
          subscription!.plan.name.isNotEmpty);

  String get displayName => name.trim().isNotEmpty ? name : id;
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
