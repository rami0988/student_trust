import 'package:flutter/material.dart';

enum DeviceSize { mobile, tablet, desktop }

/// Width-based responsive tier, resolved once per page from the constraints
/// a `LayoutBuilder` gives it — never read `MediaQuery`/`LayoutBuilder`
/// inside a leaf widget; compute a [Breakpoints] at the page root and pass
/// the plain values (padding, columns, maxContentWidth, …) down instead.
///
/// Tiers: mobile < 600, tablet 600–900, desktop > 900 (logical pixels).
class Breakpoints {
  final double width;
  final DeviceSize size;

  const Breakpoints._(this.width, this.size);

  factory Breakpoints.of(double width) {
    final DeviceSize size = width >= 900
        ? DeviceSize.desktop
        : width >= 600
        ? DeviceSize.tablet
        : DeviceSize.mobile;
    return Breakpoints._(width, size);
  }

  /// Convenience for reading the current tier off `MediaQuery` — use only at
  /// a page's root `build`, not inside nested widgets.
  factory Breakpoints.of_(BuildContext context) => Breakpoints.of(MediaQuery.sizeOf(context).width);

  bool get isMobile => size == DeviceSize.mobile;
  bool get isTablet => size == DeviceSize.tablet;
  bool get isDesktop => size == DeviceSize.desktop;
  bool get isTabletOrLarger => size != DeviceSize.mobile;

  /// Page horizontal padding: 16 / 24 / 32.
  double get horizontalPadding => switch (size) {
    DeviceSize.mobile => 16,
    DeviceSize.tablet => 24,
    DeviceSize.desktop => 32,
  };

  /// Caps how wide a page's content column gets on larger screens; `null` on
  /// mobile (no cap — the screen is already narrow). Wrap the page body in
  /// `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: ...)))`
  /// when non-null.
  double? get maxContentWidth => switch (size) {
    DeviceSize.mobile => null,
    DeviceSize.tablet => 800,
    DeviceSize.desktop => 900,
  };

  /// Grid column count for card grids (subjects, and lists promoted to a
  /// grid at tablet width and up).
  int get gridColumns => switch (size) {
    DeviceSize.mobile => 2,
    DeviceSize.tablet => 3,
    DeviceSize.desktop => 4,
  };

  /// Headline text size: 22 / 26 / 30.
  double get headlineSize => switch (size) {
    DeviceSize.mobile => 22,
    DeviceSize.tablet => 26,
    DeviceSize.desktop => 30,
  };

  /// Body text size: 14 / 16 / 16.
  double get bodySize => switch (size) {
    DeviceSize.mobile => 14,
    DeviceSize.tablet => 16,
    DeviceSize.desktop => 16,
  };
}
