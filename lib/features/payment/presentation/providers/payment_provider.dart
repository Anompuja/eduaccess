import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/data/models/subscription_entities.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/models/payment_entities.dart';
import '../../data/repositories/payment_repository_impl.dart';

typedef PaymentLookupParams = ({String schoolId, String paymentId});
typedef CheckoutParams = ({String schoolId, String planId, BillingCycle cycle});

final paymentRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepositoryImpl(PaymentRemoteDataSource(dio));
});

final activeSubscriptionPaymentProvider = StateProvider<SubscriptionPayment?>(
  (ref) => null,
);

final createSubscriptionCheckoutProvider = FutureProvider.autoDispose
    .family<SubscriptionPayment, CheckoutParams>((ref, params) async {
      final repository = ref.watch(paymentRepositoryProvider);
      final payment = await repository.createCheckout(
        schoolId: params.schoolId,
        planId: params.planId,
        cycle: params.cycle,
      );

      ref.read(activeSubscriptionPaymentProvider.notifier).state = payment;
      return payment;
    });

final subscriptionPaymentStatusProvider = FutureProvider.autoDispose
    .family<SubscriptionPayment, PaymentLookupParams>((ref, params) async {
      final repository = ref.watch(paymentRepositoryProvider);
      final payment = await repository.getPaymentStatus(
        schoolId: params.schoolId,
        paymentId: params.paymentId,
      );

      final current = ref.read(activeSubscriptionPaymentProvider);
      if (current == null ||
          current.id == payment.id ||
          current.schoolId == payment.schoolId) {
        ref.read(activeSubscriptionPaymentProvider.notifier).state = payment;
      }

      if (payment.isPaid) {
        invalidateSubscriptionPaymentScope(ref, payment.schoolId);
      }

      return payment;
    });

void invalidateSubscriptionPaymentScope(Ref ref, String schoolId) {
  ref.invalidate(schoolSubscriptionProvider(schoolId));
  ref.invalidate(
    schoolSubscriptionOverviewProvider((
      schoolId: schoolId,
      includeSchoolIdQuery: true,
    )),
  );
  ref.invalidate(
    schoolSubscriptionOverviewProvider((
      schoolId: schoolId,
      includeSchoolIdQuery: false,
    )),
  );
  ref.invalidate(currentSchoolSubscriptionOverviewProvider);
  ref.invalidate(dashboardStatsProvider);
}
