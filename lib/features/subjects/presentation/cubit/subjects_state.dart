import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/subject.dart';

part 'subjects_state.g.dart';

abstract class SubjectsState implements Built<SubjectsState, SubjectsStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Subject> get subjects;

  SubjectsState._();
  factory SubjectsState([void Function(SubjectsStateBuilder) updates]) = _$SubjectsState;

  factory SubjectsState.initial() => SubjectsState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..subjects = [],
  );
}
