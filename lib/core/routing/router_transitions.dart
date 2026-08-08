import 'package:flutter/material.dart';

abstract class RouterTransitions {
  RouterTransitions._();
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

  static MaterialPageRoute buildDefault(
    Widget widget, {
    RouteSettings? settings,
  }) {
    return MaterialPageRoute(settings: settings, builder: (_) => widget);
  }
}
