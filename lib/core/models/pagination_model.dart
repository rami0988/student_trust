import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

/// The `pagination` object every paginated student content endpoint now
/// returns alongside `data`, built by the backend's `buildPaginationMeta`
/// (`utils/pagination.js`): `{page, limit, total, totalPages, hasNextPage,
/// hasPrevPage}`.
///
/// Distinct from [MetaModel] in this same directory — that models a Laravel-
/// style `{current_page, last_page, ...}` shape the backend has never
/// actually sent (a leftover from the template). This one mirrors the real,
/// live contract shared with the backend's admin endpoints.
@JsonSerializable()
class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) => _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);

  /// The 1-indexed range of items on this page, for a "Showing X-Y of Z"
  /// label. Empty pages (last page can be short, or `total == 0`) clamp
  /// [rangeEnd] to [total] rather than overrunning it.
  int get rangeStart => total == 0 ? 0 : (page - 1) * limit + 1;

  int get rangeEnd {
    if (total == 0) return 0;
    final int end = page * limit;
    return end > total ? total : end;
  }
}
