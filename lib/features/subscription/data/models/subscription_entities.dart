enum SubscriptionStatus {
  active,
  inactive,
  trial,
  expired,
  cancelled,
}

enum BillingCycle {
  monthly,
  yearly,
  oneTime,
}

class SubscriptionFeature {
  final String id;
  final String name;
  final bool included;

  const SubscriptionFeature({
    required this.id,
    required this.name,
    required this.included,
  });
}

class SubscriptionLimit {
  final String label;
  final int used;
  final int total;

  const SubscriptionLimit({
    required this.label,
    required this.used,
    required this.total,
  });

  double get progress {
    if (total <= 0) return 0;
    final value = used / total;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}

class SchoolSubscription {
  final String planName;
  final String description;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final int price;
  final DateTime endDate;
  final List<SubscriptionFeature> features;
  final List<SubscriptionLimit> limits;

  const SchoolSubscription({
    required this.planName,
    required this.description,
    required this.status,
    required this.billingCycle,
    required this.price,
    required this.endDate,
    required this.features,
    required this.limits,
  });
}
