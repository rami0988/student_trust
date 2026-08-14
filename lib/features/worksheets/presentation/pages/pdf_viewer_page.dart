import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../../core/di/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/request_result.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../generated/l10n.dart';
import '../../domain/repositories/worksheets_repository.dart';
import 'pdf_viewer_args.dart';

/// In-app PDF viewer for students.
///
/// Downloads the file to the temp cache first (flutter_pdfview renders local
/// files only), or opens a [PdfViewerArgs.localPath] directly. The AppBar has
/// a download action that saves the PDF permanently to the device.
class PdfViewerPage extends StatefulWidget {
  final PdfViewerArgs args;
  const PdfViewerPage({super.key, required this.args});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;
  String? _error;
  int _pages = 0;
  int _currentPage = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    setState(() {
      _error = null;
      _localPath = null;
    });

    // Already on disk (opened from the Downloads snackbar).
    if (widget.args.localPath != null) {
      setState(() => _localPath = widget.args.localPath);
      return;
    }

    final RequestResult<String> result = await getIt<WorksheetsRepository>().downloadPdfToCache(widget.args.url, widget.args.fileName);
    if (!mounted) return;
    result.fold(success: (path) => setState(() => _localPath = path), failure: (failure) => setState(() => _error = failure.statusMessage));
  }

  /// Saves the PDF permanently to the device's Downloads folder.
  Future<void> _saveToDevice() async {
    if (_saving || widget.args.url.isEmpty) return;
    setState(() => _saving = true);
    final RequestResult<String> result = await getIt<WorksheetsRepository>().downloadPdfToDevice(widget.args.url, widget.args.fileName);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      success: (_) => showToastMessage(S.of(context).savedToDownloads),
      failure: (failure) => showToastMessage(failure.statusMessage, isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.args.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          if (_pages > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
                child: Text('${_currentPage + 1} / $_pages', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          if (widget.args.url.isNotEmpty)
            Semantics(
              button: true,
              label: S.of(context).downloadToDeviceTooltip,
              child: IconButton(
                tooltip: S.of(context).downloadToDeviceTooltip,
                onPressed: _saving ? null : _saveToDevice,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download_rounded),
              ),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _prepare);
    }
    if (_localPath == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: false,
      onRender: (pages) => setState(() => _pages = pages ?? 0),
      onPageChanged: (page, _) => setState(() => _currentPage = page ?? 0),
      onError: (e) => setState(() => _error = S.of(context).pdfDisplayError),
    );
  }
}
