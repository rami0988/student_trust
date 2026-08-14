// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksheet_video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorksheetVideoModel _$WorksheetVideoModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WorksheetVideoModel',
      json,
      ($checkedConvert) {
        final val = WorksheetVideoModel(
          id: $checkedConvert(
            'id',
            (v) => v as String,
            readValue: WorksheetVideoModel._readId,
          ),
          worksheetId: $checkedConvert(
            'worksheet_id',
            (v) => v as String,
            readValue: WorksheetVideoModel._readWorksheetId,
          ),
          title: $checkedConvert(
            'title_ar',
            (v) => v as String,
            readValue: WorksheetVideoModel._readTitle,
          ),
          durationSeconds: $checkedConvert(
            'duration_seconds',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: WorksheetVideoModel._readDurationSeconds,
          ),
          thumbnailUrl: $checkedConvert(
            'thumbnail_url',
            (v) => v as String?,
            readValue: WorksheetVideoModel._readThumbnailUrl,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'worksheetId': 'worksheet_id',
        'title': 'title_ar',
        'durationSeconds': 'duration_seconds',
        'thumbnailUrl': 'thumbnail_url',
      },
    );
