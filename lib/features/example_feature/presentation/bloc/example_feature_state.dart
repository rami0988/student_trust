import 'package:built_value/built_value.dart';

import '../../../../core/entities/pagination_state_data.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/example_item.dart';

part 'example_feature_state.g.dart';

abstract class ExampleFeatureState implements Built<ExampleFeatureState, ExampleFeatureStateBuilder> {
  Status get status;
  Failure? get failure;
  PaginationStateData<ExampleItem> get items;

  ExampleFeatureState._();
  factory ExampleFeatureState([void Function(ExampleFeatureStateBuilder) updates]) = _$ExampleFeatureState;

  factory ExampleFeatureState.initial() => ExampleFeatureState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..items.replace(PaginationStateData.initial()),
  );
}
