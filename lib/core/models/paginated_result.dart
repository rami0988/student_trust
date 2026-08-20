import 'pagination_model.dart';

/// A single page of `T`s plus the pagination metadata that came with it.
///
/// Plain (non-`@JsonSerializable`) on purpose: every data source already
/// parses its own item list with `XModel.fromJson`, so this just pairs that
/// list with the response's `pagination` object rather than duplicating
/// per-type JSON codegen for a generic.
class PaginatedResult<T> {
  final List<T> items;
  final PaginationModel pagination;

  const PaginatedResult(this.items, this.pagination);

  PaginatedResult<R> map<R>(R Function(T item) convert) => PaginatedResult<R>(items.map(convert).toList(), pagination);
}
