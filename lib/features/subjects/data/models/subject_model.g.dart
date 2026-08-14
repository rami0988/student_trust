// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SubjectModel',
      json,
      ($checkedConvert) {
        final val = SubjectModel(
          id: $checkedConvert(
            'id',
            (v) => v as String,
            readValue: SubjectModel._readId,
          ),
          name: $checkedConvert(
            'name_ar',
            (v) => v as String,
            readValue: SubjectModel._readName,
          ),
          isSubscribed: $checkedConvert(
            'is_subscribed',
            (v) => v as bool? ?? false,
            readValue: SubjectModel._readIsSubscribed,
          ),
          description: $checkedConvert(
            'description_ar',
            (v) => v as String?,
            readValue: SubjectModel._readDescription,
          ),
          thumbnailUrl: $checkedConvert(
            'thumbnail_url',
            (v) => v as String?,
            readValue: SubjectModel._readThumbnailUrl,
          ),
          teacherName: $checkedConvert(
            'teacher_name',
            (v) => v as String?,
            readValue: SubjectModel._readTeacherName,
          ),
          grade: $checkedConvert('grade', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'name': 'name_ar',
        'isSubscribed': 'is_subscribed',
        'description': 'description_ar',
        'thumbnailUrl': 'thumbnail_url',
        'teacherName': 'teacher_name',
      },
    );
