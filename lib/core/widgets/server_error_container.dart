import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../generated/assets.dart';
import '../../../../generated/l10n.dart';
import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';
import 'custom_app_button.dart';

class ServerErrorContainer extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;

  const ServerErrorContainer({
    super.key,
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: ColorsManager.lightRed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              Assets.iconsServerError,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).serverErrorTitle,
            style: TextStyles.font24SecondaryMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? S.of(context).serverErrorSubtitle,
            style: TextStyles.font16GreyRegular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomAppButton(
            onPressed: onRetry,
            text: S.of(context).retry,
            width: 200,
            backgroundColor: ColorsManager.lightYellow,
            textStyle: TextStyles.font16BrownMedium,
            icon: SvgPicture.asset(Assets.iconsRefresh),
          ),
        ],
      ),
    );
  }
}
