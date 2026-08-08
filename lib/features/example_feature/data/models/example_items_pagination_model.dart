import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/meta_model.dart';
import 'example_item_model.dart';

part 'example_items_pagination_model.g.dart';

@JsonSerializable(createToJson: false, checked: true)
class ExampleItemsPaginationModel {
  @JsonKey(name: 'data')
  final List<ExampleItemModel> items;
  @JsonKey(name: 'meta', fromJson: lastPageFromJson)
  final int lastPage;

  ExampleItemsPaginationModel({required this.items, required this.lastPage});

  factory ExampleItemsPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleItemsPaginationModelFromJson(json);
}
