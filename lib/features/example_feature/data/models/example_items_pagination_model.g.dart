// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_items_pagination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleItemsPaginationModel _$ExampleItemsPaginationModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ExampleItemsPaginationModel',
  json,
  ($checkedConvert) {
    final val = ExampleItemsPaginationModel(
      items: $checkedConvert(
        'data',
        (v) => (v as List<dynamic>)
            .map((e) => ExampleItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      lastPage: $checkedConvert(
        'meta',
        (v) => lastPageFromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'items': 'data', 'lastPage': 'meta'},
);
