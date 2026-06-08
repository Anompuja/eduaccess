import '../../../../core/api/paginated.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../models/subscription_entities.dart';

class SubscriptionRepositoryImpl {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  Future<List<SubscriptionPlan>> getPlans() {
    return _remoteDataSource.getPlans();
  }

  Future<SchoolSubscription> getSchoolSubscription(String schoolId) {
    return _remoteDataSource.getSchoolSubscription(schoolId);
  }

  Future<Paginated<SchoolSubscriptionRecord>> getSchoolsWithSubscription({
    required int page,
    required int perPage,
    String? search,
    SchoolDirectoryStatus? status,
  }) {
    return _remoteDataSource.getSchoolsWithSubscription(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
    );
  }

  Future<SchoolSubscription> updateSchoolSubscription({
    required String schoolId,
    required String planId,
    required BillingCycle cycle,
  }) {
    return _remoteDataSource.updateSchoolSubscription(
      schoolId: schoolId,
      planId: planId,
      cycle: cycle,
    );
  }
}
