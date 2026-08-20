import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_model.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/chapter.dart';

part 'chapters_state.g.dart';

abstract class ChaptersState implements Built<ChaptersState, ChaptersStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Chapter> get chapters;

  /// Pagination for [chapters], `null` before the first successful load.
  PaginationModel? get pagination;

  /// True while a next-page request is in flight (infinite scroll).
  bool get isLoadingMore;

  ChaptersState._();
  factory ChaptersState([void Function(ChaptersStateBuilder) updates]) = _$ChaptersState;

  factory ChaptersState.initial() => ChaptersState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..chapters = []
      ..isLoadingMore = false,
  );
}
