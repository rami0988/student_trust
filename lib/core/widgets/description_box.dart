import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';
import '../../generated/l10n.dart';

class DescriptionBox extends StatefulWidget {
  final String description;
  final String title;
  final EdgeInsetsGeometry? margin;

  const DescriptionBox({
    super.key,
    required this.title,
    required this.description,
    this.margin,
  });

  @override
  State<DescriptionBox> createState() => _DescriptionBoxState();
}

class _DescriptionBoxState extends State<DescriptionBox> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: widget.margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: widget.description, style: TextStyles.font14NavyBlueRegular),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: constraints.maxWidth);
          final bool isOverflowing = painter.computeLineMetrics().length > 3;
          painter.dispose();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                widget.title,
                style: TextStyles.font16PrimaryBold,
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  widget.description,
                  style: TextStyles.font14NavyBlueRegular,
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              if (isOverflowing)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text(
                        _isExpanded ? S.of(context).showLess : S.of(context).showMore,
                        style: TextStyles.font14PrimaryRegular,
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: ColorsManager.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
