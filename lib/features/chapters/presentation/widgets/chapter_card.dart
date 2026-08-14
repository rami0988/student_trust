import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/chapter.dart';

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final int number;
  final VoidCallback onTap;
  final VoidCallback onWorksheetsTap;

  const ChapterCard({super.key, required this.chapter, required this.number, required this.onTap, required this.onWorksheetsTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: chapter.title,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(gradient: AppTokens.brandGradient, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    const SizedBox(width: AppTokens.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppTokens.s4),
                          Text(S.of(context).lessons, maxLines: 1, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded, color: AppColors.textTertiary),
                  ],
                ),
                if (chapter.worksheetCount > 0) ...[
                  const SizedBox(height: AppTokens.s8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusSM),
                      ),
                      icon: const Icon(Icons.assignment, size: 18),
                      label: Text(S.of(context).worksheetsWithCount(chapter.worksheetCount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onPressed: onWorksheetsTap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
