// Reference bloc test: copy this pattern for new blocs.
//
// Regenerate mocks after changing the mocked classes:
//   dart run build_runner build --delete-conflicting-outputs
import 'package:mobile_template/core/entities/pagination_list.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/utils/app_enums.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/example_feature/domain/entities/example_item.dart';
import 'package:mobile_template/features/example_feature/domain/use_cases/get_example_items_use_case.dart';
import 'package:mobile_template/features/example_feature/domain/use_cases/like_example_item_use_case.dart';
import 'package:mobile_template/features/example_feature/domain/use_cases/unlike_example_item_use_case.dart';
import 'package:mobile_template/features/example_feature/presentation/bloc/example_feature_bloc.dart';
import 'package:mobile_template/features/example_feature/presentation/bloc/example_feature_event.dart';
import 'package:mobile_template/features/example_feature/presentation/bloc/example_feature_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'example_feature_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetExampleItemsUseCase>(),
  MockSpec<LikeExampleItemUseCase>(),
  MockSpec<UnlikeExampleItemUseCase>(),
])
void main() {
  late MockGetExampleItemsUseCase getExampleItemsUseCase;
  late MockLikeExampleItemUseCase likeExampleItemUseCase;
  late MockUnlikeExampleItemUseCase unlikeExampleItemUseCase;
  late EventBus eventBus;

  const ExampleItem item = ExampleItem(
    id: 1,
    title: 'First item',
    description: 'Description',
    isLiked: false,
  );

  const ServerFailure serverFailure = ServerFailure('Something went wrong', 500);

  setUp(() {
    getExampleItemsUseCase = MockGetExampleItemsUseCase();
    likeExampleItemUseCase = MockLikeExampleItemUseCase();
    unlikeExampleItemUseCase = MockUnlikeExampleItemUseCase();
    eventBus = EventBus();
  });

  ExampleFeatureBloc buildBloc() => ExampleFeatureBloc(
    getExampleItemsUseCase,
    likeExampleItemUseCase,
    unlikeExampleItemUseCase,
    eventBus,
  );

  group('GetExampleItems', () {
    blocTest<ExampleFeatureBloc, ExampleFeatureState>(
      'emits [loading, success] with the fetched page when the use case succeeds',
      build: () {
        when(getExampleItemsUseCase(1)).thenAnswer(
          (_) async => const SuccessResult(
            PaginationList<ExampleItem>(data: [item], isLastPage: true),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(GetExampleItems((b) => b..reInitialData = false)),
      // The states hold plain List fields, so compare fields with matchers
      // instead of whole state instances.
      expect: () => [
        isA<ExampleFeatureState>().having((s) => s.status, 'status', Status.loading),
        isA<ExampleFeatureState>()
            .having((s) => s.status, 'status', Status.success)
            .having((s) => s.items.items, 'items', [item])
            .having((s) => s.items.currentPage, 'currentPage', 2)
            .having((s) => s.items.isFinished, 'isFinished', true)
            .having((s) => s.items.isLoading, 'isLoading', false),
      ],
    );

    blocTest<ExampleFeatureBloc, ExampleFeatureState>(
      'emits [loading, failure] when the use case fails on the first page',
      build: () {
        when(getExampleItemsUseCase(1)).thenAnswer(
          (_) async => const FailureResult(serverFailure),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(GetExampleItems((b) => b..reInitialData = false)),
      expect: () => [
        isA<ExampleFeatureState>().having((s) => s.status, 'status', Status.loading),
        isA<ExampleFeatureState>()
            .having((s) => s.status, 'status', Status.failure)
            .having((s) => s.failure, 'failure', serverFailure),
      ],
    );
  });

  group('LikeExampleItem', () {
    blocTest<ExampleFeatureBloc, ExampleFeatureState>(
      'updates the item optimistically through the EventBus',
      build: () {
        when(likeExampleItemUseCase(1)).thenAnswer(
          (_) async => const SuccessResult(null),
        );
        return buildBloc();
      },
      seed: () => ExampleFeatureState.initial().rebuild(
        (b) => b
          ..status = Status.success
          ..items.items = [item],
      ),
      act: (bloc) => bloc.add(LikeExampleItem((b) => b..itemId = 1)),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<ExampleFeatureState>().having(
          (s) => s.items.items,
          'items',
          [item.copyWith(isLiked: true)],
        ),
      ],
      verify: (_) => verify(likeExampleItemUseCase(1)).called(1),
    );
  });
}
