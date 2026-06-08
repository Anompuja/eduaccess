import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/paginated.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/data/models/subscription_entities.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/models/payment_entities.dart';
import '../../data/repositories/payment_repository_impl.dart';

typedef PaymentLookupParams = ({String schoolId, String paymentId});
typedef CheckoutParams = ({String schoolId, String planId, BillingCycle cycle});

const paymentHistoryPerPage = 10;

final paymentRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepositoryImpl(PaymentRemoteDataSource(dio));
});

final activeSubscriptionPaymentProvider = StateProvider<SubscriptionPayment?>(
  (ref) => null,
);

final paymentHistoryCurrentPageProvider = StateProvider<int>((ref) => 1);

final paymentHistorySearchQueryProvider = StateProvider<String>((ref) => '');

final paymentHistoryStatusFilterProvider = StateProvider<PaymentStatus?>(
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
      ref.invalidate(paymentHistoryProvider);
      return payment;
    });

final subscriptionPaymentStatusProvider = FutureProvider.autoDispose
    .family<SubscriptionPayment, PaymentLookupParams>((ref, params) async {
      final repository = ref.watch(paymentRepositoryProvider);
      final current = ref.read(activeSubscriptionPaymentProvider);
      final payment = await repository.getPaymentStatus(
        schoolId: params.schoolId,
        paymentId: params.paymentId,
      );

      if (current == null ||
          (current.id == payment.id && current.schoolId == payment.schoolId)) {
        ref.read(activeSubscriptionPaymentProvider.notifier).state = payment;
      }

      final hasMeaningfulChange =
          current == null ||
          current.status != payment.status ||
          current.updatedAt != payment.updatedAt;
      if (hasMeaningfulChange) {
        ref.invalidate(paymentHistoryProvider);
      }

      if (payment.isPaid) {
        invalidateSubscriptionPaymentScope(ref, payment.schoolId);
      }

      return payment;
    });

final paymentHistoryProvider =
    FutureProvider.autoDispose<Paginated<SubscriptionPayment>>((ref) async {
      final repository = ref.watch(paymentRepositoryProvider);
      final page = ref.watch(paymentHistoryCurrentPageProvider);
      final search = ref.watch(paymentHistorySearchQueryProvider);
      final status = ref.watch(paymentHistoryStatusFilterProvider);
      final user = ref.watch(currentUserProvider);
      final activeSchool = ref.watch(activeSchoolProvider);

      final schoolId = switch (user?.role) {
        UserRole.superadmin => activeSchool?.id,
        _ => user?.schoolId,
      };

      return repository.getPaymentHistory(
        page: page,
        perPage: paymentHistoryPerPage,
        schoolId: schoolId,
        search: search.isNotEmpty ? search : null,
        status: status,
      );
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
  ref.invalidate(schoolSubscriptionRecordsProvider);
  ref.invalidate(dashboardStatsProvider);
}
