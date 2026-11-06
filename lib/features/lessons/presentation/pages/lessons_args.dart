class LessonsArgs {
  final String chapterId;
  final String chapterTitle;

  /// Subject name, shown as the label above the chapter title; optional.
  final String? subjectName;

  const LessonsArgs({required this.chapterId, required this.chapterTitle, this.subjectName});
}
