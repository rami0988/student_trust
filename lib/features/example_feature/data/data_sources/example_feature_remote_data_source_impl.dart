import 'package:injectable/injectable.dart';

import '../../../../core/data_source/remote/base_remote_data_source_impl.dart';
import '../../../../core/models/base_model.dart';
import '../../../../core/network/endpoints.dart';
import '../models/example_item_model.dart';
import '../models/example_items_pagination_model.dart';
import 'example_feature_remote_data_source.dart';

@LazySingleton(as: ExampleFeatureRemoteDataSource)
class ExampleFeatureRemoteDataSourceImpl extends BaseRemoteDataSourceImpl implements ExampleFeatureRemoteDataSource {
  ExampleFeatureRemoteDataSourceImpl(super._dio);

  @override
  Future<ExampleItemsPaginationModel> getExampleItems(int page) async {
    final BaseModel baseModel = await performGetRequest(
      endpoint: Endpoints.exampleItems,
      queryParameters: {'page': page},
    );
    return ExampleItemsPaginationModel.fromJson(baseModel.toJson());
  }

  @override
  Future<ExampleItemModel> getExampleItemById(int itemId) async {
    final BaseModel baseModel = await performGetRequest(
      endpoint: Endpoints.exampleItemById(itemId),
    );
    return ExampleItemModel.fromJson(baseModel.data);
  }

  @override
  Future<void> likeExampleItem(int itemId) async => await performPutRequest(
    endpoint: Endpoints.likeExampleItem(itemId),
  );

  @override
  Future<void> unlikeExampleItem(int itemId) async => await performDeleteRequest(
    endpoint: Endpoints.likeExampleItem(itemId),
  );
}
