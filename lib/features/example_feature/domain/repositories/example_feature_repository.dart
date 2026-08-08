import '../../../../core/entities/pagination_list.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/example_item.dart';

abstract class ExampleFeatureRepository extends BaseRepository {
  Future<RequestResult<PaginationList<ExampleItem>>> getExampleItems(int page);
  Future<RequestResult<ExampleItem>> getExampleItemById(int itemId);
  Future<RequestResult<void>> likeExampleItem(int itemId);
  Future<RequestResult<void>> unlikeExampleItem(int itemId);
}
