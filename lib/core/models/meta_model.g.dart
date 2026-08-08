// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MetaModel',
  json,
  ($checkedConvert) {
    final val = MetaModel(
      currentPage: $checkedConvert('current_page', (v) => (v as num?)?.toInt()),
      firstPageUrl: $checkedConvert('first_page_url', (v) => v as String?),
      from: $checkedConvert('from', (v) => (v as num?)?.toInt()),
      lastPage: $checkedConvert('last_page', (v) => (v as num?)?.toInt() ?? 1),
      lastPageUrl: $checkedConvert('last_page_url', (v) => v as String?),
      nextPageUrl: $checkedConvert('next_page_url', (v) => v),
      path: $checkedConvert('path', (v) => v as String?),
      perPage: $checkedConvert('per_page', (v) => (v as num?)?.toInt()),
      prevPageUrl: $checkedConvert('prev_page_url', (v) => v),
      to: $checkedConvert('to', (v) => (v as num?)?.toInt()),
      total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'currentPage': 'current_page',
    'firstPageUrl': 'first_page_url',
    'lastPage': 'last_page',
    'lastPageUrl': 'last_page_url',
    'nextPageUrl': 'next_page_url',
    'perPage': 'per_page',
    'prevPageUrl': 'prev_page_url',
  },
);

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) => <String, dynamic>{
  'current_page': instance.currentPage,
  'first_page_url': instance.firstPageUrl,
  'from': instance.from,
  'last_page': instance.lastPage,
  'last_page_url': instance.lastPageUrl,
  'next_page_url': instance.nextPageUrl,
  'path': instance.path,
  'per_page': instance.perPage,
  'prev_page_url': instance.prevPageUrl,
  'to': instance.to,
  'total': instance.total,
};
