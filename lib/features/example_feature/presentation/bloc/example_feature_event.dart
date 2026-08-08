import 'package:built_value/built_value.dart';

part 'example_feature_event.g.dart';

sealed class ExampleFeatureEvent {}

abstract class GetExampleItems extends ExampleFeatureEvent implements Built<GetExampleItems, GetExampleItemsBuilder> {
  bool get reInitialData;

  GetExampleItems._();
  factory GetExampleItems([void Function(GetExampleItemsBuilder) updates]) = _$GetExampleItems;
}

abstract class LikeExampleItem extends ExampleFeatureEvent implements Built<LikeExampleItem, LikeExampleItemBuilder> {
  int get itemId;

  LikeExampleItem._();
  factory LikeExampleItem([void Function(LikeExampleItemBuilder) updates]) = _$LikeExampleItem;
}

abstract class UnlikeExampleItem extends ExampleFeatureEvent
    implements Built<UnlikeExampleItem, UnlikeExampleItemBuilder> {
  int get itemId;

  UnlikeExampleItem._();
  factory UnlikeExampleItem([void Function(UnlikeExampleItemBuilder) updates]) = _$UnlikeExampleItem;
}

abstract class ChangeExampleItemLikeStateInternally extends ExampleFeatureEvent
    implements Built<ChangeExampleItemLikeStateInternally, ChangeExampleItemLikeStateInternallyBuilder> {
  int get itemId;
  bool get isLiked;

  ChangeExampleItemLikeStateInternally._();
  factory ChangeExampleItemLikeStateInternally([
    void Function(ChangeExampleItemLikeStateInternallyBuilder) updates,
  ]) = _$ChangeExampleItemLikeStateInternally;
}
