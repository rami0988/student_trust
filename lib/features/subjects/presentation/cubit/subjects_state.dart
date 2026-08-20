import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_model.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/subject.dart';

part 'subjects_state.g.dart';

abstract class SubjectsState implements Built<SubjectsState, SubjectsStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Subject> get subjects;

  /// Pagination for [subjects], `null` before the first successful load and
  /// while [isSearching] (a search holds the complete match set instead —
  /// see `SubjectsCubit.searchSubjects`).
  PaginationModel? get pagination;

  /// True while a next-page request is in flight (infinite scroll).
  bool get isLoadingMore;

  /// True once the student has typed a search query: [subjects] then holds
  /// every subject across every backend page (looped via `getAllSubjects`)
  /// rather than just the loaded page, since the backend has no `?search=`.
  bool get isSearching;

  SubjectsState._();
  factory SubjectsState([void Function(SubjectsStateBuilder) updates]) = _$SubjectsState;

  factory SubjectsState.initial() => SubjectsState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..subjects = []
      ..isLoadingMore = false
      ..isSearching = false,
  );
}
