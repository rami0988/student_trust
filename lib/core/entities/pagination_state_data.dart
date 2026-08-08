import 'package:built_value/built_value.dart';

part 'pagination_state_data.g.dart';

abstract class PaginationStateData<T> implements Built<PaginationStateData<T>, PaginationStateDataBuilder<T>> {
  List<T> get items;

  bool get isLoading;

  bool get isFinished;

  int get currentPage;

  PaginationStateData._();

  factory PaginationStateData([
    Function(PaginationStateDataBuilder<T> b) updates,
  ]) = _$PaginationStateData<T>;

  factory PaginationStateData.initial() => PaginationStateData<T>(
    (b) => b
      ..items = []
      ..isLoading = false
      ..isFinished = false
      ..currentPage = 1,
  );
}
