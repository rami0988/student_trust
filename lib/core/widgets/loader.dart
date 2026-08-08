import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/colors_manager.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double? size;
  const Loader({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: color ?? ColorsManager.primary,
      size: size ?? 50,
    );
  }
}
