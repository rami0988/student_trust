import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/lesson.dart';

part 'lessons_state.g.dart';

abstract class LessonsState implements Built<LessonsState, LessonsStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Lesson> get lessons;

  /// Lesson ids available offline (downloaded + decrypted-ready).
  List<String> get downloadedLessonIds;

  LessonsState._();
  factory LessonsState([void Function(LessonsStateBuilder) updates]) = _$LessonsState;

  factory LessonsState.initial() => LessonsState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..lessons = []
      ..downloadedLessonIds = [],
  );
}
