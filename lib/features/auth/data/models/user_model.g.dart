// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserModel', json, ($checkedConvert) {
      final val = UserModel(
        id: $checkedConvert(
          'id',
          (v) => v as String,
          readValue: UserModel._readId,
        ),
        username: $checkedConvert('username', (v) => v as String? ?? ''),
        fullName: $checkedConvert(
          'fullName',
          (v) => v as String,
          readValue: UserModel._readFullName,
        ),
        role: $checkedConvert('role', (v) => v as String? ?? 'student'),
        phone: $checkedConvert(
          'phone',
          (v) => v as String,
          readValue: UserModel._readPhone,
        ),
        grade: $checkedConvert('grade', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'fullName': instance.fullName,
  'role': instance.role,
  'grade': instance.grade,
  'phone': instance.phone,
};
