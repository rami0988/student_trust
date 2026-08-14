import 'package:equatable/equatable.dart';

class Worksheet extends Equatable {
  final String id;
  final String chapterId;
  final String title;
  final String? description;
  final int filesCount;
  final int videosCount;

  const Worksheet({
    required this.id,
    required this.chapterId,
    required this.title,
    this.description,
    this.filesCount = 0,
    this.videosCount = 0,
  });

  @override
  List<Object?> get props => [id, chapterId, title, description, filesCount, videosCount];
}
