import 'package:equatable/equatable.dart';

import 'progress.dart';

class Lesson extends Equatable {
  final String id;
  final String chapterId;
  final String title;
  final String? description;
  final int durationSeconds;
  final int sortOrder;
  final bool isPublished;
  final String? bunnyVideoId;
  final String? thumbnailUrl;
  final Progress progress;

  const Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    this.description,
    this.durationSeconds = 0,
    this.sortOrder = 0,
    this.isPublished = true,
    this.bunnyVideoId,
    this.thumbnailUrl,
    this.progress = const Progress(),
  });

  @override
  List<Object?> get props => [
    id,
    chapterId,
    title,
    description,
    durationSeconds,
    sortOrder,
    isPublished,
    bunnyVideoId,
    thumbnailUrl,
    progress,
  ];
}
