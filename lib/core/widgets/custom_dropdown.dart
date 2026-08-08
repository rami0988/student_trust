import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final String hintText;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onSelected;
  final String Function(T)? itemAsString;
  final String? Function(T?)? validator;
  final bool showSearchBox;
  final String searchHintText;
  final bool enabled;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FutureOr<List<T>> Function(String filter, LoadProps? loadProps)? asyncItems;
  final Widget Function(BuildContext, String)? loadingBuilder;
  final DropdownSearchPopupItemBuilder<T>? popupItemBuilder;
  final bool Function(T)? popupItemEnabled;
  final TextStyle? itemStyle;
  final double maxHeight;

  const CustomDropdown({
    super.key,
    this.title,
    this.titleStyle,
    required this.hintText,
    this.items = const [],
    this.selectedItem,
    this.onSelected,
    this.itemAsString,
    this.validator,
    this.showSearchBox = false,
    this.searchHintText = '',
    this.enabled = true,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.5,
    this.fillColor,
    this.contentPadding,
    this.suffixIcon,
    this.prefixIcon,
    this.asyncItems,
    this.loadingBuilder,
    this.popupItemBuilder,
    this.popupItemEnabled,
    this.itemStyle,
    this.maxHeight = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: titleStyle ?? TextStyles.font14BlackMedium,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
        ],
        DropdownSearch<T>(
          enabled: enabled,
          selectedItem: selectedItem,
          items:
              asyncItems ??
              (String filter, LoadProps? _) {
                if (filter.isEmpty) return items;
                return items
                    .where(
                      (T item) => (itemAsString?.call(item) ?? item.toString()).toLowerCase().contains(
                        filter.toLowerCase(),
                      ),
                    )
                    .toList();
              },
          itemAsString: itemAsString,
          compareFn: (T a, T b) => a == b,
          dropdownBuilder: (BuildContext context, T? selectedItem) {
            if (selectedItem == null) return const SizedBox.shrink();
            return Text(
              itemAsString?.call(selectedItem) ?? selectedItem.toString(),
              style: TextStyles.font16Black60OpacityRegular,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
          onSelected: onSelected,
          validator: validator,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          suffixProps: const DropdownSuffixProps(
            dropdownButtonProps: DropdownButtonProps(
              iconClosed: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorsManager.grey,
                size: 22,
              ),
              iconOpened: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorsManager.primary,
                size: 22,
              ),
            ),
            clearButtonProps: ClearButtonProps(isVisible: false),
          ),
          decoratorProps: DropDownDecoratorProps(
            textAlignVertical: TextAlignVertical.center,
            baseStyle: TextStyles.font16Black60OpacityRegular,
            decoration: InputDecoration(
              hintText: hintText,
              hintMaxLines: 1,
              hintStyle: TextStyles.font16Black60OpacityRegular,
              contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: prefixIcon,
              prefixIconConstraints: prefixIcon != null ? const BoxConstraints(minWidth: 36, maxWidth: 42) : null,
              filled: true,
              fillColor: fillColor ?? ColorsManager.lightGrey,
              enabledBorder: _buildBorder(
                borderColor ?? ColorsManager.transparent,
                borderWidth,
              ),
              focusedBorder: _buildBorder(ColorsManager.primary, borderWidth),
              errorBorder: _buildBorder(ColorsManager.red, borderWidth),
              focusedErrorBorder: _buildBorder(ColorsManager.red, borderWidth),
              disabledBorder: _buildBorder(
                ColorsManager.transparent,
                borderWidth,
              ),
              errorMaxLines: 2,
              errorStyle: TextStyles.font12RedRegular,
            ),
          ),
          popupProps: PopupProps<T>.menu(
            showSearchBox: showSearchBox,
            fit: FlexFit.loose,
            constraints: BoxConstraints(maxHeight: maxHeight),
            listViewProps: const ListViewProps(
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            itemClickProps: ClickProps(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              splashColor: ColorsManager.transparent,
              highlightColor: ColorsManager.transparent,
            ),
            menuProps: MenuProps(
              shape: null,
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              backgroundColor: ColorsManager.white,
              elevation: 4,
              shadowColor: ColorsManager.grey.withValues(alpha: 0.2),
            ),
            scrollbarProps: const ScrollbarProps(
              radius: Radius.circular(14),
              crossAxisMargin: 1.5,
              mainAxisMargin: 12,
              padding: EdgeInsets.zero,
              thickness: 2,
              thumbColor: ColorsManager.grey,
              trackColor: ColorsManager.lightGrey,
              trackBorderColor: ColorsManager.lightGrey,
            ),
            searchFieldProps: showSearchBox
                ? TextFieldProps(
                    cursorColor: ColorsManager.primary,
                    style: TextStyles.font16Black60OpacityRegular,
                    decoration: InputDecoration(
                      hintText: searchHintText.isNotEmpty ? searchHintText : hintText,
                      hintStyle: TextStyles.font16Black60OpacityRegular,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: ColorsManager.grey,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: ColorsManager.lightGrey,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorsManager.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorsManager.primary,
                          width: 1.5,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : const TextFieldProps(),
            itemBuilder: popupItemBuilder ?? _defaultItemBuilder,
            loadingBuilder: loadingBuilder,
            disabledItemFn: popupItemEnabled != null ? (T item) => !(popupItemEnabled!(item)) : null,
          ),
        ),
      ],
    );
  }

  Widget _defaultItemBuilder(
    BuildContext context,
    T item,
    bool isDisabled,
    bool isSelected,
  ) {
    final int index = items.indexOf(item);
    final bool isLast = index == items.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? ColorsManager.primary.withValues(alpha: 0.08) : ColorsManager.transparent,
        borderRadius: isLast ? BorderRadius.circular(borderRadius ?? 16) : null,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: ColorsManager.grey.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              itemAsString?.call(item) ?? item.toString(),
              style: (itemStyle ?? TextStyles.font16Black60OpacityRegular).copyWith(
                color: isDisabled
                    ? ColorsManager.grey.withValues(alpha: 0.4)
                    : isSelected
                    ? ColorsManager.primary
                    : ColorsManager.black,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              color: ColorsManager.primary,
              size: 18,
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
