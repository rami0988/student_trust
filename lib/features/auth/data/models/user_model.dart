import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Raw JSON shape (this backend is unversioned/no envelope — see
/// core/network/endpoints.dart NOTE(migration)). Field names and fallbacks
/// mirror the OLD app's UserModel exactly, since they were reverse-engineered
/// against the real API responses.
@JsonSerializable(createToJson: true, checked: true)
class UserModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'username', defaultValue: '')
  final String username;
  @JsonKey(name: 'fullName', readValue: _readFullName)
  final String fullName;
  @JsonKey(name: 'role', defaultValue: 'student')
  final String role;
  @JsonKey(name: 'grade')
  final String? grade;
  @JsonKey(name: 'phone', readValue: _readPhone)
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.phone,
    this.grade,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toDomain() => User(id: id, username: username, fullName: fullName, role: role, grade: grade, phone: phone);

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readFullName(Map json, String key) => (json['fullName'] ?? json['full_name'] ?? '').toString();

  static Object? _readPhone(Map json, String key) =>
      (json['phone'] ?? json['phone_number'] ?? json['username'] ?? '').toString();
}
