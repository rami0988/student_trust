import 'package:flutter/material.dart';

import '../extensions/colors.dart';
import 'colors_manager.dart';
import 'font_manager.dart';

abstract class TextStyles {
  TextStyles._();

  static const TextStyle font14GrayMedium = TextStyle(
    color: ColorsManager.grey,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font18NavyBlueBold = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 18,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12MediumGreenBold = TextStyle(
    color: ColorsManager.mediumGreen,
    fontSize: 12,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font26WhiteBold = TextStyle(
    color: ColorsManager.white,
    fontSize: 26,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font20WhiteBold = TextStyle(
    color: ColorsManager.white,
    fontSize: 20,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12GreyBold = TextStyle(
    color: ColorsManager.grey,
    fontSize: 12,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12NavyBlueBold = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 12,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12WhiteBold = TextStyle(
    color: ColorsManager.white,
    fontSize: 12,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12GreyMedium = TextStyle(
    color: ColorsManager.grey,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14PrimaryMedium = TextStyle(
    color: ColorsManager.primary,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16BlackBold = TextStyle(
    color: ColorsManager.black,
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font16PrimaryMedium1Height = TextStyle(
    color: ColorsManager.primary,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
    height: 1.3,
  );

  static const TextStyle font14GrayRegular = TextStyle(
    color: ColorsManager.grey,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font18WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 18,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font22OrangeBold = TextStyle(
    color: ColorsManager.orange,
    fontSize: 22,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font14PrimaryRegular = TextStyle(
    color: ColorsManager.primary,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font14NavyBlueRegular = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font14NavyBlueMedium = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14DarkRedMedium = TextStyle(
    color: ColorsManager.darkRed,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14NavyBlueMediumWithDecoration = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
    decoration: TextDecoration.lineThrough,
    decorationThickness: 2,
    decorationStyle: TextDecorationStyle.solid,
    decorationColor: ColorsManager.red,
  );

  static const TextStyle font18NavyBlueMedium = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 18,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14LightYellowMedium = TextStyle(
    color: ColorsManager.lightYellow,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30SecondaryBold = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 30,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font14WhiteRegular = TextStyle(
    color: ColorsManager.white,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font14WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font24WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 24,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font20WhiteRegular = TextStyle(
    color: ColorsManager.white,
    fontSize: 20,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16PrimaryMedium = TextStyle(
    color: ColorsManager.primary,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16PrimaryBold = TextStyle(
    color: ColorsManager.primary,
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font24BlackBold = TextStyle(
    color: ColorsManager.black,
    fontSize: 24,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font20BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 20,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font18BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 18,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16DarkRedMedium = TextStyle(
    color: ColorsManager.darkRed,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font20WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 20,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font18WhiteRegular = TextStyle(
    color: ColorsManager.white,
    fontSize: 18,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font20PrimaryMedium = TextStyle(
    color: ColorsManager.primary,
    fontSize: 20,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font24PrimaryMedium = TextStyle(
    color: ColorsManager.primary,
    fontSize: 24,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14GreyRegular = TextStyle(
    color: ColorsManager.grey,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16BrownMedium = TextStyle(
    color: ColorsManager.brown,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle font16Black60OpacityRegular = TextStyle(
    color: ColorsManager.black.withOpacityValue(0.6),
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16Black90OpacityRegular = TextStyle(
    color: ColorsManager.black.withOpacityValue(0.9),
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16White90OpacityRegular = TextStyle(
    color: ColorsManager.white.withOpacityValue(0.9),
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16PrimaryRegular = TextStyle(
    color: ColorsManager.primary,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16WhiteRegular = TextStyle(
    color: ColorsManager.white,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font12RedRegular = TextStyle(
    color: ColorsManager.red,
    fontSize: 12,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font14White80OpacityRegular = TextStyle(
    color: ColorsManager.white.withOpacityValue(0.8),
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font12WhiteRegular = TextStyle(
    color: ColorsManager.white,
    fontSize: 12,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font10WhiteMedium = TextStyle(
    color: ColorsManager.white,
    fontSize: 10,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16GreyRegular = TextStyle(
    color: ColorsManager.grey,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font24SecondaryMedium = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 24,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14SecondaryMedium = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14SecondarySemiBold = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 14,
    fontWeight: FontWeightHelper.semiBold,
  );

  static const TextStyle font14BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font14SecondaryMediumUnderlined = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
    decoration: TextDecoration.underline,
    decorationColor: ColorsManager.secondary,
  );

  static const TextStyle font16SecondaryMedium = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16SecondaryMedium1Height = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
    height: 1,
  );

  static const TextStyle font16GreyMedium = TextStyle(
    color: ColorsManager.grey,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16OrangeMedium = TextStyle(
    color: ColorsManager.orange,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16NavyBlueRegular = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16NavyBlueMedium = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16NavyBlueBold = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font16RedMedium = TextStyle(
    color: ColorsManager.red,
    fontSize: 16,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font12GreyRegular = TextStyle(
    color: ColorsManager.grey,
    fontSize: 12,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font18BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 18,
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle font14Black70OpacityRegular = TextStyle(
    color: ColorsManager.black.withOpacityValue(0.7),
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font20BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 20,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font24BlackMedium = TextStyle(
    color: ColorsManager.black,
    fontSize: 24,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16SecondaryRegular = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font20SecondaryMedium = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 20,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font18DarkMedium = TextStyle(
    color: Color(0xFF364153),
    fontSize: 18,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font20OrangeMedium = TextStyle(
    color: ColorsManager.orange,
    fontSize: 20,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font18SecondaryMedium = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 18,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font20OrangeBold = TextStyle(
    color: ColorsManager.orange,
    fontSize: 20,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font14SecondaryRegular = TextStyle(
    color: ColorsManager.secondary,
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font16BrownRegular = TextStyle(
    color: ColorsManager.brown,
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font12PrimaryMediumCairoFamily = TextStyle(
    color: ColorsManager.primary,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
    fontFamily: 'Cairo',
  );

  static const TextStyle font12Gray400MediumCairoFamily = TextStyle(
    color: ColorsManager.grey400,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
    fontFamily: 'Cairo',
  );

  static const TextStyle font12GreenMedium = TextStyle(
    color: ColorsManager.green,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font12OrangeMedium = TextStyle(
    color: ColorsManager.orange,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14BrownMedium = TextStyle(
    color: ColorsManager.brown,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14PrimarySemiBold = TextStyle(
    color: ColorsManager.primary,
    fontSize: 14,
    fontWeight: FontWeightHelper.semiBold,
  );

  static const TextStyle font20NavyBlueBold = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 20,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font12BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 12,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font24OrangeBold = TextStyle(
    color: ColorsManager.orange,
    fontSize: 24,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font40BlackRegular = TextStyle(
    color: ColorsManager.black,
    fontSize: 40,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font30GreenMedium = TextStyle(
    color: ColorsManager.green,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30OrangeMedium = TextStyle(
    color: ColorsManager.orange,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30NavyBlueMedium = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font30PrimaryMedium = TextStyle(
    color: ColorsManager.primary,
    fontSize: 30,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font14OrangeMedium = TextStyle(
    color: ColorsManager.orange,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font12NavyBlueMedium = TextStyle(
    color: ColorsManager.navyBlue,
    fontSize: 12,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16WhiteBold = TextStyle(
    color: ColorsManager.white,
    fontSize: 16,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font14LightYellowBold = TextStyle(
    color: ColorsManager.lightYellow,
    fontSize: 14,
    fontWeight: FontWeightHelper.bold,
  );

  static const TextStyle font14GreenMedium = TextStyle(
    color: ColorsManager.green,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );

  static const TextStyle font16GreenSemiBold = TextStyle(
    color: ColorsManager.green,
    fontSize: 16,
    fontWeight: FontWeightHelper.semiBold,
  );

  static const TextStyle font13GreenRegular = TextStyle(
    color: ColorsManager.green,
    fontSize: 13,
    fontWeight: FontWeightHelper.regular,
  );

  static const TextStyle font14RedMedium = TextStyle(
    color: ColorsManager.red,
    fontSize: 14,
    fontWeight: FontWeightHelper.medium,
  );
}
