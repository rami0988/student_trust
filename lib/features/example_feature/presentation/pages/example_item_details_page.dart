import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/navigation.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loader.dart';
import '../cubit/example_item_details_cubit.dart';
import '../cubit/example_item_details_state.dart';
import 'example_item_details_args.dart';

class ExampleItemDetailsPage extends StatelessWidget {
  final ExampleItemDetailsArgs args;
  const ExampleItemDetailsPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      topPadding: 120,
      body: BlocBuilder<ExampleItemDetailsCubit, ExampleItemDetailsState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return const Center(child: Loader());
          }

          if (state.status.isFailure) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => context.read<ExampleItemDetailsCubit>().getExampleItem(),
            );
          }

          final item = state.item;
          if (!state.status.isSuccess || item == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyles.font20BlackMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<ExampleItemDetailsCubit>().toggleLike(),
                      icon: Icon(
                        item.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: item.isLiked ? ColorsManager.red : ColorsManager.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.description,
                  style: TextStyles.font16BlackRegular,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        Positioned(
          left: 0,
          right: 0,
          top: 8,
          child: SafeArea(
            child: CustomBackButton(onTap: () => context.pop()),
          ),
        ),
      ],
    );
  }
}
