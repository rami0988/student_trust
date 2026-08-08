import 'package:json_annotation/json_annotation.dart';

import 'link_model.dart';
import 'meta_model.dart';

part 'base_model.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BaseModel {
  @JsonKey(name: 'success')
  final bool? success;
  @JsonKey(name: 'message')
  final String? message;
  @JsonKey(name: 'data')
  final dynamic data;
  @JsonKey(name: 'links')
  final LinkModel? links;
  @JsonKey(name: 'meta')
  final MetaModel? meta;

  BaseModel({
    this.success,
    this.message,
    required this.data,
    this.links,
    this.meta,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) => _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);
}
