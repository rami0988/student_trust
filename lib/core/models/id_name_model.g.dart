// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_name_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdNameModel _$IdNameModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IdNameModel', json, ($checkedConvert) {
      final val = IdNameModel(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });
