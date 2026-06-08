import 'package:dio/dio.dart';

import '../../../../core/api/paginated.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../subscription/data/models/subscription_entities.dart';
import '../models/payment_entities.dart';

class PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSource(this._dio);

  Future<SubscriptionPayment> createCheckout({
    required String schoolId,
    required String planId,
    required BillingCycle cycle,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.schoolSubscriptionCheckout(schoolId),
        data: {'plan_id': planId, 'cycle': cycle.apiValue},
      );
      return _parsePayment(
        _readMapData(response.data),
        fallbackSchoolId: schoolId,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, fallback: 'Gagal membuat checkout payment.');
    }
  }

  Future<SubscriptionPayment> getPaymentStatus({
    required String schoolId,
    required String paymentId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.schoolSubscriptionPayment(schoolId, paymentId),
      );
      return _parsePayment(
        _readMapData(response.data),
        fallbackSchoolId: schoolId,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, fallback: 'Gagal memuat status payment.');
    }
  }

  Future<Paginated<SubscriptionPayment>> getPaymentHistory({
    required int page,
    required int perPage,
    String? schoolId,
    String? search,
    PaymentStatus? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'per_page': perPage};
      if (schoolId != null && schoolId.isNotEmpty) {
        params['school_id'] = schoolId;
      }
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      if (status != null && status != PaymentStatus.unknown) {
        params['status'] = status.apiValue;
      }

      final response = await _dio.get(
        ApiEndpoints.billingPayments,
        queryParameters: params,
      );

      final data = response.data;
      if (data is! Map) {
        return Paginated.empty<SubscriptionPayment>();
      }

      return Paginated<SubscriptionPayment>.fromResponseBody(
        data.cast<String, dynamic>(),
        (json) => _parsePayment(json, fallbackSchoolId: schoolId ?? ''),
      );
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallback: 'Gagal memuat riwayat pembayaran.',
      );
    }
  }

  SubscriptionPayment _parsePayment(
    Map<String, dynamic> payload, {
    required String fallbackSchoolId,
  }) {
    final paymentMap = _firstNonEmptyMap([
      payload['payment'],
      payload['data'],
      payload,
    ]);

    return SubscriptionPayment(
      id: _readString(paymentMap, const ['id', 'payment_id']) ?? '',
      schoolId:
          _readString(paymentMap, const ['school_id']) ?? fallbackSchoolId,
      schoolName: _readString(paymentMap, const ['school_name']) ?? '',
      planId: _readString(paymentMap, const ['plan_id']) ?? '',
      planName: _readString(paymentMap, const ['plan_name']) ?? '',
      createdByUserId:
          _readString(paymentMap, const ['created_by_user_id']) ?? '',
      activatedSubscriptionId:
          _readString(paymentMap, const ['activated_subscription_id']) ?? '',
      status: PaymentStatus.fromString(
        _readString(paymentMap, const ['status']) ?? '',
      ),
      cycle: BillingCycle.fromString(
        _readString(paymentMap, const ['cycle']) ?? '',
      ),
      amount: _readInt(paymentMap, const ['amount']),
      currency: _readString(paymentMap, const ['currency']) ?? 'IDR',
      provider: _readString(paymentMap, const ['provider']) ?? 'midtrans',
      providerOrderId:
          _readString(paymentMap, const ['provider_order_id']) ?? '',
      providerTransactionId:
          _readString(paymentMap, const ['provider_transaction_id']) ?? '',
      providerSnapToken:
          _readString(paymentMap, const ['provider_snap_token']) ?? '',
      providerRedirectUrl:
          _readString(paymentMap, const ['provider_redirect_url']) ?? '',
      paymentType: _readString(paymentMap, const ['payment_type']) ?? '',
      transactionStatus:
          _readString(paymentMap, const ['transaction_status']) ?? '',
      fraudStatus: _readString(paymentMap, const ['fraud_status']) ?? '',
      paidAt: _readDate(paymentMap, const ['paid_at']),
      expiresAt: _readDate(paymentMap, const ['expires_at']),
      createdAt: _readDate(paymentMap, const ['created_at']),
      updatedAt: _readDate(paymentMap, const ['updated_at']),
    );
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

  DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed.toLocal();
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
      400 => 'Permintaan payment tidak valid.',
      401 => 'Unauthorized.',
      403 => 'Anda tidak memiliki akses ke payment sekolah ini.',
      404 => 'Data payment tidak ditemukan.',
      409 => 'Masih ada payment pending untuk sekolah ini.',
      422 => 'Data payment tidak dapat diproses.',
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
