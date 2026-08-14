import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/worksheet.dart';

part 'worksheets_state.g.dart';

abstract class WorksheetsState implements Built<WorksheetsState, WorksheetsStateBuilder> {
  Status get status;
  Failure? get failure;
  List<Worksheet> get worksheets;

  WorksheetsState._();
  factory WorksheetsState([void Function(WorksheetsStateBuilder) updates]) = _$WorksheetsState;

  factory WorksheetsState.initial() => WorksheetsState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..worksheets = [],
  );
}
