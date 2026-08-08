// Reference repository test: copy this pattern for new repositories.
//
// Regenerate mocks after changing the mocked classes:
//   dart run build_runner build --delete-conflicting-outputs
import 'package:mobile_template/core/error/exceptions.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/features/example_feature/data/data_sources/example_feature_remote_data_source.dart';
import 'package:mobile_template/features/example_feature/data/models/example_item_model.dart';
import 'package:mobile_template/features/example_feature/data/models/example_items_pagination_model.dart';
import 'package:mobile_template/features/example_feature/data/repositories/example_feature_repository_impl.dart';
import 'package:mobile_template/features/example_feature/domain/entities/example_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'example_feature_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ExampleFeatureRemoteDataSource>()])
void main() {
  late MockExampleFeatureRemoteDataSource remoteDataSource;
  late ExampleFeatureRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockExampleFeatureRemoteDataSource();
    repository = ExampleFeatureRepositoryImpl(remoteDataSource);
  });

  group('getExampleItems', () {
    test('maps models to domain entities and detects the last page', () async {
      when(remoteDataSource.getExampleItems(2)).thenAnswer(
        (_) async => ExampleItemsPaginationModel(
          items: [
            ExampleItemModel(
              id: 1,
              title: 'First item',
              description: 'Description',
              isLiked: true,
            ),
          ],
          lastPage: 2,
        ),
      );

      final result = await repository.getExampleItems(2);

      expect(result.isSuccess, isTrue);
      result.fold(
        failure: (_) => fail('Expected success'),
        success: (paginationList) {
          expect(paginationList.isLastPage, isTrue);
          expect(paginationList.data, const [
            ExampleItem(
              id: 1,
              title: 'First item',
              description: 'Description',
              isLiked: true,
            ),
          ]);
        },
      );
    });

    test('returns a ServerFailure when the data source throws a ServerException', () async {
      when(remoteDataSource.getExampleItems(1)).thenThrow(
        ServerException('Something went wrong', 500),
      );

      final result = await repository.getExampleItems(1);

      expect(result.isFailure, isTrue);
      result.fold(
        failure: (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.statusMessage, 'Something went wrong');
        },
        success: (_) => fail('Expected failure'),
      );
    });
  });

  group('likeExampleItem', () {
    test('returns success when the data source completes', () async {
      when(remoteDataSource.likeExampleItem(1)).thenAnswer((_) async {});

      final result = await repository.likeExampleItem(1);

      expect(result.isSuccess, isTrue);
    });
  });
}
