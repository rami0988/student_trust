import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? grade;
  final String role;

  /// Phone number used for the anti-piracy video watermark. The backend does
  /// not always expose a dedicated phone field, so it falls back to
  /// [username] (usually the student's phone on this platform).
  final String phone;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.phone,
    this.grade,
  });

  @override
  List<Object?> get props => [id, username, fullName, grade, role, phone];
}
