import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';
import '../../generated/l10n.dart';
import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';
import '../utils/language_helper.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;
  const CustomBackButton({
    super.key,
    required this.onTap,
    this.margin = const EdgeInsetsDirectional.only(
      start: 28,
      end: 6,
      top: 14,
      bottom: 14,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: margin,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(0.50, -0.00),
                end: Alignment(0.50, 1.00),
                colors: [ColorsManager.yellow, ColorsManager.orange],
              ),
            ),
            child: RotatedBox(
              quarterTurns: LanguageHelper.isEnglishLocale(context) ? 2 : 0,
              child: SvgPicture.asset(Assets.iconsBack),
            ),
          ),
          SizedBox(
            height: LanguageHelper.isEnglishLocale(context) ? null : 30,
            child: Text(
              S.of(context).back,
              style: TextStyles.font16WhiteMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
