import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/example_item.dart';

part 'example_item_details_state.g.dart';

abstract class ExampleItemDetailsState implements Built<ExampleItemDetailsState, ExampleItemDetailsStateBuilder> {
  Status get status;
  Failure? get failure;
  ExampleItem? get item;

  ExampleItemDetailsState._();
  factory ExampleItemDetailsState([void Function(ExampleItemDetailsStateBuilder) updates]) = _$ExampleItemDetailsState;

  factory ExampleItemDetailsState.initial() => ExampleItemDetailsState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..item = null,
  );
}
