import 'package:injectable/injectable.dart';

import '../../../../core/entities/pagination_list.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/example_item.dart';
import '../repositories/example_feature_repository.dart';

@injectable
class GetExampleItemsUseCase {
  final ExampleFeatureRepository _exampleFeatureRepository;

  GetExampleItemsUseCase(this._exampleFeatureRepository);

  Future<RequestResult<PaginationList<ExampleItem>>> call(int page) async =>
      await _exampleFeatureRepository.getExampleItems(page);
}
