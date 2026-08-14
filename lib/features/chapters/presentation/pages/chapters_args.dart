class ChaptersArgs {
  final String subjectId;
  final String subjectName;

  /// Threaded through for the Hero animation from the subject card.
  final String? subjectThumbnailUrl;

  const ChaptersArgs({required this.subjectId, required this.subjectName, this.subjectThumbnailUrl});
}
