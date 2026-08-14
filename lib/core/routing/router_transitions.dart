import 'package:flutter/material.dart';

import '../widgets/app_motion.dart' show isReducedMotionEnabled;

abstract class RouterTransitions {
  RouterTransitions._();

  static const Duration _duration = Duration(milliseconds: 300);
  static const Curve _curve = Curves.easeInOutCubic;

  static PageRouteBuilder buildVertical(
    Widget widget, {
    RouteSettings? routeSettings,
  }) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, animation, secondaryAnimation) => widget,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder buildHorizontal(
    Widget widget, {
    RouteSettings? routeSettings,
  }) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, _, _) => widget,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder buildFade(
    Widget widget, {
    RouteSettings? routeSettings,
  }) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, _, _) => widget,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder buildScale(
    Widget widget, {
    RouteSettings? routeSettings,
  }) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, _, _) => widget,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  /// The app-wide default push transition: the incoming page slides in from
  /// the leading edge (right in RTL, left in LTR — so it always reads as
  /// "forward") while fading in, and the outgoing page fades out slightly.
  /// Falls back to an instant cut when the OS "reduce motion" setting is on.
  static PageRoute buildDefault(
    Widget widget, {
    RouteSettings? settings,
  }) {
    if (isReducedMotionEnabled) {
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => widget,
      );
    }

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      pageBuilder: (_, _, _) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bool isRtl = Directionality.of(context) == TextDirection.rtl;
        final Offset begin = Offset(isRtl ? -1 : 1, 0);
        final CurvedAnimation curved = CurvedAnimation(parent: animation, curve: _curve, reverseCurve: _curve.flipped);

        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }
}
