// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleItemModel _$ExampleItemModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExampleItemModel', json, ($checkedConvert) {
      final val = ExampleItemModel(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String? ?? ''),
        isLiked: $checkedConvert('is_liked', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'isLiked': 'is_liked'});
