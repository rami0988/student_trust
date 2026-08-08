// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseModel _$BaseModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BaseModel', json, ($checkedConvert) {
      final val = BaseModel(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert('data', (v) => v),
        links: $checkedConvert(
          'links',
          (v) =>
              v == null ? null : LinkModel.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) =>
              v == null ? null : MetaModel.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BaseModelToJson(BaseModel instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'links': instance.links?.toJson(),
  'meta': instance.meta?.toJson(),
};
