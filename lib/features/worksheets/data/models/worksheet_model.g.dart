// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksheet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorksheetModel _$WorksheetModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WorksheetModel',
      json,
      ($checkedConvert) {
        final val = WorksheetModel(
          id: $checkedConvert(
            'id',
            (v) => v as String,
            readValue: WorksheetModel._readId,
          ),
          chapterId: $checkedConvert(
            'chapter_id',
            (v) => v as String,
            readValue: WorksheetModel._readChapterId,
          ),
          title: $checkedConvert(
            'title_ar',
            (v) => v as String,
            readValue: WorksheetModel._readTitle,
          ),
          filesCount: $checkedConvert(
            'filesCount',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: WorksheetModel._readFilesCount,
          ),
          videosCount: $checkedConvert(
            'videosCount',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: WorksheetModel._readVideosCount,
          ),
          description: $checkedConvert(
            'description_ar',
            (v) => v as String?,
            readValue: WorksheetModel._readDescription,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'chapterId': 'chapter_id',
        'title': 'title_ar',
        'description': 'description_ar',
      },
    );
