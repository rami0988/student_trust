import '../models/example_item_model.dart';
import '../models/example_items_pagination_model.dart';

abstract class ExampleFeatureRemoteDataSource {
  Future<ExampleItemsPaginationModel> getExampleItems(int page);
  Future<ExampleItemModel> getExampleItemById(int itemId);
  Future<void> likeExampleItem(int itemId);
  Future<void> unlikeExampleItem(int itemId);
}
