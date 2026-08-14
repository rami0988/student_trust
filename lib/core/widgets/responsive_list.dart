import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../utils/breakpoints.dart';

/// A list on mobile, a fixed-column grid from tablet width up — the single
/// place this switch lives, so every list screen (chapters, lessons,
/// worksheets, downloads) gets it for free instead of re-implementing it.
///
/// Uses a fixed cell height ([gridItemHeight]) rather than an aspect ratio:
/// these are row-style cards (thumbnail + capped-line text), so height
/// should stay constant while width shrinks per column — an aspect ratio
/// would either overflow or leave dead space as the column count changes.
class ResponsiveList extends StatelessWidget {
  final Breakpoints breakpoints;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double gridItemHeight;
  final ScrollPhysics? physics;

  const ResponsiveList({
    super.key,
    required this.breakpoints,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridItemHeight,
    this.padding = EdgeInsets.zero,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (breakpoints.isMobile) {
      return ListView.separated(
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: itemBuilder,
      );
    }
    return GridView.builder(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: breakpoints.gridColumns,
        mainAxisExtent: gridItemHeight,
        crossAxisSpacing: AppTokens.s12,
        mainAxisSpacing: AppTokens.s12,
      ),
      // Align (not the grid cell's tight constraint) lets each card keep its
      // natural intrinsic height — cards whose content is shorter than
      // [gridItemHeight] (e.g. no worksheet button) just sit at the top of
      // the cell instead of being force-stretched or overflowing.
      itemBuilder: (context, index) => Align(alignment: Alignment.topCenter, child: itemBuilder(context, index)),
    );
  }
}
