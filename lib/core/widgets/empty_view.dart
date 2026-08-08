import 'package:flutter/material.dart';

import '../extensions/strings.dart';
import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmptyView({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 96,
              color: ColorsManager.darkGrey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyles.font18BlackRegular,
              textAlign: TextAlign.center,
            ),
            if (!subtitle.isNullOrEmpty())
              Text(
                subtitle!,
                style: TextStyles.font14GreyRegular,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
