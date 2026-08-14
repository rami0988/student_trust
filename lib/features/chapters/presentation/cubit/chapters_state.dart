import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/chapter.dart';

part 'chapters_state.g.dart';

abstract class ChaptersState implements Built<ChaptersState, ChaptersStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Chapter> get chapters;

  ChaptersState._();
  factory ChaptersState([void Function(ChaptersStateBuilder) updates]) = _$ChaptersState;

  factory ChaptersState.initial() => ChaptersState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..chapters = [],
  );
}
