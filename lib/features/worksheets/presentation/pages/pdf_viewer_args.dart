/// Provide [url] to stream the PDF from the CDN (cached to temp first), or
/// [localPath] to open an already-downloaded file directly.
class PdfViewerArgs {
  final String url;
  final String fileName;
  final String? localPath;

  const PdfViewerArgs({required this.url, required this.fileName, this.localPath});
}
