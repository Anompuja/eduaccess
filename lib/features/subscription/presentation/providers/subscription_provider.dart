import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/providers/active_school_provider.dart';
import '../../../students/presentation/providers/students_data_provider.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../data/models/subscription_entities.dart';
import '../../data/repositories/subscription_repository_impl.dart';

final subscriptionRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return SubscriptionRepositoryImpl(SubscriptionRemoteDataSource(dio));
});

final currentSubscriptionSchoolIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  final activeSchool = ref.watch(activeSchoolProvider);

  return switch (user?.role) {
    UserRole.superadmin => activeSchool?.id,
    _ => user?.schoolId,
  };
});

final schoolPlansProvider = FutureProvider.autoDispose<List<SubscriptionPlan>>((
  ref,
) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final plans = await repository.getPlans();
  return plans.where((plan) => plan.isActive).toList();
});

final schoolSubscriptionProvider = FutureProvider.autoDispose
    .family<SchoolSubscription, String>((ref, schoolId) async {
      final repository = ref.watch(subscriptionRepositoryProvider);
      return repository.getSchoolSubscription(schoolId);
    });

final schoolSubscriptionOverviewProvider = FutureProvider.autoDispose
    .family<
      SchoolSubscriptionOverview,
      ({String schoolId, bool includeSchoolIdQuery})
    >((ref, params) async {
      final subscription = await ref.watch(
        schoolSubscriptionProvider(params.schoolId).future,
      );
      final studentsUsed = await ref.watch(
        schoolStudentCountProvider((
          schoolId: params.schoolId,
          includeSchoolIdQuery: params.includeSchoolIdQuery,
        )).future,
      );

      return SchoolSubscriptionOverview(
        subscription: subscription,
        studentsUsed: studentsUsed,
      );
    });

final currentSchoolSubscriptionOverviewProvider =
    FutureProvider.autoDispose<SchoolSubscriptionOverview?>((ref) async {
      final schoolId = ref.watch(currentSubscriptionSchoolIdProvider);
      final user = ref.watch(currentUserProvider);
      if (schoolId == null || schoolId.isEmpty) return null;

      return ref.watch(
        schoolSubscriptionOverviewProvider((
          schoolId: schoolId,
          includeSchoolIdQuery: user?.role == UserRole.superadmin,
        )).future,
      );
    });
