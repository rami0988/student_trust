import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../extensions/colors.dart';
import '../extensions/strings.dart';
import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';
import '../utils/constants.dart';
import '../utils/language_helper.dart';
import '../utils/logger.dart';

class CustomCountryCodePicker extends StatelessWidget {
  final String? countryCode;
  final void Function(String) onChanged;

  const CustomCountryCodePicker({
    super.key,
    required this.onChanged,
    this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      initialSelection: countryCode ?? Constants.countryCode,
      countryFilter: Constants.countryFilter,
      backgroundColor: ColorsManager.primary,
      dialogBackgroundColor: ColorsManager.primary,
      searchStyle: TextStyles.font16WhiteRegular,
      dialogTextStyle: TextStyles.font14WhiteRegular,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      topBarPadding: const EdgeInsets.only(top: 12, right: 24, left: 24),
      searchPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      builder: (countryCode) {
        return Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: LanguageHelper.isEnglishLocale(context)
                  ? BorderSide.none
                  : BorderSide(
                      color: ColorsManager.grey.withOpacityValue(0.3),
                      width: 1,
                    ),
              end: LanguageHelper.isEnglishLocale(context)
                  ? BorderSide(
                      color: ColorsManager.grey.withOpacityValue(0.3),
                      width: 1,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: ColorsManager.grey,
              ),
              const SizedBox(width: 6),
              Text(
                countryCode?.dialCode ?? '',
                style: TextStyles.font16GreyRegular,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(width: 6),
              if (countryCode != null)
                Container(
                  height: 14,
                  width: 23,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        countryCode.flagUri!,
                        package: 'country_code_picker',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      headerText: S.of(context).selectCountry,
      headerTextStyle: TextStyles.font20WhiteMedium,
      closeIcon: const Icon(Icons.close_rounded, color: ColorsManager.white),
      boxDecoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, -0.00),
          end: Alignment(0.50, 1.00),
          colors: [ColorsManager.primary, ColorsManager.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      searchDecoration: InputDecoration(
        hintText: S.of(context).search,
        hintStyle: TextStyles.font16WhiteRegular,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: 16, end: 6),
          child: Icon(
            Icons.search_rounded,
            size: 24,
            color: ColorsManager.white,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, maxWidth: 42),
        filled: true,
        fillColor: ColorsManager.white.withOpacityValue(0.1),
        enabledBorder: _buildBorder(
          ColorsManager.white.withOpacityValue(0.2),
          1.3,
        ),
        focusedBorder: _buildBorder(ColorsManager.white, 1.4),
        disabledBorder: _buildBorder(ColorsManager.white, 1.3),
      ),
      onChanged: (value) {
        Logger.debug(name: 'CountryCodeField', 'Selected country code: $value');
        if (!value.dialCode.isNullOrEmpty()) {
          onChanged(value.dialCode!);
        }
      },
    );
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
