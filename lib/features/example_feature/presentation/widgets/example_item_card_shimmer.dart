import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_loading.dart';

class ExampleItemCardShimmer extends StatelessWidget {
  const ExampleItemCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      height: 88,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );
  }
}
