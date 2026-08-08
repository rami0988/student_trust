import 'package:injectable/injectable.dart';

import '../../../../core/utils/request_result.dart';
import '../repositories/example_feature_repository.dart';

@injectable
class UnlikeExampleItemUseCase {
  final ExampleFeatureRepository _exampleFeatureRepository;

  UnlikeExampleItemUseCase(this._exampleFeatureRepository);

  Future<RequestResult<void>> call(int itemId) async => await _exampleFeatureRepository.unlikeExampleItem(itemId);
}
