import 'package:injectable/injectable.dart';

import '../../../../core/entities/pagination_list.dart';
import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/example_item.dart';
import '../../domain/repositories/example_feature_repository.dart';
import '../data_sources/example_feature_remote_data_source.dart';

@LazySingleton(as: ExampleFeatureRepository)
class ExampleFeatureRepositoryImpl extends BaseRepositoryImpl implements ExampleFeatureRepository {
  final ExampleFeatureRemoteDataSource _exampleFeatureRemoteDataSource;

  ExampleFeatureRepositoryImpl(
    this._exampleFeatureRemoteDataSource,
  ) : super('ExampleFeatureRepository');

  @override
  Future<RequestResult<PaginationList<ExampleItem>>> getExampleItems(int page) => execute(
    () => _exampleFeatureRemoteDataSource.getExampleItems(page),
    converter: (dataModel) => PaginationList<ExampleItem>(
      data: dataModel.items.map((item) => item.toDomain()).toList(),
      isLastPage: dataModel.lastPage == page,
    ),
  );

  @override
  Future<RequestResult<ExampleItem>> getExampleItemById(int itemId) => execute(
    () => _exampleFeatureRemoteDataSource.getExampleItemById(itemId),
    converter: (dataModel) => dataModel.toDomain(),
  );

  @override
  Future<RequestResult<void>> likeExampleItem(int itemId) => execute(
    () => _exampleFeatureRemoteDataSource.likeExampleItem(itemId),
  );

  @override
  Future<RequestResult<void>> unlikeExampleItem(int itemId) => execute(
    () => _exampleFeatureRemoteDataSource.unlikeExampleItem(itemId),
  );
}
