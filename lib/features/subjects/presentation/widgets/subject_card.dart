import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/subject.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({super.key, required this.subject, required this.onTap});

  /// Shared Hero tag so the thumbnail can fly into the Chapters page header
  /// — see [ChaptersPage]'s header, which Heroes the same tag.
  static String heroTag(String subjectId) => 'subject-thumb-$subjectId';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: subject.name,
      child: PressableScale(
        onTap: subject.isSubscribed ? onTap : null,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: heroTag(subject.id),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (subject.thumbnailUrl != null && subject.thumbnailUrl!.isNotEmpty)
                        AppNetworkImage(url: subject.thumbnailUrl!)
                      else
                        const DecoratedBox(
                          decoration: BoxDecoration(gradient: AppTokens.brandGradient),
                          child: Icon(Icons.menu_book_rounded, size: 44, color: Colors.white70),
                        ),
                      Positioned(top: AppTokens.s8, right: AppTokens.s8, child: _SubscriptionBadge(isSubscribed: subject.isSubscribed)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppTokens.s12, AppTokens.s12, AppTokens.s12, AppTokens.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    if (subject.teacherName != null) ...[
                      const SizedBox(height: AppTokens.s4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: AppTokens.s4),
                          Expanded(
                            child: Text(
                              subject.teacherName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (subject.grade != null && subject.grade!.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppTokens.rSM)),
                        child: Text(
                          subject.grade!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  final bool isSubscribed;
  const _SubscriptionBadge({required this.isSubscribed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isSubscribed ? AppColors.success : AppColors.textSecondary, borderRadius: BorderRadius.circular(AppTokens.rFull)),
      child: Text(
        isSubscribed ? S.of(context).subscribed : S.of(context).notSubscribed,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
