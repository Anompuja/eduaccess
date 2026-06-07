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
}
