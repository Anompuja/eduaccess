/// Generic paginated response wrapper.
///
/// Matches backend `PaginatedResponse`:
/// ```json
/// {
///   "data": [...],
///   "pagination": { "page": 1, "per_page": 20, "total": 34, "total_pages": 2 }
/// }
/// ```
///
/// Reuse across list endpoints (parents, students, teachers, etc.).
class Paginated<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const Paginated({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  bool get hasNext => page < totalPages;
  bool get hasPrev => page > 1;
  bool get isEmpty => items.isEmpty;

  /// Parse from a backend response body.
  /// [body] is the full response Map (with `data` and `pagination` keys).
  /// [parseItem] converts each raw JSON item into [T].
  factory Paginated.fromResponseBody(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final rawList = body['data'];
    final items = rawList is List
        ? rawList
              .whereType<Map>()
              .map((m) => parseItem(m.cast<String, dynamic>()))
              .toList()
        : <T>[];

    final pagination = body['pagination'];
    Map<String, dynamic> metadata = <String, dynamic>{};
    if (pagination is Map) {
      metadata = pagination.cast<String, dynamic>();
    } else if (body.containsKey('page') ||
        body.containsKey('per_page') ||
        body.containsKey('total') ||
        body.containsKey('total_pages')) {
      metadata = body;
    }

    if (metadata.isNotEmpty) {
      final page = (metadata['page'] as num?)?.toInt() ?? 1;
      final perPage =
          (metadata['per_page'] as num?)?.toInt() ??
          (items.isEmpty ? 0 : items.length);
      final total = (metadata['total'] as num?)?.toInt() ?? items.length;
      final totalPages =
          (metadata['total_pages'] as num?)?.toInt() ??
          (perPage <= 0 ? (items.isEmpty ? 0 : 1) : (total / perPage).ceil());

      return Paginated<T>(
        items: items,
        page: page,
        perPage: perPage,
        total: total,
        totalPages: totalPages,
      );
    }

    // Fallback when backend doesn't include pagination (single-page list).
    return Paginated<T>(
      items: items,
      page: 1,
      perPage: items.length,
      total: items.length,
      totalPages: items.isEmpty ? 0 : 1,
    );
  }

  static Paginated<T> empty<T>() => Paginated<T>(
    items: const [],
    page: 1,
    perPage: 0,
    total: 0,
    totalPages: 0,
  );
}
