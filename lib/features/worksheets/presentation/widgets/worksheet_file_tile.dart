import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/worksheet_file.dart';

class WorksheetFileTile extends StatelessWidget {
  final WorksheetFile file;
  final double? progress;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  const WorksheetFileTile({super.key, required this.file, required this.progress, required this.isSaved, required this.onOpen, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final bool isDownloading = progress != null;
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: AppTokens.radiusSM),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 22),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(file.sizeLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                TextButton(onPressed: onOpen, child: Text(S.of(context).open)),
                if (isDownloading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTokens.s8),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  )
                else
                  Semantics(
                    button: true,
                    label: S.of(context).downloadToDeviceTooltip,
                    child: IconButton(
                      tooltip: S.of(context).downloadToDeviceTooltip,
                      icon: Icon(isSaved ? Icons.download_done_rounded : Icons.download_rounded, color: isSaved ? AppColors.success : AppColors.primary),
                      onPressed: onDownload,
                    ),
                  ),
              ],
            ),
            if (isDownloading)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s8, left: AppTokens.s8, right: AppTokens.s8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.rFull),
                  child: LinearProgressIndicator(
                    value: progress! > 0 ? progress : null,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    minHeight: 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
