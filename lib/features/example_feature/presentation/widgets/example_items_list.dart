import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loader.dart';
import '../bloc/example_feature_bloc.dart';
import '../bloc/example_feature_event.dart';
import '../bloc/example_feature_state.dart';
import 'example_item_card.dart';

class ExampleItemsList extends StatelessWidget {
  const ExampleItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExampleFeatureBloc, ExampleFeatureState>(
      builder: (context, state) {
        return ListView.separated(
          controller: context.read<ExampleFeatureBloc>().scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemCount: !state.items.isFinished && state.items.items.isNotEmpty
              ? state.items.items.length + 1
              : state.items.items.length,
          itemBuilder: (BuildContext context, int index) {
            if (index >= state.items.items.length && !state.items.isFinished) {
              return const Center(child: Loader());
            }
            final item = state.items.items[index];
            return ExampleItemCard(
              item: item,
              onLikeChanged: (isLiked) {
                if (isLiked) {
                  context.read<ExampleFeatureBloc>().add(
                    UnlikeExampleItem((b) => b..itemId = item.id),
                  );
                } else {
                  context.read<ExampleFeatureBloc>().add(
                    LikeExampleItem((b) => b..itemId = item.id),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
