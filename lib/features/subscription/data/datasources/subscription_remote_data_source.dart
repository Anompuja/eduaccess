import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/paginated.dart';
import '../models/subscription_entities.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _dio.get(ApiEndpoints.schoolPlans);
      final rawList = _readListData(response.data);

      return rawList
          .whereType<Map>()
          .map((entry) => _map(entry))
          .map(_parsePlan)
          .where((plan) => plan.id.isNotEmpty || plan.name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.tier.sortOrder.compareTo(b.tier.sortOrder));
    } on DioException catch (e) {
      throw _handleDioException(e, fallback: 'Gagal memuat daftar paket.');
    }
  }

  Future<SchoolSubscription> getSchoolSubscription(String schoolId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.schoolSubscription(schoolId),
      );
      return _parseSubscription(
        _readMapData(response.data),
        fallbackSchoolId: schoolId,
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallback: 'Gagal memuat subscription sekolah.',
      );
    }
  }

  Future<Paginated<SchoolSubscriptionRecord>> getSchoolsWithSubscription({
    required int page,
    required int perPage,
    String? search,
    SchoolDirectoryStatus? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'per_page': perPage};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      if (status != null && status != SchoolDirectoryStatus.unknown) {
        params['status'] = status.apiValue;
      }

      final response = await _dio.get(
        ApiEndpoints.schools,
        queryParameters: params,
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<SchoolSubscriptionRecord>();
      }

      return Paginated<SchoolSubscriptionRecord>.fromResponseBody(
        data.cast<String, dynamic>(),
        _parseSchoolSubscriptionRecord,
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallback: 'Gagal memuat daftar subscription sekolah.',
      );
    }
  }

  Future<SchoolSubscription> updateSchoolSubscription({
    required String schoolId,
    required String planId,
    required BillingCycle cycle,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.schoolSubscription(schoolId),
        data: {'plan_id': planId, 'cycle': cycle.apiValue},
      );
      return _parseSubscription(
        _readMapData(response.data),
        fallbackSchoolId: schoolId,
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallback: 'Gagal memperbarui subscription sekolah.',
      );
    }
  }

  SchoolSubscription _parseSubscription(
    Map<String, dynamic> payload, {
    required String fallbackSchoolId,
  }) {
    final subscriptionMap = _firstNonEmptyMap([
      payload['subscription'],
      payload['data'],
      payload,
    ]);

    final schoolMap = _firstNonEmptyMap([
      payload['school'],
      subscriptionMap['school'],
      payload,
    ]);

    final planMap = _firstNonEmptyMap([
      payload['plan'],
      subscriptionMap['plan'],
      subscriptionMap['current_plan'],
      subscriptionMap['active_plan'],
      subscriptionMap,
    ]);

    return SchoolSubscription(
      id: _readString(subscriptionMap, const ['id', 'subscription_id']) ?? '',
      schoolId:
          _readString(subscriptionMap, const ['school_id']) ??
          _readString(schoolMap, const ['id']) ??
          fallbackSchoolId,
      schoolName:
          _readString(schoolMap, const ['name', 'school_name']) ??
          _readString(subscriptionMap, const ['school_name']) ??
          '',
      status: SubscriptionStatus.fromString(
        _readString(subscriptionMap, const ['status']) ?? '',
      ),
      startDate: _readDate(subscriptionMap, const ['start_date', 'starts_at']),
      endDate: _readDate(subscriptionMap, const [
        'end_date',
        'ends_at',
        'expired_at',
      ]),
      cycle: BillingCycle.fromString(
        _readString(subscriptionMap, const ['cycle', 'billing_cycle']) ?? '',
      ),
      price: _readInt(subscriptionMap, const ['price', 'amount']),
      quantity: _readInt(subscriptionMap, const ['quantity']),
      plan: _parsePlan(planMap),
    );
  }

  SchoolSubscriptionRecord _parseSchoolSubscriptionRecord(
    Map<String, dynamic> json,
  ) {
    final schoolId = _readString(json, const ['id', 'school_id']) ?? '';
    final subscriptionMap = _firstNonEmptyMap([
      json['subscription'],
      json['current_subscription'],
      json['active_subscription'],
    ]);

    return SchoolSubscriptionRecord(
      id: schoolId,
      name: _readString(json, const ['name', 'school_name']) ?? '',
      status: SchoolDirectoryStatus.fromString(
        _readString(json, const ['status']) ?? '',
      ),
      subscription: subscriptionMap.isEmpty
          ? null
          : _parseSubscription(json, fallbackSchoolId: schoolId),
    );
  }

  SubscriptionPlan _parsePlan(Map<String, dynamic> json) {
    final name =
        _readString(json, const ['name', 'plan_name', 'subscription_plan']) ??
        '';
    final code =
        _readString(json, const ['code', 'slug', 'plan_code']) ??
        name.toLowerCase();

    return SubscriptionPlan(
      id: _readString(json, const ['id', 'plan_id']) ?? '',
      code: code,
      name: name,
      description: _readString(json, const ['description']) ?? '',
      features: _readStringList(json, const ['features']),
      monthlyPrice: _readInt(json, const ['monthly_price']) != 0
          ? _readInt(json, const ['monthly_price'])
          : _readInt(json, const ['price', 'amount']),
      yearlyPrice: _readInt(json, const ['yearly_price']),
      maxStudents: _readInt(json, const ['max_students', 'student_limit']),
      isActive: _readBool(json, const [
        'is_active',
        'active',
      ], defaultValue: true),
      tier: SubscriptionTier.fromPlan(name: name, code: code),
    );
  }

  List<dynamic> _readListData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) return inner;
      if (inner is Map && inner['items'] is List) return inner['items'] as List;
    }
    if (data is List) return data;
    return const [];
  }

  Map<String, dynamic> _readMapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      if (inner is Map) return _map(inner);
      return data;
    }
    if (data is Map) return _map(data);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _firstNonEmptyMap(List<dynamic> values) {
    for (final value in values) {
      final mapped = _readMapData(value);
      if (mapped.isNotEmpty) return mapped;
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _map(Map value) =>
      value.map((key, dynamic value) => MapEntry(key.toString(), value));

  String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  bool _readBool(
    Map<String, dynamic> json,
    List<String> keys, {
    required bool defaultValue,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
    }
    return defaultValue;
  }

  List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }

  DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  String _handleDioException(DioException e, {required String fallback}) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    }

    final message = _extractServerMessage(e);
    if (message != null) return message;

    return switch (e.response?.statusCode) {
      400 => 'Permintaan tidak valid.',
      401 => 'Unauthorized.',
      403 => 'Anda tidak memiliki akses ke subscription sekolah ini.',
      404 => 'Data subscription sekolah tidak ditemukan.',
      409 => 'Subscription sekolah konflik dengan data saat ini.',
      422 => 'Data subscription tidak dapat diproses.',
      500 => 'Server error. Please try again later.',
      _ => e.message ?? fallback,
    };
  }

  String? _extractServerMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }
}
