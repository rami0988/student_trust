// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ChapterModel',
      json,
      ($checkedConvert) {
        final val = ChapterModel(
          id: $checkedConvert(
            'id',
            (v) => v as String,
            readValue: ChapterModel._readId,
          ),
          subjectId: $checkedConvert(
            'subject_id',
            (v) => v as String,
            readValue: ChapterModel._readSubjectId,
          ),
          title: $checkedConvert(
            'title_ar',
            (v) => v as String,
            readValue: ChapterModel._readTitle,
          ),
          sortOrder: $checkedConvert(
            'sort_order',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: ChapterModel._readSortOrder,
          ),
          worksheetCount: $checkedConvert(
            'worksheets',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: ChapterModel._readWorksheetCount,
          ),
          grade: $checkedConvert('grade', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'subjectId': 'subject_id',
        'title': 'title_ar',
        'sortOrder': 'sort_order',
        'worksheetCount': 'worksheets',
      },
    );
