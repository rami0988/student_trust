// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MediaModel',
  json,
  ($checkedConvert) {
    final val = MediaModel(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String?),
      fileName: $checkedConvert('file_name', (v) => v as String?),
      mimeType: $checkedConvert('mime_type', (v) => v as String?),
      size: $checkedConvert('size', (v) => v as num?),
      original: $checkedConvert('original', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'fileName': 'file_name', 'mimeType': 'mime_type'},
);
