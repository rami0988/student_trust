import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String? teacherName;
  final String? grade;
  final bool isSubscribed;

  const Subject({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.teacherName,
    this.grade,
    this.isSubscribed = false,
  });

  @override
  List<Object?> get props => [id, name, description, thumbnailUrl, teacherName, grade, isSubscribed];
}
