import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../generated/l10n.dart';
import '../bloc/example_feature_bloc.dart';
import '../bloc/example_feature_event.dart';
import '../bloc/example_feature_state.dart';
import '../widgets/example_item_card_shimmer.dart';
import '../widgets/example_items_app_bar.dart';
import '../widgets/example_items_list.dart';

class ExampleItemsPage extends StatelessWidget {
  const ExampleItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: BlocBuilder<ExampleFeatureBloc, ExampleFeatureState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return const _ShimmerList();
          }

          if (state.status.isEmpty) {
            return EmptyView(
              title: S.of(context).emptyExampleItemsTitle,
              subtitle: S.of(context).emptyExampleItemsSubtitle,
            );
          }

          if (state.status.isFailure) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => context.read<ExampleFeatureBloc>().add(
                GetExampleItems((b) => b..reInitialData = true),
              ),
            );
          }

          if (state.status.isSuccess) {
            return CustomRefreshIndicator(
              onRefresh: () {
                context.read<ExampleFeatureBloc>().add(
                  GetExampleItems((b) => b..reInitialData = true),
                );
              },
              child: const ExampleItemsList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      actions: const [ExampleItemsAppBar()],
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ExampleItemCardShimmer(),
    );
  }
}
