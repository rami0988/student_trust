import 'user_model.dart';

/// Wraps the raw login response `{accessToken, refreshToken, user}` — kept
/// separate from [UserModel] since the tokens aren't part of the [User]
/// entity, only something the repository persists to secure storage.
class LoginResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final UserModel user;

  LoginResponseModel({required this.accessToken, required this.refreshToken, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    accessToken: json['accessToken'] as String?,
    refreshToken: json['refreshToken'] as String?,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}
