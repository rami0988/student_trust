import 'package:injectable/injectable.dart';

import '../../../../core/utils/request_result.dart';
import '../repositories/example_feature_repository.dart';

@injectable
class LikeExampleItemUseCase {
  final ExampleFeatureRepository _exampleFeatureRepository;

  LikeExampleItemUseCase(this._exampleFeatureRepository);

  Future<RequestResult<void>> call(int itemId) async => await _exampleFeatureRepository.likeExampleItem(itemId);
}
