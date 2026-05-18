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
    if (pagination is Map) {
      final p = pagination.cast<String, dynamic>();
      return Paginated<T>(
        items: items,
        page: (p['page'] as num?)?.toInt() ?? 1,
        perPage: (p['per_page'] as num?)?.toInt() ?? items.length,
        total: (p['total'] as num?)?.toInt() ?? items.length,
        totalPages: (p['total_pages'] as num?)?.toInt() ?? 1,
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
