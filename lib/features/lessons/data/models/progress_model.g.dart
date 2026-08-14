// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProgressModel', json, ($checkedConvert) {
      final val = ProgressModel(
        positionSeconds: $checkedConvert(
          'positionSeconds',
          (v) => (v as num?)?.toInt() ?? 0,
          readValue: ProgressModel._readPositionSeconds,
        ),
        isCompleted: $checkedConvert(
          'isCompleted',
          (v) => v as bool? ?? false,
          readValue: ProgressModel._readIsCompleted,
        ),
      );
      return val;
    });
