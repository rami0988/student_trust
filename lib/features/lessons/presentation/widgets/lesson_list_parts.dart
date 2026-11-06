import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/chapter_progress.dart';

/// Horizontally scrolling filter chips with counts.
class LessonFilterBar extends StatelessWidget {
  final LessonFilter selected;
  final Map<LessonFilter, int> counts;
  final ValueChanged<LessonFilter> onSelected;

  const LessonFilterBar({super.key, required this.selected, required this.counts, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    String label(LessonFilter f) => switch (f) {
      LessonFilter.all => s.filterAll,
      LessonFilter.inProgress => s.filterInProgress,
      LessonFilter.completed => s.filterCompleted,
      LessonFilter.downloaded => s.filterDownloaded,
    };
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: LessonFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTokens.s8),
        itemBuilder: (context, i) {
          final LessonFilter f = LessonFilter.values[i];
          return _FilterChip(
            label: label(f),
            count: counts[f] ?? 0,
            icon: f == LessonFilter.downloaded ? Icons.offline_pin_rounded : null,
            selected: f == selected,
            onTap: () => onSelected(f),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.count, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.surface : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      label: '$label $count',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.rFull),
          child: AnimatedContainer(
            duration: AppTokens.dMed,
            curve: AppTokens.curve,
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12 + 2),
            decoration: BoxDecoration(
              color: selected ? AppColors.textPrimary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.rFull),
              border: Border.all(color: selected ? AppColors.textPrimary : AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
                Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: 0.2) : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppTokens.rFull),
                  ),
                  child: Text('$count', style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Green strip summarising this chapter's offline lessons.
class OfflineSummary extends StatelessWidget {
  final int count;
  const OfflineSummary({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8 + 2),
      decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: AppTokens.radiusMD),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, size: 18, color: AppColors.success),
          const SizedBox(width: AppTokens.s8 + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.offlineSummary(count), style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(s.offlineSummarySub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "الدروس ………… عرض 6 من 6"
class LessonsSectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const LessonsSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
        if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

/// Loading placeholder shaped like the hero + lesson cards.
class LessonsSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LessonsSkeleton({super.key, this.padding = const EdgeInsets.all(AppTokens.s16)});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ShimmerBox(height: 150, borderRadius: AppTokens.radiusXL),
          const SizedBox(height: AppTokens.s16),
          const Row(
            children: [
              ShimmerBox(width: 70, height: 36),
              SizedBox(width: AppTokens.s8),
              ShimmerBox(width: 100, height: 36),
              SizedBox(width: AppTokens.s8),
              ShimmerBox(width: 80, height: 36),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          for (int i = 0; i < 5; i++) ...[
            Container(
              padding: const EdgeInsets.all(AppTokens.s8 + 2),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 104, height: 82, borderRadius: AppTokens.radiusMD),
                  const SizedBox(width: AppTokens.s12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        ShimmerBox(width: 170, height: 14),
                        SizedBox(height: AppTokens.s8),
                        ShimmerBox(height: 10),
                        SizedBox(height: 6),
                        ShimmerBox(width: 110, height: 10),
                        SizedBox(height: AppTokens.s12),
                        ShimmerBox(width: 64, height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s12),
          ],
        ],
      ),
    );
  }
}
