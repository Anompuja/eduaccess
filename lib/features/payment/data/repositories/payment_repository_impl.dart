import '../../../../core/api/paginated.dart';
import '../../../subscription/data/models/subscription_entities.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/payment_entities.dart';

class PaymentRepositoryImpl {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  Future<SubscriptionPayment> createCheckout({
    required String schoolId,
    required String planId,
    required BillingCycle cycle,
  }) {
    return _remoteDataSource.createCheckout(
      schoolId: schoolId,
      planId: planId,
      cycle: cycle,
    );
  }

  Future<SubscriptionPayment> getPaymentStatus({
    required String schoolId,
    required String paymentId,
  }) {
    return _remoteDataSource.getPaymentStatus(
      schoolId: schoolId,
      paymentId: paymentId,
    );
  }

  Future<Paginated<SubscriptionPayment>> getPaymentHistory({
    required int page,
    required int perPage,
    String? schoolId,
    String? search,
    PaymentStatus? status,
  }) {
    return _remoteDataSource.getPaymentHistory(
      page: page,
      perPage: perPage,
      schoolId: schoolId,
      search: search,
      status: status,
    );
  }
}
