import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/worksheet.dart';

class WorksheetCard extends StatelessWidget {
  final Worksheet worksheet;
  final VoidCallback onTap;

  const WorksheetCard({super.key, required this.worksheet, required this.onTap});

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppTokens.rSM)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppTokens.s4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: worksheet.title,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: AppTokens.radiusMD),
                  child: const Icon(Icons.assignment_rounded, color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: AppTokens.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worksheet.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      if (worksheet.description != null && worksheet.description!.isNotEmpty) ...[
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          worksheet.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: AppTokens.s8),
                      Wrap(
                        spacing: AppTokens.s8,
                        runSpacing: AppTokens.s4,
                        children: [
                          _chip(Icons.picture_as_pdf_rounded, S.of(context).filesCount(worksheet.filesCount), AppColors.primary),
                          _chip(Icons.play_circle_outline_rounded, S.of(context).solutionVideosCount(worksheet.videosCount), AppColors.accent),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
