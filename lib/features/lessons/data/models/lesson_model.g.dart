// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LessonModel',
  json,
  ($checkedConvert) {
    final val = LessonModel(
      id: $checkedConvert(
        'id',
        (v) => v as String,
        readValue: LessonModel._readId,
      ),
      chapterId: $checkedConvert(
        'chapter_id',
        (v) => v as String,
        readValue: LessonModel._readChapterId,
      ),
      title: $checkedConvert(
        'title_ar',
        (v) => v as String,
        readValue: LessonModel._readTitle,
      ),
      durationSeconds: $checkedConvert(
        'duration_seconds',
        (v) => (v as num?)?.toInt() ?? 0,
        readValue: LessonModel._readDurationSeconds,
      ),
      sortOrder: $checkedConvert(
        'sort_order',
        (v) => (v as num?)?.toInt() ?? 0,
        readValue: LessonModel._readSortOrder,
      ),
      isPublished: $checkedConvert(
        'is_published',
        (v) => v as bool? ?? true,
        readValue: LessonModel._readIsPublished,
      ),
      progress: $checkedConvert(
        'progress',
        (v) => ProgressModel.fromJson(v as Map<String, dynamic>),
        readValue: LessonModel._readProgress,
      ),
      description: $checkedConvert(
        'description_ar',
        (v) => v as String?,
        readValue: LessonModel._readDescription,
      ),
      bunnyVideoId: $checkedConvert(
        'bunny_video_id',
        (v) => v as String?,
        readValue: LessonModel._readBunnyVideoId,
      ),
      thumbnailUrl: $checkedConvert(
        'thumbnail_url',
        (v) => v as String?,
        readValue: LessonModel._readThumbnailUrl,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'chapterId': 'chapter_id',
    'title': 'title_ar',
    'durationSeconds': 'duration_seconds',
    'sortOrder': 'sort_order',
    'isPublished': 'is_published',
    'description': 'description_ar',
    'bunnyVideoId': 'bunny_video_id',
    'thumbnailUrl': 'thumbnail_url',
  },
);
