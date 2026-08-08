// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkModel _$LinkModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LinkModel', json, ($checkedConvert) {
      final val = LinkModel(
        first: $checkedConvert('first', (v) => v as String?),
        last: $checkedConvert('last', (v) => v as String?),
        prev: $checkedConvert('prev', (v) => v as String?),
        next: $checkedConvert('next', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LinkModelToJson(LinkModel instance) => <String, dynamic>{
  'first': instance.first,
  'last': instance.last,
  'prev': instance.prev,
  'next': instance.next,
};
