import 'package:flutter/material.dart';

import '../../../../core/theme/text_styles.dart';
import '../../../../generated/l10n.dart';

class ExampleItemsAppBar extends StatelessWidget {
  const ExampleItemsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 28, end: 28, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                S.of(context).exampleItems,
                style: TextStyles.font24WhiteMedium,
                maxLines: 1,
              ),
              Text(
                S.of(context).exampleItemsSubtitle,
                style: TextStyles.font20WhiteRegular,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
